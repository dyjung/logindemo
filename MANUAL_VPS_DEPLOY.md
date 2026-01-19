# Hostinger VPS 배포 완전 매뉴얼

> LoginDemo 프로젝트를 Hostinger VPS에 Docker로 배포하는 전체 과정
>
> 작성일: 2026-01-18
> 서버: Ubuntu 24.04 LTS on Hostinger VPS

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [아키텍처](#2-아키텍처)
3. [VPS 초기 설정](#3-vps-초기-설정)
4. [Docker 설치](#4-docker-설치)
5. [프로젝트 구성 파일](#5-프로젝트-구성-파일)
6. [프로젝트 배포](#6-프로젝트-배포)
7. [도메인 연결](#7-도메인-연결)
8. [SSL 인증서 설정](#8-ssl-인증서-설정-lets-encrypt)
9. [트러블슈팅](#9-트러블슈팅)
10. [유지보수](#10-유지보수)
11. [빠른 참조](#11-빠른-참조)

---

## 1. 프로젝트 개요

### 1.1 프로젝트 구조

```
LoginDemo/
├── frontend/              # Next.js 프론트엔드
│   ├── Dockerfile
│   ├── src/app/
│   └── package.json
├── backend/               # NestJS 백엔드 API
│   ├── Dockerfile
│   ├── prisma/
│   └── package.json
├── docker-compose.yml     # 통합 Docker 설정
├── nginx.conf             # Nginx 리버스 프록시 설정
├── .env                   # 환경 변수 (git 제외)
└── MANUAL_VPS_DEPLOY.md   # 이 문서
```

### 1.2 기술 스택

| 구성요소 | 기술 | 포트 |
|----------|------|------|
| Frontend | Next.js 15 | 3000 (내부) |
| Backend | NestJS + Prisma | 3000 (내부) |
| Database | Supabase PostgreSQL | 외부 |
| Proxy | Nginx Alpine | 80, 443 |
| Container | Docker + Docker Compose | - |

---

## 2. 아키텍처

### 2.1 배포 아키텍처

```
                    ┌─────────────────────────────────────────────┐
                    │              Hostinger VPS                  │
                    │            72.62.245.151                    │
                    │                                             │
  Internet          │  ┌─────────────────────────────────────┐   │
     │              │  │         Docker Network              │   │
     │              │  │         (app-network)               │   │
     ▼              │  │                                     │   │
┌─────────┐         │  │  ┌─────────┐                       │   │
│ Client  │────────────▶│  │  Nginx  │ :80, :443            │   │
└─────────┘         │  │  └────┬────┘                       │   │
                    │  │       │                             │   │
                    │  │       ├──── / ────▶ Frontend :3000  │   │
                    │  │       │                             │   │
                    │  │       ├──── /v1 ──▶ Backend :3000   │   │
                    │  │       │                             │   │
                    │  │       └──── /api-docs ▶ Backend     │   │
                    │  │                                     │   │
                    │  └─────────────────────────────────────┘   │
                    │                                             │
                    └─────────────────────────────────────────────┘
                                        │
                                        ▼
                              ┌──────────────────┐
                              │    Supabase      │
                              │   PostgreSQL     │
                              └──────────────────┘
```

### 2.2 컨테이너 구성

| 컨테이너 | 이미지 | 역할 |
|----------|--------|------|
| logindemo-nginx | nginx:alpine | 리버스 프록시, SSL 종료 |
| logindemo-frontend | node:20-alpine | Next.js 웹 서버 |
| logindemo-backend | node:20-alpine | NestJS API 서버 |

---

## 3. VPS 초기 설정

### 3.1 Hostinger VPS 구매

1. [Hostinger](https://www.hostinger.com) 접속
2. VPS 플랜 선택 및 구매
3. OS: **Ubuntu 24.04 LTS** 선택
4. 초기 root 비밀번호 설정

### 3.2 SSH 접속

```bash
# root 계정으로 최초 접속
ssh root@72.62.245.151

# 비밀번호 입력
```

### 3.3 일반 사용자 계정 생성 (보안상 권장)

```bash
# 새 사용자 생성
adduser dyjung

# 비밀번호 설정 및 정보 입력
# (Enter로 기본값 사용 가능)

# sudo 권한 부여
usermod -aG sudo dyjung

# SSH 키 복사 (root의 키를 새 사용자에게)
mkdir -p /home/dyjung/.ssh
cp ~/.ssh/authorized_keys /home/dyjung/.ssh/
chown -R dyjung:dyjung /home/dyjung/.ssh
chmod 700 /home/dyjung/.ssh
chmod 600 /home/dyjung/.ssh/authorized_keys

# 이후 새 사용자로 접속
ssh dyjung@72.62.245.151
```

### 3.4 시스템 업데이트

```bash
sudo apt update
sudo apt upgrade -y
```

### 3.5 방화벽 설정 (UFW)

```bash
# SSH 허용 (먼저!)
sudo ufw allow OpenSSH

# HTTP/HTTPS 허용
sudo ufw allow 80
sudo ufw allow 443

# 방화벽 활성화
sudo ufw enable

# 상태 확인
sudo ufw status

# 출력 예시:
# Status: active
# To                         Action      From
# --                         ------      ----
# OpenSSH                    ALLOW       Anywhere
# 80                         ALLOW       Anywhere
# 443                        ALLOW       Anywhere
```

### 3.6 Git 설치

```bash
sudo apt install git -y
git --version
```

---

## 4. Docker 설치

### 4.1 기존 Docker 제거 (있는 경우)

```bash
sudo apt remove docker docker-engine docker.io containerd runc 2>/dev/null
```

### 4.2 Docker 설치

```bash
# 필수 패키지 설치
sudo apt install -y ca-certificates curl gnupg lsb-release

# Docker GPG 키 추가
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 저장소 추가
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 패키지 목록 업데이트
sudo apt update

# Docker 설치
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker 서비스 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 설치 확인
docker --version
docker compose version
```

### 4.3 Docker 설치 확인

```bash
# 테스트 컨테이너 실행
sudo docker run hello-world

# 성공 메시지 확인:
# Hello from Docker!
# This message shows that your installation appears to be working correctly.
```

### 4.4 로그아웃 후 재접속

```bash
# docker 그룹 적용을 위해 재접속 필요
exit
ssh dyjung@72.62.245.151

# sudo 없이 docker 명령 확인
docker ps
```

---

## 5. 프로젝트 구성 파일

### 5.1 docker-compose.yml

```yaml
# ============================================
# Docker Compose - LoginDemo (통합)
# Frontend (Next.js) + Backend (NestJS)
# ============================================

services:
  # NestJS API Server
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: logindemo-backend
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DATABASE_URL=${DATABASE_URL}
      - DIRECT_URL=${DIRECT_URL}
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/v1/init"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    networks:
      - app-network

  # Next.js Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      args:
        # 빈 문자열 = 상대 경로 사용 (Nginx가 프록시)
        - NEXT_PUBLIC_API_URL=
    container_name: logindemo-frontend
    restart: unless-stopped
    ports:
      - "3001:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      backend:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
    networks:
      - app-network

  # Nginx Reverse Proxy (HTTPS)
  nginx:
    image: nginx:alpine
    container_name: logindemo-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - /var/www/certbot:/var/www/certbot:ro
    depends_on:
      - frontend
      - backend
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

### 5.2 nginx.conf (HTTPS 적용 버전)

```nginx
# ============================================
# Nginx Configuration for LoginDemo
# HTTPS + HTTP to HTTPS redirect
# ============================================

# HTTP -> HTTPS 리다이렉트
server {
    listen 80;
    server_name dyjung.com www.dyjung.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS 서버
server {
    listen 443 ssl;
    server_name dyjung.com www.dyjung.com;

    # SSL 인증서
    ssl_certificate /etc/letsencrypt/live/dyjung.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dyjung.com/privkey.pem;

    # SSL 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Frontend (Next.js)
    location / {
        proxy_pass http://logindemo-frontend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API (/api/*)
    location /api {
        proxy_pass http://logindemo-backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend Health Check
    location /health {
        proxy_pass http://logindemo-backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # Backend v1 API
    location /v1 {
        proxy_pass http://logindemo-backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Swagger API Docs
    location /api-docs {
        proxy_pass http://logindemo-backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5.3 Backend Dockerfile

```dockerfile
# ============================================
# Multi-stage Dockerfile for NestJS Production
# ============================================

# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app

# Install dependencies for native modules (bcrypt)
RUN apk add --no-cache python3 make g++

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate Prisma Client
RUN npx prisma generate

# Build NestJS
RUN npm run build

# Stage 3: Production
FROM node:20-alpine AS production
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nestjs

# Copy necessary files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/prisma ./prisma

# Set ownership
RUN chown -R nestjs:nodejs /app

USER nestjs

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start command
CMD ["sh", "-c", "npx prisma db push --skip-generate && node dist/main"]
```

### 5.4 Frontend Dockerfile

```dockerfile
# ============================================
# Multi-stage Dockerfile for Next.js Production
# ============================================

# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build argument for API URL
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

RUN npm run build

# Stage 3: Production
FROM node:20-alpine AS production
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy built files
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Set ownership
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
```

### 5.5 .env 파일 (예시)

```bash
# Database (Supabase)
DATABASE_URL="postgresql://postgres.xxxxx:password@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.xxxxx:password@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres"
```

---

## 6. 프로젝트 배포

### 6.1 프로젝트 디렉토리 생성

```bash
sudo mkdir -p /var/www/logindemo
sudo chown -R $USER:$USER /var/www/logindemo
cd /var/www/logindemo
```

### 6.2 Git 저장소 클론

```bash
# HTTPS로 클론
git clone https://github.com/dyjung/logindemo.git .

# 또는 특정 브랜치
git clone -b main https://github.com/dyjung/logindemo.git .
```

### 6.3 환경 변수 설정

```bash
# .env 파일 생성
cat > .env << 'EOF'
DATABASE_URL="postgresql://user:password@host:6543/database?pgbouncer=true"
DIRECT_URL="postgresql://user:password@host:5432/database"
EOF

# 권한 설정 (보안상 중요!)
chmod 600 .env
```

### 6.4 Docker 이미지 빌드 및 실행

```bash
# 빌드 및 백그라운드 실행
sudo docker compose up -d --build

# 빌드 로그 실시간 확인
sudo docker compose up --build 2>&1 | tee build.log
```

### 6.5 상태 확인

```bash
# 컨테이너 상태 확인
sudo docker compose ps

# 예상 출력:
# NAME                  IMAGE                  STATUS                   PORTS
# logindemo-backend     logindemo-backend      Up (healthy)             0.0.0.0:3000->3000/tcp
# logindemo-frontend    logindemo-frontend     Up (healthy)             0.0.0.0:3001->3000/tcp
# logindemo-nginx       nginx:alpine           Up                       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```

### 6.6 로그 확인

```bash
# 모든 서비스 로그
sudo docker compose logs -f

# 특정 서비스 로그
sudo docker compose logs backend --tail=50
sudo docker compose logs frontend --tail=50
sudo docker compose logs nginx --tail=50
```

### 6.7 동작 확인

```bash
# Backend API 확인
curl http://localhost:3000/v1/init

# Frontend 확인 (Nginx 경유)
curl http://localhost

# IP로 외부 접속 확인
curl http://72.62.245.151
```

---

## 7. 도메인 연결

### 7.1 Hostinger DNS 설정

Hostinger 대시보드 → 도메인 → DNS 관리에서 A 레코드 추가:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 72.62.245.151 | 14400 |
| A | www | 72.62.245.151 | 14400 |

### 7.2 DNS 전파 확인

```bash
# DNS 확인 (서버 또는 로컬에서)
dig dyjung.com +short
# 결과: 72.62.245.151

nslookup dyjung.com
# 결과: Address: 72.62.245.151

# 온라인 도구로도 확인 가능
# https://dnschecker.org
```

### 7.3 HTTP 접속 확인

```bash
curl http://dyjung.com
curl http://www.dyjung.com

# 브라우저에서 접속 확인
# http://www.dyjung.com
```

---

## 8. SSL 인증서 설정 (Let's Encrypt)

### 8.1 Certbot 설치

```bash
sudo apt update
sudo apt install certbot -y
```

### 8.2 SSL 인증서 발급

```bash
# 중요: Docker 컨테이너 중지 (포트 80 해제 필요)
cd /var/www/logindemo
sudo docker compose down

# SSL 인증서 발급 (standalone 모드)
sudo certbot certonly --standalone -d dyjung.com -d www.dyjung.com

# 대화형 입력:
# 1. 이메일 주소 입력
# 2. 약관 동의 (Y)
# 3. 이메일 수신 동의 (선택)
```

### 8.3 인증서 발급 성공 확인

```bash
# 성공 시 출력 예시:
# Successfully received certificate.
# Certificate is saved at: /etc/letsencrypt/live/dyjung.com/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/dyjung.com/privkey.pem
```

### 8.4 인증서 파일 위치

```
/etc/letsencrypt/live/dyjung.com/
├── fullchain.pem   # 인증서 + 체인
├── privkey.pem     # 개인키
├── cert.pem        # 인증서만
└── chain.pem       # 중간 인증서
```

### 8.5 nginx.conf HTTPS 설정 확인

위 5.2 섹션의 nginx.conf가 이미 HTTPS 설정을 포함하고 있음.

### 8.6 Docker 재시작

```bash
# 443 포트 방화벽 허용 (아직 안했다면)
sudo ufw allow 443

# Docker 재시작
sudo docker compose up -d --build

# 상태 확인
sudo docker compose ps
```

### 8.7 HTTPS 접속 확인

```bash
# HTTPS 헤더 확인
curl -I https://www.dyjung.com

# HTTP가 HTTPS로 리다이렉트되는지 확인
curl -I http://www.dyjung.com

# 예상 출력:
# HTTP/1.1 301 Moved Permanently
# Location: https://www.dyjung.com/
```

### 8.8 인증서 자동 갱신 확인

```bash
# 갱신 테스트 (실제 갱신 안함)
sudo certbot renew --dry-run

# Certbot systemd timer 확인
sudo systemctl list-timers | grep certbot
```

### 8.9 인증서 갱신 시 주의사항

Let's Encrypt 인증서는 90일 유효. Certbot이 자동 갱신하지만, standalone 모드는 포트 80이 필요하므로 갱신 시 Docker를 잠시 중지해야 함.

```bash
# 수동 갱신 방법 (필요시)
cd /var/www/logindemo
sudo docker compose down
sudo certbot renew
sudo docker compose up -d
```

---

## 9. 트러블슈팅

### 9.1 Git pull 권한 문제

**오류:**
```
fatal: detected dubious ownership in repository at '/var/www/logindemo'
```

**해결:**
```bash
sudo git config --global --add safe.directory /var/www/logindemo
sudo git pull
```

### 9.2 Git pull 로컬 변경 충돌

**오류:**
```
error: Your local changes to the following files would be overwritten by merge
```

**해결 (로컬 변경 무시):**
```bash
sudo git reset --hard HEAD
sudo git pull
```

### 9.3 Healthcheck 실패

**증상:** Container가 `unhealthy` 상태

**확인:**
```bash
# Backend healthcheck
curl http://localhost:3000/v1/init

# Frontend healthcheck
curl http://localhost:3001/api/health

# 컨테이너 로그 확인
sudo docker compose logs backend --tail=100
```

**해결:**
- Backend: `/v1/init` 엔드포인트 존재 확인
- Frontend: `/api/health` API route 존재 확인

### 9.4 포트 충돌

**오류:**
```
Error starting userland proxy: listen tcp 0.0.0.0:80: bind: address already in use
```

**확인 및 해결:**
```bash
# 포트 사용 확인
sudo lsof -i :80
sudo lsof -i :443

# Apache 중지 (설치된 경우)
sudo systemctl stop apache2
sudo systemctl disable apache2

# 또는 충돌 프로세스 종료
sudo kill -9 <PID>
```

### 9.5 컨테이너 시작 실패

**확인:**
```bash
# 상세 로그 확인
sudo docker compose logs <service-name>

# 컨테이너 내부 접속
sudo docker exec -it logindemo-backend sh

# 이미지 다시 빌드
sudo docker compose build --no-cache
sudo docker compose up -d
```

### 9.6 SSL 인증서 오류

**증상:** 브라우저에서 SSL 오류

**확인:**
```bash
# 인증서 파일 존재 확인
sudo ls -la /etc/letsencrypt/live/dyjung.com/

# Nginx 설정 문법 확인
sudo docker exec logindemo-nginx nginx -t

# 인증서 만료일 확인
sudo openssl x509 -dates -noout -in /etc/letsencrypt/live/dyjung.com/fullchain.pem
```

### 9.7 Nginx 502 Bad Gateway

**원인:** Backend/Frontend 컨테이너가 아직 시작되지 않음

**확인:**
```bash
# 모든 컨테이너 상태 확인
sudo docker compose ps

# 컨테이너간 네트워크 확인
sudo docker network ls
sudo docker network inspect logindemo_app-network
```

---

## 10. 유지보수

### 10.1 코드 업데이트 배포

```bash
cd /var/www/logindemo

# 최신 코드 가져오기
sudo git pull

# 컨테이너 재빌드 및 재시작
sudo docker compose down
sudo docker compose up -d --build

# 또는 특정 서비스만
sudo docker compose up -d --build frontend
sudo docker compose up -d --build backend
```

### 10.2 로그 모니터링

```bash
# 실시간 로그 확인
sudo docker compose logs -f

# 특정 서비스 최근 로그
sudo docker compose logs backend --tail=100
sudo docker compose logs frontend --tail=100
sudo docker compose logs nginx --tail=100

# 특정 시간 이후 로그
sudo docker compose logs --since="2026-01-18T00:00:00"
```

### 10.3 컨테이너 재시작

```bash
# 전체 재시작
sudo docker compose restart

# 특정 서비스 재시작
sudo docker compose restart backend
sudo docker compose restart frontend
sudo docker compose restart nginx
```

### 10.4 디스크 정리

```bash
# 사용하지 않는 Docker 리소스 정리
sudo docker system prune -a

# 미사용 이미지만 삭제
sudo docker image prune -a

# 미사용 볼륨 삭제
sudo docker volume prune

# 디스크 사용량 확인
df -h
sudo docker system df
```

### 10.5 서버 재시작 후 자동 시작

Docker와 컨테이너는 다음 설정으로 자동 시작됨:
- Docker 서비스: `systemctl enable docker`
- 컨테이너: `restart: unless-stopped` 설정

### 10.6 백업

```bash
# .env 파일 백업 (중요!)
sudo cp /var/www/logindemo/.env ~/backup/env.backup.$(date +%Y%m%d)

# 전체 설정 백업
sudo tar -czvf ~/backup/logindemo-config.tar.gz \
  /var/www/logindemo/docker-compose.yml \
  /var/www/logindemo/nginx.conf \
  /var/www/logindemo/.env

# 데이터베이스는 Supabase에서 관리됨
```

---

## 11. 빠른 참조

### 11.1 서버 정보

| 항목 | 값 |
|------|-----|
| VPS IP | 72.62.245.151 |
| SSH | `ssh dyjung@72.62.245.151` |
| 프로젝트 경로 | `/var/www/logindemo` |
| 도메인 | dyjung.com, www.dyjung.com |
| SSL 만료일 | 2026-04-17 (자동 갱신) |

### 11.2 주요 URL

| 서비스 | URL |
|--------|-----|
| Frontend | https://www.dyjung.com |
| Backend API | https://www.dyjung.com/v1/init |
| Swagger Docs | https://www.dyjung.com/api-docs |

### 11.3 자주 사용하는 명령어

```bash
# 서버 접속
ssh dyjung@72.62.245.151

# 프로젝트 디렉토리 이동
cd /var/www/logindemo

# 상태 확인
sudo docker compose ps

# 로그 확인
sudo docker compose logs -f

# 업데이트 배포
sudo git pull && sudo docker compose up -d --build

# 재시작
sudo docker compose restart

# 중지
sudo docker compose down

# 완전 재빌드
sudo docker compose down && sudo docker compose up -d --build

# 리소스 정리
sudo docker system prune -a
```

### 11.4 포트 매핑

| 포트 | 서비스 | 설명 |
|------|--------|------|
| 80 | Nginx | HTTP (HTTPS 리다이렉트) |
| 443 | Nginx | HTTPS |
| 3000 | Backend | API (내부) |
| 3001 | Frontend | Web (내부) |

---

## 부록: 체크리스트

### A. 최초 배포 체크리스트

- [ ] VPS 구매 및 SSH 접속 확인
- [ ] 사용자 계정 생성 및 sudo 권한 부여
- [ ] 시스템 업데이트 (`apt update && apt upgrade`)
- [ ] 방화벽 설정 (22, 80, 443)
- [ ] Docker 및 Docker Compose 설치
- [ ] 프로젝트 클론
- [ ] .env 파일 생성
- [ ] Docker 빌드 및 실행
- [ ] HTTP 접속 확인
- [ ] DNS 설정 (A 레코드)
- [ ] DNS 전파 확인
- [ ] SSL 인증서 발급
- [ ] HTTPS 접속 확인

### B. 업데이트 배포 체크리스트

- [ ] `git pull`로 최신 코드 가져오기
- [ ] `docker compose up -d --build`
- [ ] `docker compose ps`로 상태 확인
- [ ] 웹사이트 동작 확인

---

## 연락처

- **긴급연락처**: 양부장 010-2623-5585

---

*마지막 수정: 2026-01-18*
