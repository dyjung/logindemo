import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { SystemController } from './system/system.controller';
import { AppService } from './app.service';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [SystemController],
  providers: [AppService],
})
export class AppModule { }
