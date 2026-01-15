import { Injectable, ConflictException, BadRequestException, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
    RegisterRequest, RegisterResponse,
    LoginRequest, LoginResponse,
    TokenRefreshRequest, TokenRefreshResponse,
    TokenVerifyResponse,
    LogoutRequest, LogoutResponse,
    FindIdResponse,
    PasswordResetRequest, PasswordResetResponse,
    PasswordConfirmRequest, PasswordConfirmResponse
} from '../common/dto';
import { AuthenticationMethod, UserStatus } from '../common/enums';
import { AuthenticationMethod as PrismaAuthMethod } from '@prisma/client';
import { hashPassword, verifyPassword } from '../common/utils/password.util';
import { randomUUID, createHash } from 'crypto';

@Injectable()
export class AuthService {
    constructor(private readonly prisma: PrismaService) {}

    async register(request: RegisterRequest): Promise<RegisterResponse> {
        const { provider, email, password, nickname, socialAccessToken, marketingConsent } = request;

        // EMAIL 회원가입 시 이메일과 비밀번호 필수
        if (provider === AuthenticationMethod.EMAIL) {
            if (!email) {
                throw new BadRequestException('Email is required for email registration');
            }
            if (!password) {
                throw new BadRequestException('Password is required for email registration');
            }

            // 이메일 중복 체크
            const existingUser = await this.prisma.user.findUnique({
                where: { email },
            });
            if (existingUser) {
                throw new ConflictException('Email already exists');
            }
        }

        // 소셜 로그인 시 socialAccessToken 필수
        if (provider !== AuthenticationMethod.EMAIL && !socialAccessToken) {
            throw new BadRequestException('Social access token is required for social registration');
        }

        // 비밀번호 해싱 (EMAIL 회원가입 시)
        const passwordHash = password ? await hashPassword(password) : null;

        // Provider ID 생성 (소셜 로그인 시 실제로는 소셜 API에서 가져옴)
        const providerId = provider !== AuthenticationMethod.EMAIL
            ? `${provider.toLowerCase()}_${randomUUID()}`
            : null;

        // 트랜잭션으로 User + AuthenticationAccount 생성
        const user = await this.prisma.user.create({
            data: {
                email: email || null,
                nickname,
                status: 'ACTIVE',
                marketingConsent: marketingConsent || false,
                authenticationAccounts: {
                    create: {
                        method: provider as PrismaAuthMethod,
                        providerId,
                        passwordHash,
                    },
                },
            },
            include: {
                authenticationAccounts: true,
            },
        });

        // 토큰 생성 및 DB 저장
        const { accessToken, refreshToken } = await this.createTokensForUser(user.id);

        return {
            user: {
                id: user.id,
                nickname: user.nickname,
                status: user.status as UserStatus,
                createdAt: user.createdAt,
            },
            accessToken,
            refreshToken,
            expiresIn: 3600,
        };
    }

    async login(request: LoginRequest): Promise<LoginResponse> {
        const { provider, email, password, socialAccessToken } = request;

        // EMAIL 로그인
        if (provider === AuthenticationMethod.EMAIL) {
            if (!email || !password) {
                throw new BadRequestException('Email and password are required');
            }

            // 이메일로 사용자 찾기
            const user = await this.prisma.user.findUnique({
                where: { email },
                include: {
                    authenticationAccounts: {
                        where: { method: 'EMAIL' },
                    },
                },
            });

            if (!user) {
                throw new UnauthorizedException('Invalid email or password');
            }

            // 계정 상태 확인
            if (user.status !== 'ACTIVE') {
                throw new UnauthorizedException(`Account is ${user.status.toLowerCase()}`);
            }

            // EMAIL 인증 계정 확인
            const emailAccount = user.authenticationAccounts[0];
            if (!emailAccount || !emailAccount.passwordHash) {
                throw new UnauthorizedException('Invalid email or password');
            }

            // 비밀번호 검증
            const isValid = await verifyPassword(password, emailAccount.passwordHash);
            if (!isValid) {
                throw new UnauthorizedException('Invalid email or password');
            }

            // 마지막 로그인 시간 업데이트
            await this.prisma.user.update({
                where: { id: user.id },
                data: { lastLogin: new Date() },
            });

            // 토큰 생성 및 DB 저장
            const { accessToken, refreshToken } = await this.createTokensForUser(user.id);

            return {
                user: {
                    id: user.id,
                    nickname: user.nickname,
                    status: user.status as UserStatus,
                    createdAt: user.createdAt,
                },
                accessToken,
                refreshToken,
                expiresIn: 3600,
            };
        }

        // 소셜 로그인 (추후 구현)
        if (!socialAccessToken) {
            throw new BadRequestException('Social access token is required');
        }

        // 소셜 로그인은 실제 소셜 API 연동 필요
        throw new BadRequestException(`${provider} login is not implemented yet`);
    }

