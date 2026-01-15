import { Controller, Post, Get, Body, Headers, Patch, Query, HttpStatus, HttpCode } from '@nestjs/common';
import { ApiHeader, ApiOperation, ApiResponse, ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import {
    LoginRequest, LoginResponse,
    TokenRefreshRequest, TokenRefreshResponse,
    TokenVerifyResponse,
    LogoutRequest, LogoutResponse,
    RegisterRequest, RegisterResponse,
    FindIdResponse,
    PasswordResetRequest, PasswordResetResponse,
    PasswordConfirmRequest, PasswordConfirmResponse
} from '../common/dto';
import { UserStatus, Platform, AuthenticationMethod } from '../common/enums';
import { AuthService } from './auth.service';

@ApiTags('Auth')
@Controller('v1/auth')
export class AuthController {
    constructor(private readonly authService: AuthService) {}

    @Post('login')
    @ApiOperation({ summary: '통합 로그인' })
    @ApiHeader({ name: 'X-App-Version', required: true })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform })
    @ApiResponse({ status: 200, type: LoginResponse })
    async login(@Body() body: LoginRequest): Promise<LoginResponse> {
        return this.authService.login(body);
    }

    @Post('refresh')
    @ApiOperation({ summary: '토큰 갱신' })
    @ApiHeader({ name: 'X-App-Version', required: true })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform })
    @ApiResponse({ status: 200, type: TokenRefreshResponse })
    async refresh(@Body() body: TokenRefreshRequest): Promise<TokenRefreshResponse> {
        return this.authService.refresh(body);
    }

    @Get('verify')
    @ApiBearerAuth()
    @ApiOperation({ summary: '토큰 검증' })
    @ApiHeader({ name: 'X-App-Version', required: true })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform })
    @ApiResponse({ status: 200, type: TokenVerifyResponse })
    async verify(@Headers('authorization') authHeader: string): Promise<TokenVerifyResponse> {
        const token = authHeader?.replace('Bearer ', '');
        return this.authService.verify(token);
    }

    @Post('logout')
    @ApiBearerAuth()
    @ApiOperation({ summary: '로그아웃' })
    @ApiResponse({ status: 200, type: LogoutResponse })
    async logout(@Body() body: LogoutRequest): Promise<LogoutResponse> {
        return this.authService.logout(body);
    }

    @Post('register')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: '통합 회원가입' })
    @ApiHeader({ name: 'X-App-Version', required: true })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform })
    @ApiResponse({ status: 201, type: RegisterResponse })
    async register(@Body() body: RegisterRequest): Promise<RegisterResponse> {
        return this.authService.register(body);
    }

    @Get('find-id')
    @ApiOperation({ summary: '이메일(아이디) 찾기' })
    @ApiHeader({ name: 'X-App-Version', required: true })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform })
    @ApiResponse({ status: 200, type: FindIdResponse })
    async findId(
        @Query('provider') provider: string,
        @Query('socialAccessToken') socialAccessToken: string
    ): Promise<FindIdResponse> {
        return this.authService.findId(provider, socialAccessToken);
    }

    @Post('password-reset')
    @ApiOperation({ summary: '비밀번호 재설정 요청' })
    @ApiHeader({ name: 'X-App-Version', required: true })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform })
    @ApiResponse({ status: 200, type: PasswordResetResponse })
    async passwordReset(@Body() body: PasswordResetRequest): Promise<PasswordResetResponse> {
        return this.authService.passwordReset(body);
    }

    @Patch('password-confirm')
    @ApiOperation({ summary: '비밀번호 변경 확정' })
    @ApiHeader({ name: 'X-App-Version', required: true })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform })
    @ApiResponse({ status: 200, type: PasswordConfirmResponse })
    async passwordConfirm(@Body() body: PasswordConfirmRequest): Promise<PasswordConfirmResponse> {
        return this.authService.passwordConfirm(body);
    }
}
