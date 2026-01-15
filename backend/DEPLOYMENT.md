# Backend Deployment Guide

Hostinger VPS + Supabase PostgreSQL 배포 가이드

---

## 목차

### Part A: 기본 배포 (PM2)
1. [Supabase 설정](#1-supabase-설정)
2. [Hostinger VPS 구매 및 접속](#2-hostinger-vps-구매-및-접속)
3. [VPS 초기 설정](#3-vps-초기-설정)
4. [백엔드 코드 업로드](#4-백엔드-코드-업로드)
5. [환경변수 및 DB 설정](#5-환경변수-및-db-설정)
6. [PM2로 서버 실행](#6-pm2로-서버-실행)
7. [Nginx 리버스 프록시](#7-nginx-리버스-프록시)
8. [SSL 인증서 설정](#8-ssl-인증서-설정)
9. [방화벽 설정](#9-방화벽-설정)
10. [배포 후 관리](#10-배포-후-관리)

### Part B: Docker 배포 (상용화 추천)
11. [Docker 배포 개요](#11-docker-배포-개요)
12. [VPS Docker 설치](#12-vps-docker-설치)
13. [Docker로 배포](#13-docker로-배포)
14. [Docker 관리](#14-docker-관리)

---

## 아키텍처

```
┌─────────────┐     HTTPS      ┌─────────────────┐     TCP      ┌──────────────┐
│   Mobile    │ ────────────── │  Hostinger VPS  │ ──────────── │   Supabase   │
│   App       │                │  (NestJS API)   │              │  PostgreSQL  │
└─────────────┘                └─────────────────┘              └──────────────┘
                                     │
                               Nginx + SSL
```

---

## 1. Supabase 설정

### 1.1 프로젝트 생성

1. [supabase.com](https://supabase.com) 접속
2. **Start your project** 클릭
3. GitHub 계정으로 로그인
4. **New Project** 클릭:
   - **Organization**: 선택 또는 새로 생성
   - **Project name**: `logindemo`
   - **Database Password**: 강력한 비밀번호 설정
   - **Region**: `Northeast Asia (Tokyo)` 선택
5. **Create new project** 클릭 (2-3분 소요)

### 1.2 연결 정보 확인

1. 좌측 메뉴 **Project Settings** (톱니바퀴) 클릭
2. **Database** 탭 선택
3. 아래 두 가지 연결 문자열 복사:

**Transaction Mode (Pooler)** - 일반 쿼리용:
```
postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres
```

**Session Mode (Direct)** - 마이그레이션용:
```
postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres
```

### 1.3 연결 정보 기록

```
PROJECT_REF: abcdefghijklmnop
PASSWORD: MyStr0ngP@ssw0rd!
REGION: aws-0-ap-northeast-1
```

**예시 연결 문자열:**
```
DATABASE_URL="postgresql://postgres.abcdefghijklmnop:MyStr0ngP@ssw0rd!@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.abcdefghijklmnop:MyStr0ngP@ssw0rd!@aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres"
```

- [ ] Supabase 프로젝트 생성 완료
- [ ] 연결 문자열 복사 완료

---

## 2. Hostinger VPS 구매 및 접속

### 2.1 VPS 구매

1. [hostinger.com/vps-hosting](https://www.hostinger.com/vps-hosting) 접속
2. 플랜 선택 (KVM 1 추천 - 시작용으로 충분)
3. **OS 선택**: Ubuntu 22.04 LTS
4. **데이터센터**: Singapore 또는 가까운 곳

### 2.2 VPS 정보 기록

```
VPS IP: 123.456.78.90
Root Password: VpsR00tP@ss!
도메인 (선택): api.logindemo.com
```

### 2.3 SSH 접속

**Mac/Linux 터미널:**
```bash
ssh root@[VPS_IP]
```

**Windows:**
- PuTTY 또는 Windows Terminal 사용

- [ ] VPS 구매 완료
- [ ] SSH 접속 성공

---

## 3. VPS 초기 설정

SSH 접속 후 아래 명령어를 순서대로 실행:

### 3.1 시스템 업데이트

```bash
apt update && apt upgrade -y
```

### 3.2 필수 패키지 설치

```bash
apt install -y curl git nginx certbot python3-certbot-nginx ufw
```

### 3.3 Node.js 20 설치 (NVM)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
```

```bash
source ~/.bashrc
```

```bash
nvm install 20
nvm use 20
nvm alias default 20
```

### 3.4 PM2 설치

```bash
npm install -g pm2
```

### 3.5 설치 확인

```bash
node -v   # v20.x.x 출력되어야 함
npm -v
pm2 -v
nginx -v
```

- [ ] 시스템 업데이트 완료
- [ ] Node.js 20 설치 완료
- [ ] PM2 설치 완료
- [ ] Nginx 설치 완료

---

## 4. 백엔드 코드 업로드

두 가지 방법 중 선택:

### 방법 A: Git Clone (GitHub 사용 시)

```bash
mkdir -p /var/www
cd /var/www
git clone https://github.com/dyjung/logindemo-backend.git backend
cd backend
npm install --production
```

### 방법 B: 직접 업로드 (로컬에서)

**로컬 터미널에서 실행:**

```bash
# 1. 백엔드 폴더로 이동
cd /Users/doyoungchung/WorkSpace/iOS/LoginDemo

# 2. 압축 (node_modules 제외)
tar --exclude='backend/node_modules' \
    --exclude='backend/dist' \
    --exclude='backend/.env' \
    -czvf backend.tar.gz backend/

# 3. VPS로 전송
scp backend.tar.gz root@[VPS_IP]:/var/www/
```

**VPS에서 실행:**

```bash
cd /var/www
tar -xzvf backend.tar.gz
cd backend
npm install --production
```

- [ ] 코드 업로드 완료
- [ ] npm install 완료

---

## 5. 환경변수 및 DB 설정

### 5.1 환경변수 파일 생성

```bash
nano /var/www/backend/.env
```

아래 내용 입력 (Supabase 정보로 교체):

```env
# Supabase PostgreSQL
DATABASE_URL="postgresql://postgres.abcdefghijklmnop:MyStr0ngP@ssw0rd!@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.abcdefghijklmnop:MyStr0ngP@ssw0rd!@aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres"

# Application
NODE_ENV=production
PORT=3000
```

저장: `Ctrl + X` → `Y` → `Enter`

### 5.2 Prisma 클라이언트 생성

```bash
cd /var/www/backend
npx prisma generate
```

### 5.3 데이터베이스 마이그레이션

```bash
npx prisma migrate deploy
```

### 5.4 마이그레이션 확인

```bash
npx prisma studio
```
(브라우저에서 http://[VPS_IP]:5555 접속하여 테이블 확인 후 Ctrl+C로 종료)

### 5.5 NestJS 빌드

```bash
npm run build
```

- [ ] .env 파일 생성 완료
- [ ] Prisma generate 완료
- [ ] DB 마이그레이션 완료
- [ ] NestJS 빌드 완료

---

## 6. PM2로 서버 실행

### 6.1 PM2 설정 파일 생성

```bash
nano /var/www/backend/ecosystem.config.js
```

내용:

```javascript
module.exports = {
  apps: [{
    name: 'logindemo-api',
    script: 'dist/main.js',
    cwd: '/var/www/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
```

### 6.2 PM2로 실행

```bash
cd /var/www/backend
pm2 start ecosystem.config.js
```

### 6.3 시스템 재부팅 시 자동 시작

```bash
pm2 startup
pm2 save
```

### 6.4 상태 확인

```bash
pm2 status
pm2 logs logindemo-api
```

### 6.5 로컬 테스트

```bash
curl http://localhost:3000
```

- [ ] PM2 실행 완료
- [ ] 자동 시작 설정 완료
- [ ] localhost 테스트 성공

---

## 7. Nginx 리버스 프록시

### 7.1 Nginx 설정 파일 생성

```bash
nano /etc/nginx/sites-available/api
```

**도메인이 있는 경우 (예: api.logindemo.com):**

```nginx
server {
    listen 80;
    server_name api.logindemo.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
```

**도메인이 없는 경우 (IP만 사용):**

```nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
```

### 7.2 심볼릭 링크 생성

```bash
ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
```

### 7.3 기본 설정 제거 (선택)

```bash
rm /etc/nginx/sites-enabled/default
```

### 7.4 설정 테스트 및 재시작

```bash
nginx -t
systemctl restart nginx
```

### 7.5 외부 접속 테스트

```bash
curl http://[VPS_IP]
```

- [ ] Nginx 설정 완료
- [ ] 외부 접속 테스트 성공

---

## 8. SSL 인증서 설정

> 도메인이 있는 경우에만 진행

### 8.1 DNS 설정

도메인 관리자에서 A 레코드 추가:
```
api.logindemo.com → 123.456.78.90
```

### 8.2 Let's Encrypt SSL 발급

```bash
certbot --nginx -d api.logindemo.com
```

이메일 입력 후 안내에 따라 진행

### 8.3 자동 갱신 테스트

```bash
certbot renew --dry-run
```

- [ ] DNS 설정 완료
- [ ] SSL 인증서 발급 완료

---

## 9. 방화벽 설정

### 9.1 UFW 설정

```bash
ufw allow 22      # SSH
ufw allow 80      # HTTP
ufw allow 443     # HTTPS
ufw --force enable
ufw status
```

- [ ] 방화벽 설정 완료

---

## 10. 배포 후 관리

### 10.1 유용한 명령어

```bash
# 서버 상태 확인
pm2 status

# 로그 확인
pm2 logs logindemo-api

# 서버 재시작
pm2 restart logindemo-api

# 서버 중지
pm2 stop logindemo-api

# Nginx 상태
systemctl status nginx

# Nginx 재시작
systemctl restart nginx
```

### 10.2 코드 업데이트 시

```bash
cd /var/www/backend

# Git 사용 시
git pull origin main

# 의존성 변경 시
npm install --production

# Prisma 스키마 변경 시
npx prisma generate
npx prisma migrate deploy

# 재빌드
npm run build

# 재시작
pm2 restart logindemo-api
```

### 10.3 배포 자동화 스크립트 (선택)

```bash
nano /var/www/backend/deploy.sh
```

```bash
#!/bin/bash
cd /var/www/backend
git pull origin main
npm install --production
npx prisma generate
npx prisma migrate deploy
npm run build
pm2 restart logindemo-api
echo "Deployment completed!"
```

> GitHub 저장소: https://github.com/dyjung/logindemo-backend.git

```bash
chmod +x /var/www/backend/deploy.sh
```

실행:
```bash
/var/www/backend/deploy.sh
```

---

## 최종 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] Hostinger VPS 구매 및 SSH 접속
- [ ] Node.js, PM2, Nginx 설치
- [ ] 백엔드 코드 업로드
- [ ] .env 환경변수 설정
- [ ] Prisma 마이그레이션
- [ ] PM2로 서버 실행
- [ ] Nginx 리버스 프록시 설정
- [ ] SSL 인증서 (도메인 있는 경우)
- [ ] 방화벽 설정
- [ ] API 테스트 성공

---

## API 엔드포인트

배포 완료 후 접속 주소:

```
HTTP:  http://123.456.78.90
HTTPS: https://api.logindemo.com (도메인 있는 경우)
```

Swagger 문서:
```
http://123.456.78.90/api
https://api.logindemo.com/api
```

---

# Part B: Docker 배포 (상용화 추천)

---

## 11. Docker 배포 개요

### 11.1 Docker vs PM2 비교

| 항목 | PM2 | Docker |
|------|-----|--------|
| **격리성** | 낮음 | 높음 (컨테이너) |
| **이식성** | Node.js 버전 의존 | 완전 독립 |
| **배포 일관성** | 환경별 차이 가능 | 동일한 환경 보장 |
| **롤백** | 수동 | 이미지 태그로 쉽게 |
| **스케일링** | 제한적 | 쉬움 |
| **복잡도** | 낮음 | 중간 |

### 11.2 Docker 파일 구조

```
backend/
├── Dockerfile              # 멀티스테이지 빌드
├── docker-compose.yml      # 프로덕션 (Supabase)
├── docker-compose.dev.yml  # 로컬 개발 (PostgreSQL 포함)
├── .dockerignore           # Docker 빌드 제외 파일
└── ...
```

### 11.3 아키텍처 (Docker)

```
┌─────────────┐     HTTPS      ┌─────────────────────────────────┐
│   Mobile    │ ────────────── │         Hostinger VPS           │
│   App       │                │  ┌───────────┐  ┌────────────┐  │
└─────────────┘                │  │   Nginx   │──│  Docker    │  │
                               │  │ (Host)    │  │ Container  │  │
                               │  └───────────┘  │ (NestJS)   │  │
                               │                 └──────┬─────┘  │
                               └────────────────────────┼────────┘
                                                        │ TCP
                                               ┌────────▼────────┐
                                               │    Supabase     │
                                               │   PostgreSQL    │
                                               └─────────────────┘
```

- [ ] Docker 개념 이해 완료

---

## 12. VPS Docker 설치

> Part A의 1~2번(Supabase, VPS 구매)을 먼저 완료하세요.

### 12.1 Docker 설치

```bash
# 1. 기존 Docker 제거 (있다면)
apt remove docker docker-engine docker.io containerd runc

# 2. 필수 패키지 설치
apt update
apt install -y ca-certificates curl gnupg lsb-release

# 3. Docker GPG 키 추가
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Docker 저장소 추가
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Docker 설치
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Docker 확인
docker --version
docker compose version
```

### 12.2 Docker 서비스 시작

```bash
systemctl start docker
systemctl enable docker
```

### 12.3 Nginx 설치 (호스트)

```bash
apt install -y nginx certbot python3-certbot-nginx
```

- [ ] Docker 설치 완료
- [ ] Docker Compose 설치 완료
- [ ] Nginx 설치 완료

---

## 13. Docker로 배포

### 13.1 코드 업로드

**방법 A: Git Clone (추천)**
```bash
mkdir -p /var/www
cd /var/www
git clone https://github.com/dyjung/logindemo-backend.git backend
cd backend
```

**방법 B: 직접 업로드 (로컬에서)**
```bash
# 로컬에서
cd /Users/doyoungchung/WorkSpace/iOS/LoginDemo
tar --exclude='backend/node_modules' \
    --exclude='backend/dist' \
    --exclude='backend/.env' \
    -czvf backend.tar.gz backend/

scp backend.tar.gz root@[VPS_IP]:/var/www/
```

```bash
# VPS에서
cd /var/www
tar -xzvf backend.tar.gz
cd backend
```

### 13.2 환경변수 파일 생성

```bash
nano /var/www/backend/.env
```

```env
# Supabase PostgreSQL
DATABASE_URL="postgresql://postgres.abcdefghijklmnop:MyStr0ngP@ssw0rd!@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.abcdefghijklmnop:MyStr0ngP@ssw0rd!@aws-0-ap-northeast-1.pooler.supabase.com:5432/postgres"

# Application
NODE_ENV=production
PORT=3000
```

### 13.3 Docker 이미지 빌드

```bash
cd /var/www/backend
docker build -t logindemo-api:latest .
```

빌드 확인:
```bash
docker images | grep logindemo
```

예시 출력:
```
logindemo-api   latest   abc123def456   10 seconds ago   250MB
```

### 13.4 Docker Compose로 실행

```bash
cd /var/www/backend
docker compose up -d
```

상태 확인:
```bash
docker compose ps
docker compose logs -f
```

### 13.5 컨테이너 테스트

```bash
curl http://localhost:3000
curl http://localhost:3000/health
```

예시 출력:
```json
{"status":"ok","timestamp":"2025-01-15T12:00:00.000Z"}
```

- [ ] Docker 이미지 빌드 완료
- [ ] Docker Compose 실행 완료
- [ ] Health check 테스트 성공

---

## 13.6 Nginx 설정 (Docker용)

```bash
nano /etc/nginx/sites-available/api
```

```nginx
server {
    listen 80;
    server_name api.logindemo.com;  # 또는 _ (IP만 사용 시)

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
}
```

```bash
ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
```

### 13.7 SSL 인증서 (도메인 있는 경우)

```bash
certbot --nginx -d api.logindemo.com
```

### 13.8 방화벽 설정

```bash
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable
```

- [ ] Nginx 설정 완료
- [ ] SSL 설정 완료 (도메인 있는 경우)
- [ ] 방화벽 설정 완료

---

## 14. Docker 관리

### 14.1 기본 명령어

```bash
# 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f api

# 컨테이너 재시작
docker compose restart api

# 컨테이너 중지
docker compose down

# 컨테이너 시작
docker compose up -d
```

### 14.2 코드 업데이트 시

```bash
cd /var/www/backend

# Git 사용 시
git pull origin main

# 이미지 재빌드 및 재시작
docker compose down
docker build -t logindemo-api:latest .
docker compose up -d

# 또는 한 줄로
docker compose up -d --build
```

### 14.3 배포 스크립트

```bash
nano /var/www/backend/deploy-docker.sh
```

```bash
#!/bin/bash
set -e

cd /var/www/backend

echo "1. Pulling latest code..."
git pull origin main

echo "2. Building Docker image..."
docker build -t logindemo-api:latest .

echo "3. Restarting container..."
docker compose down
docker compose up -d

echo "4. Waiting for health check..."
sleep 5

echo "5. Checking status..."
docker compose ps
curl -s http://localhost:3000/health

echo "Deployment completed!"
```

```bash
chmod +x /var/www/backend/deploy-docker.sh
```

실행:
```bash
/var/www/backend/deploy-docker.sh
```

### 14.4 이미지 버전 관리 (태깅)

```bash
# 버전 태그로 빌드
docker build -t logindemo-api:v1.0.0 .
docker build -t logindemo-api:v1.0.1 .

# 롤백 시
docker compose down
docker tag logindemo-api:v1.0.0 logindemo-api:latest
docker compose up -d
```

### 14.5 리소스 모니터링

```bash
# 컨테이너 리소스 사용량
docker stats

# 디스크 사용량
docker system df

# 미사용 이미지 정리
docker image prune -a
```

### 14.6 자동 시작 설정

Docker 서비스는 기본적으로 시스템 재부팅 시 자동 시작됩니다.
`docker-compose.yml`에 `restart: unless-stopped` 설정이 있으므로 컨테이너도 자동 시작됩니다.

확인:
```bash
systemctl is-enabled docker
# 출력: enabled
```

- [ ] 배포 스크립트 생성 완료
- [ ] 자동 시작 확인 완료

---

## Docker 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] Hostinger VPS 구매 및 SSH 접속
- [ ] Docker 및 Docker Compose 설치
- [ ] 백엔드 코드 업로드
- [ ] .env 환경변수 설정
- [ ] Docker 이미지 빌드
- [ ] Docker Compose 실행
- [ ] Nginx 리버스 프록시 설정
- [ ] SSL 인증서 (도메인 있는 경우)
- [ ] 방화벽 설정
- [ ] Health check 테스트 성공

---

## 문제 해결

### PM2가 실행되지 않음
```bash
pm2 logs logindemo-api --lines 50
```

### Nginx 502 Bad Gateway
```bash
# PM2 실행 확인
pm2 status

# 포트 확인
netstat -tlnp | grep 3000
```

### DB 연결 실패
```bash
# .env 파일 확인
cat /var/www/backend/.env

# Prisma 연결 테스트
cd /var/www/backend
npx prisma db pull
```

### SSL 인증서 갱신 실패
```bash
certbot renew --force-renewal
systemctl restart nginx
```

---

## Docker 문제 해결

### Docker 빌드 실패
```bash
# 빌드 로그 확인
docker build -t logindemo-api:latest . 2>&1 | tee build.log

# 캐시 없이 빌드
docker build --no-cache -t logindemo-api:latest .
```

### 컨테이너 시작 실패
```bash
# 로그 확인
docker compose logs api

# 컨테이너 내부 접속
docker compose exec api sh

# 환경변수 확인
docker compose exec api env
```

### DB 연결 실패 (Docker)
```bash
# 컨테이너 내부에서 DB 연결 테스트
docker compose exec api sh
npx prisma db pull

# .env 파일 확인
cat /var/www/backend/.env
```

### 포트 충돌
```bash
# 3000 포트 사용 중인 프로세스 확인
netstat -tlnp | grep 3000
lsof -i :3000

# PM2가 실행 중이면 중지
pm2 stop all
pm2 delete all
```

### 디스크 공간 부족
```bash
# Docker 리소스 정리
docker system prune -a --volumes

# 미사용 이미지 삭제
docker image prune -a
```

### 컨테이너 재시작 반복
```bash
# 상세 로그 확인
docker compose logs --tail=100 api

# Health check 비활성화 후 테스트
docker run --rm -it logindemo-api:latest sh
```