    // 토큰 해시 생성 헬퍼
    private hashToken(token: string): string {
        return createHash('sha256').update(token).digest('hex');
    }

    // RefreshToken DB 저장과 함께 로그인/회원가입 응답 생성
    async createTokensForUser(userId: string, deviceId?: string): Promise<{ accessToken: string; refreshToken: string }> {
        const accessToken = `access_${randomUUID()}`;
        const refreshToken = `refresh_${randomUUID()}`;
        const tokenHash = this.hashToken(refreshToken);

        // 7일 후 만료
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 7);

        await this.prisma.refreshToken.create({
            data: {
                tokenHash,
                userId,
                deviceId,
                expiresAt,
            },
        });

        return { accessToken, refreshToken };
    }

    // 토큰 갱신
    async refresh(request: TokenRefreshRequest): Promise<TokenRefreshResponse> {
        const { refreshToken } = request;

        if (!refreshToken) {
            throw new BadRequestException('Refresh token is required');
        }

        const tokenHash = this.hashToken(refreshToken);

        // DB에서 토큰 조회
        const storedToken = await this.prisma.refreshToken.findUnique({
            where: { tokenHash },
            include: { user: true },
        });

        if (!storedToken) {
            throw new UnauthorizedException('Invalid refresh token');
        }

        // 만료 확인
        if (storedToken.expiresAt < new Date()) {
            throw new UnauthorizedException('Refresh token expired');
        }

        // 무효화 확인
        if (storedToken.isRevoked) {
            throw new UnauthorizedException('Refresh token has been revoked');
        }

        // 사용자 상태 확인
        if (storedToken.user.status !== 'ACTIVE') {
            throw new UnauthorizedException(`Account is ${storedToken.user.status.toLowerCase()}`);
        }

        // 기존 토큰 무효화 (Rotation)
        await this.prisma.refreshToken.update({
            where: { id: storedToken.id },
            data: {
                isRevoked: true,
                revokedAt: new Date(),
                revokedReason: 'Token rotated',
                usageCount: { increment: 1 },
                lastUsedAt: new Date(),
            },
        });

        // 새 토큰 생성
        const { accessToken, refreshToken: newRefreshToken } = await this.createTokensForUser(
            storedToken.userId,
            storedToken.deviceId ?? undefined,
        );

        return {
            accessToken,
            refreshToken: newRefreshToken,
        };
    }

    // 토큰 검증
    async verify(accessToken: string): Promise<TokenVerifyResponse> {
        // 현재는 간단한 형식 검증만 (추후 JWT 검증으로 교체)
        if (!accessToken || !accessToken.startsWith('access_')) {
            return { valid: false };
        }

        // 실제로는 JWT를 디코딩하여 사용자 ID를 추출
        // 현재는 마지막 로그인한 사용자를 반환 (데모용)
        const user = await this.prisma.user.findFirst({
            where: { status: 'ACTIVE' },
            orderBy: { lastLogin: 'desc' },
        });

        if (!user) {
            return { valid: false };
        }

        return {
            valid: true,
            user: {
                id: user.id,
                nickname: user.nickname,
                status: user.status as UserStatus,
                createdAt: user.createdAt,
            },
        };
    }

    // 로그아웃
    async logout(request: LogoutRequest, refreshToken?: string): Promise<LogoutResponse> {
        const { allDevices } = request;
        const tokenToRevoke = request.refreshToken || refreshToken;

        if (allDevices) {
            // 모든 디바이스에서 로그아웃 - 해당 사용자의 모든 토큰 무효화
            if (tokenToRevoke) {
                const tokenHash = this.hashToken(tokenToRevoke);
                const storedToken = await this.prisma.refreshToken.findUnique({
                    where: { tokenHash },
                });

                if (storedToken) {
                    await this.prisma.refreshToken.updateMany({
                        where: {
                            userId: storedToken.userId,
                            isRevoked: false,
                        },
                        data: {
                            isRevoked: true,
                            revokedAt: new Date(),
                            revokedReason: 'Logout from all devices',
                        },
                    });
                }
            }
            return { success: true, message: 'Logged out from all devices' };
        }

        // 단일 디바이스 로그아웃
        if (tokenToRevoke) {
            const tokenHash = this.hashToken(tokenToRevoke);
            await this.prisma.refreshToken.updateMany({
                where: { tokenHash, isRevoked: false },
                data: {
                    isRevoked: true,
                    revokedAt: new Date(),
                    revokedReason: 'User logout',
                },
            });
        }

        return { success: true, message: 'Successfully logged out' };
    }

    // 아이디(이메일) 찾기
    async findId(provider: string, socialAccessToken: string): Promise<FindIdResponse> {
        if (!provider || !socialAccessToken) {
            throw new BadRequestException('Provider and social access token are required');
        }

        // 실제로는 소셜 API를 호출하여 사용자 정보를 가져옴
        // 여기서는 providerId로 직접 조회 (데모용)
        const authAccount = await this.prisma.authenticationAccount.findFirst({
            where: {
                method: provider.toUpperCase() as PrismaAuthMethod,
            },
            include: {
                user: {
                    include: {
                        authenticationAccounts: true,
                    },
                },
            },
        });

        if (!authAccount || !authAccount.user.email) {
            throw new NotFoundException('No account found with this social login');
        }

        // 이메일 마스킹
        const email = authAccount.user.email;
        const [localPart, domain] = email.split('@');
        const maskedLocal = localPart.substring(0, 2) + '***';
        const maskedEmail = `${maskedLocal}@${domain}`;

        // 연결된 인증 방법 목록
        const linkedMethods = authAccount.user.authenticationAccounts.map(
            (acc) => acc.method as AuthenticationMethod,
        );

        return {
            maskedEmail,
            createdAt: authAccount.user.createdAt,
            linkedMethods,
        };
    }

    // 비밀번호 재설정 요청
    async passwordReset(request: PasswordResetRequest): Promise<PasswordResetResponse> {
        const { email } = request;

        const user = await this.prisma.user.findUnique({
            where: { email },
        });

        // 보안상 사용자 존재 여부와 관계없이 동일한 응답 반환
        if (!user) {
            return { sent: true, message: 'If the email exists, a reset link has been sent', retryAfter: 60 };
        }

        // 기존 미사용 토큰 무효화
        await this.prisma.passwordResetToken.updateMany({
            where: {
                userId: user.id,
                isUsed: false,
                expiresAt: { gt: new Date() },
            },
            data: {
                isUsed: true,
                usedAt: new Date(),
            },
        });

        // 새 토큰 생성 (1시간 유효)
        const resetToken = randomUUID();
        const tokenHash = this.hashToken(resetToken);
        const expiresAt = new Date();
        expiresAt.setHours(expiresAt.getHours() + 1);

        await this.prisma.passwordResetToken.create({
            data: {
                tokenHash,
                userId: user.id,
                expiresAt,
            },
        });

        // 실제로는 이메일 발송
        console.log(`[DEBUG] Password reset token for ${email}: ${resetToken}`);

        return {
            sent: true,
            message: 'Password reset email sent',
            retryAfter: 60,
        };
    }

    // 비밀번호 변경 확정
    async passwordConfirm(request: PasswordConfirmRequest): Promise<PasswordConfirmResponse> {
        const { token, newPassword } = request;

        const tokenHash = this.hashToken(token);

        const resetToken = await this.prisma.passwordResetToken.findUnique({
            where: { tokenHash },
            include: { user: true },
        });

        if (!resetToken) {
            throw new BadRequestException('Invalid or expired reset token');
        }

        if (resetToken.isUsed) {
            throw new BadRequestException('Reset token has already been used');
        }

        if (resetToken.expiresAt < new Date()) {
            throw new BadRequestException('Reset token has expired');
        }

        // 비밀번호 해싱
        const passwordHash = await hashPassword(newPassword);

        // 트랜잭션으로 비밀번호 업데이트 및 토큰 사용 처리
        await this.prisma.$transaction([
            // EMAIL 인증 계정의 비밀번호 업데이트
            this.prisma.authenticationAccount.updateMany({
                where: {
                    userId: resetToken.userId,
                    method: 'EMAIL',
                },
                data: { passwordHash },
            }),
            // 토큰 사용 처리
            this.prisma.passwordResetToken.update({
                where: { id: resetToken.id },
                data: {
                    isUsed: true,
                    usedAt: new Date(),
                },
            }),
            // 해당 사용자의 모든 refresh 토큰 무효화 (보안)
            this.prisma.refreshToken.updateMany({
                where: {
                    userId: resetToken.userId,
                    isRevoked: false,
                },
                data: {
                    isRevoked: true,
                    revokedAt: new Date(),
                    revokedReason: 'Password changed',
                },
            }),
        ]);

        return {
            success: true,
            message: 'Password changed successfully',
        };
    }
}
