import { Controller, Get, Headers } from '@nestjs/common';
import { ApiHeader, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { InitResponse } from '../common/dto';
import { UserStatus, Platform } from '../common/enums';

@ApiTags('System')
@Controller('v1/init')
export class SystemController {
    @Get()
    @ApiOperation({
        summary: '앱 초기화 및 부트스트랩',
        description: '앱 버전 체크, 서비스 상태, 사용자 컨텍스트 및 자동 로그인 처리를 수행합니다.',
    })
    @ApiHeader({ name: 'X-App-Version', required: true, description: '현재 앱 버전' })
    @ApiHeader({ name: 'X-Platform', required: true, enum: Platform, description: '플랫폼' })
    @ApiHeader({ name: 'X-Device-Id', required: false, description: '디바이스 ID' })
    @ApiHeader({ name: 'X-Refresh-Token', required: false, description: '리프레시 토큰 (자동 로그인용)' })
    @ApiResponse({ status: 200, type: InitResponse })
    initialize(
        @Headers('X-App-Version') appVersion: string,
        @Headers('X-Platform') platform: string,
        @Headers('X-Device-Id') deviceId?: string,
        @Headers('X-Refresh-Token') refreshToken?: string,
    ): InitResponse {
        // Mock implementation
        return {
            config: {
                minVersion: '1.0.0',
                maintenanceMode: false,
            },
            forceUpdate: false,
            isMaintenance: false,
            userContext: {
                country: 'KR',
                currency: 'KRW',
                language: 'ko',
            },
            autoLogin: refreshToken ? {
                success: true,
                user: {
                    id: 'user-123',
                    nickname: '테스트유저',
                    status: UserStatus.ACTIVE,
                    createdAt: new Date(),
                },
                accessToken: 'mock-access-token',
                refreshToken: 'mock-new-refresh-token',
            } : undefined,
        };
    }
}
