import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
    IsString, IsEmail, IsEnum, IsOptional, IsDate, IsNumber,
    ValidateNested, IsBoolean
} from 'class-validator';
import { Type } from 'class-transformer';
import { UserStatus, Platform } from './enums';

export class User {
    @ApiProperty()
    @IsString()
    id: string;

    @ApiPropertyOptional()
    @IsOptional()
    @IsEmail()
    email?: string;

    @ApiProperty()
    @IsString()
    nickname: string;

    @ApiProperty({ enum: UserStatus })
    @IsEnum(UserStatus)
    status: UserStatus;

    @ApiProperty()
    @IsDate()
    @Type(() => Date)
    createdAt: Date;

    @ApiPropertyOptional()
    @IsOptional()
    @IsDate()
    @Type(() => Date)
    lastLogin?: Date;

    @ApiPropertyOptional()
    @IsOptional()
    @IsDate()
    @Type(() => Date)
    updatedAt?: Date;
}

export class GeoLocation {
    @ApiProperty()
    @IsNumber()
    latitude: number;

    @ApiProperty()
    @IsNumber()
    longitude: number;
}

export class UserContext {
    @ApiProperty()
    @IsString()
    country: string;

    @ApiProperty()
    @IsString()
    currency: string;

    @ApiProperty()
    @IsString()
    language: string;

    @ApiPropertyOptional()
    @IsOptional()
    @ValidateNested()
    @Type(() => GeoLocation)
    location?: GeoLocation;
}

export class AppConfig {
    @ApiProperty()
    @IsString()
    minVersion: string;

    @ApiProperty()
    @IsBoolean()
    maintenanceMode: boolean;

    @ApiPropertyOptional()
    @IsOptional()
    @IsString()
    noticeMessage?: string;
}

export class DeviceInfo {
    @ApiProperty()
    @IsString()
    deviceId: string;

    @ApiProperty({ enum: Platform })
    @IsEnum(Platform)
    platform: Platform;

    @ApiProperty()
    @IsString()
    appVersion: string;
}
