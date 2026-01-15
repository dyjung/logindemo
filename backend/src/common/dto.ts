import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
    IsString, IsEmail, IsEnum, IsOptional, IsBoolean, IsNumber,
    IsArray, ValidateNested, MinLength, MaxLength, IsDate
} from 'class-validator';
import { Type } from 'class-transformer';
import { AuthenticationMethod, AutoLoginFailureReason } from './enums';
import { User, AppConfig, UserContext, DeviceInfo } from './models';

/** Header DTOs */
export class CommonClientHeaders {
    @ApiProperty({ name: 'X-App-Version' })
    @IsString()
    'x-app-version': string;

    @ApiProperty({ name: 'X-Platform' })
    @IsString()
    'x-platform': string;

    @ApiPropertyOptional({ name: 'X-Device-Id' })
    @IsOptional()
    @IsString()
    'x-device-id'?: string;

    @ApiPropertyOptional({ name: 'X-Request-Id' })
    @IsOptional()
    @IsString()
    'x-request-id'?: string;
}

/** Response Models */
export class AutoLoginResult {
    @ApiProperty()
    @IsBoolean()
    success: boolean;

    @ApiPropertyOptional()
    @IsOptional()
    @ValidateNested()
    @Type(() => User)
    user?: User;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    accessToken?: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    refreshToken?: string;

    @ApiPropertyOptional({ enum: AutoLoginFailureReason })
    @IsOptional()
    @IsEnum(AutoLoginFailureReason)
    failureReason?: AutoLoginFailureReason;
}

export class InitResponse {
    @ApiProperty()
    @ValidateNested()
    @Type(() => AppConfig)
    config: AppConfig;

    @ApiProperty()
    @IsBoolean()
    forceUpdate: boolean;

    @ApiProperty()
    @IsBoolean()
    isMaintenance: boolean;

    @ApiProperty()
    @ValidateNested()
    @Type(() => UserContext)
    userContext: UserContext;

    @ApiPropertyOptional()
    @IsOptional()
    @ValidateNested()
    @Type(() => AutoLoginResult)
    autoLogin?: AutoLoginResult;
}

/** Auth Request/Response */
export class LoginRequest {
    @ApiProperty({ enum: AuthenticationMethod })
    @IsEnum(AuthenticationMethod)
    provider: AuthenticationMethod;

    @ApiPropertyOptional()
    @IsOptional()
    @IsEmail()
    email?: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    password?: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    socialAccessToken?: string;

    @ApiPropertyOptional()
    @IsOptional()
    @ValidateNested()
    @Type(() => DeviceInfo)
    deviceInfo?: DeviceInfo;
}

export class LoginResponse {
    @ApiProperty()
    @ValidateNested()
    @Type(() => User)
    user: User;

    @ApiProperty()
    @IsString()
    accessToken: string;

    @ApiProperty()
    @IsString()
    refreshToken: string;

    @ApiProperty()
    @IsNumber()
    expiresIn: number;
}

export class TokenRefreshRequest {
    @ApiProperty()
    @IsString()
    refreshToken: string;

    @ApiPropertyOptional()
    @IsOptional()
    @ValidateNested()
    @Type(() => DeviceInfo)
    deviceInfo?: DeviceInfo;
}

export class TokenRefreshResponse {
    @ApiProperty()
    @IsString()
    accessToken: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    refreshToken?: string;
}

export class TokenVerifyResponse {
    @ApiProperty()
    @IsBoolean()
    valid: boolean;

    @ApiPropertyOptional()
    @IsOptional()
    @ValidateNested()
    @Type(() => User)
    user?: User;
}

export class LogoutRequest {
    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    refreshToken?: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsBoolean()
    allDevices?: boolean;
}

export class LogoutResponse {
    @ApiProperty()
    @IsBoolean()
    success: boolean;

    @ApiProperty()
    @IsString()
    message: string;
}

export class RegisterRequest {
    @ApiProperty({ enum: AuthenticationMethod })
    @IsEnum(AuthenticationMethod)
    provider: AuthenticationMethod;

    @ApiPropertyOptional()
    @IsOptional()
    @IsEmail()
    email?: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    @MinLength(8)
    @MaxLength(100)
    password?: string;

    @ApiProperty()
    @IsString()
    @MinLength(2)
    @MaxLength(20)
    nickname: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    socialAccessToken?: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsBoolean()
    marketingConsent?: boolean;

    @ApiPropertyOptional()
    @IsOptional()
    @ValidateNested()
    @Type(() => DeviceInfo)
    deviceInfo?: DeviceInfo;
}

export class RegisterResponse {
    @ApiProperty()
    @ValidateNested()
    @Type(() => User)
    user: User;

    @ApiProperty()
    @IsString()
    accessToken: string;

    @ApiProperty()
    @IsString()
    refreshToken: string;

    @ApiProperty()
    @IsNumber()
    expiresIn: number;
}

export class FindIdResponse {
    @ApiProperty()
    @IsString()
    maskedEmail: string;

    @ApiProperty()
    @IsDate()
    @Type(() => Date)
    createdAt: Date;

    @ApiProperty({ enum: AuthenticationMethod, isArray: true })
    @IsArray()
    @IsEnum(AuthenticationMethod, { each: true })
    linkedMethods: AuthenticationMethod[];
}

export class PasswordResetRequest {
    @ApiProperty()
    @IsEmail()
    email: string;
}

export class PasswordResetResponse {
    @ApiProperty()
    @IsBoolean()
    sent: boolean;

    @ApiProperty()
    @IsString()
    message: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsNumber()
    retryAfter?: number;
}

export class PasswordConfirmRequest {
    @ApiProperty()
    @IsString()
    token: string;

    @ApiProperty()
    @IsString()
    @MinLength(8)
    @MaxLength(100)
    newPassword: string;
}

export class PasswordConfirmResponse {
    @ApiProperty()
    @IsBoolean()
    success: boolean;

    @ApiProperty()
    @IsString()
    message: string;
}
