# Hostinger VPS 배포 매뉴얼

> LoginDemo 프로젝트를 Hostinger VPS에 Docker로 배포하는 전체 과정

---

## 목차

1. [VPS 초기 설정](#1-vps-초기-설정)
2. [Docker 설치](#2-docker-설치)
3. [프로젝트 배포](#3-프로젝트-배포)
4. [Nginx 리버스 프록시 설정](#4-nginx-리버스-프록시-설정)
5. [도메인 연결](#5-도메인-연결)
6. [SSL 인증서 설정](#6-ssl-인증서-설정-lets-encrypt)
7. [유지보수](#7-유지보수)

---

## 1. VPS 초기 설정

### 1.1 Hostinger VPS 구매
- Hostinger에서 VPS 플랜 선택 및 구매
- OS: Ubuntu 24.04 LTS 선택

### 1.2 SSH 접속
```bash
# root 계정으로 최초 접속
ssh root@<VPS_IP>

# 예시
ssh root@72.62.245.151
```

### 1.3 일반 사용자 계정 생성 (권장)
```bash
# 새 사용자 생성
adduser dyjung

# sudo 권한 부여
usermod -aG sudo dyjung

# SSH 키 복사 (선택)
mkdir -p /home/dyjung/.ssh
cp ~/.ssh/authorized_keys /home/dyjung/.ssh/
chown -R dyjung:dyjung /home/dyjung/.ssh
chmod 700 /home/dyjung/.ssh
chmod 600 /home/dyjung/.ssh/authorized_keys
```

### 1.4 기본 패키지 업데이트
```bash
sudo apt update
sudo apt upgrade -y
```

### 1.5 방화벽 설정
```bash
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
sudo ufw status
```

---

## 2. Docker 설치

### 2.1 기존 Docker 제거 (있는 경우)
```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

### 2.2 Docker 설치
```bash
# 필수 패키지 설치
sudo apt install -y ca-certificates curl gnupg lsb-release

# Docker GPG 키 추가
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker 저장소 추가
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Docker 서비스 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가 (sudo 없이 docker 사용)
sudo usermod -aG docker $USER

# 설치 확인
docker --version
docker compose version
```

### 2.3 Docker 설치 확인
```bash
# 테스트 컨테이너 실행
sudo docker run hello-world
```

---

## 3. 프로젝트 배포

### 3.1 프로젝트 디렉토리 생성
```bash
sudo mkdir -p /var/www/logindemo
sudo chown -R $USER:$USER /var/www/logindemo
cd /var/www/logindemo
```

### 3.2 Git 저장소 클론
```bash
git clone https://github.com/dyjung/logindemo.git .

# 또는 특정 브랜치
git clone -b main https://github.com/dyjung/logindemo.git .
```

### 3.3 환경 변수 설정
```bash
# .env 파일 생성
cat > .env << 'EOF'
DATABASE_URL="postgresql://user:password@host:6543/database?pgbouncer=true"
DIRECT_URL="postgresql://user:password@host:5432/database"
EOF

# 권한 설정 (보안)
chmod 600 .env
```

### 3.4 Docker Compose로 빌드 및 실행
```bash
# 빌드 및 실행
sudo docker compose up -d --build

# 상태 확인
sudo docker compose ps

# 로그 확인
sudo docker compose logs -f
sudo docker compose logs backend --tail=50
sudo docker compose logs frontend --tail=50
```

### 3.5 동작 확인
```bash
# Backend API 확인
curl http://localhost:3000/v1/init

# Frontend 확인
curl http://localhost:3001
```

---

## 4. Nginx 리버스 프록시 설정

### 4.1 nginx.conf 구성

프로젝트에 포함된 `nginx.conf` 파일:

```nginx
# HTTP 서버 (HTTPS 리다이렉트 전)
server {
    listen 80;
    server_name _;

    # Frontend
    location / {
        proxy_pass http://logindemo-frontend:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Backend API
    location /v1 {
        proxy_pass http://logindemo-backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4.2 docker-compose.yml에 Nginx 포함

```yaml
services:
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
    depends_on:
      - frontend
      - backend
    networks:
      - app-network
```

---

## 5. 도메인 연결

### 5.1 Hostinger DNS 설정

Hostinger 대시보드 → 도메인 → DNS 관리에서:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 72.62.245.151 | 14400 |
| A | www | 72.62.245.151 | 14400 |

### 5.2 DNS 전파 확인
```bash
# DNS 확인 (서버 또는 로컬에서)
dig dyjung.com +short
nslookup dyjung.com

# 결과: 72.62.245.151
```

### 5.3 nginx.conf에 도메인 설정
```nginx
server {
    listen 80;
    server_name dyjung.com www.dyjung.com;
    # ...
}
```

---

## 6. SSL 인증서 설정 (Let's Encrypt)

### 6.1 Certbot 설치
```bash
sudo apt update
sudo apt install certbot -y
```

### 6.2 인증서 발급

```bash
# Docker 컨테이너 중지 (포트 80 해제)
cd /var/www/logindemo
sudo docker compose down

# SSL 인증서 발급 (standalone 모드)
sudo certbot certonly --standalone -d dyjung.com -d www.dyjung.com

# 이메일 입력, 약관 동의 진행
```

인증서 저장 위치:
- 인증서: `/etc/letsencrypt/live/dyjung.com/fullchain.pem`
- 개인키: `/etc/letsencrypt/live/dyjung.com/privkey.pem`

### 6.3 nginx.conf HTTPS 설정

```nginx
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
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # Frontend
    location / {
        proxy_pass http://logindemo-frontend:3000;
        # ... proxy headers
    }

    # Backend API
    location /v1 {
        proxy_pass http://logindemo-backend:3000;
        # ... proxy headers
    }
}
```

### 6.4 docker-compose.yml 업데이트

```yaml
nginx:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    - /etc/letsencrypt:/etc/letsencrypt:ro
    - /var/www/certbot:/var/www/certbot:ro
```

### 6.5 배포 및 확인
```bash
# 방화벽에 443 포트 추가
sudo ufw allow 443

# Docker 재시작
sudo docker compose up -d --build

# 확인
curl -I https://www.dyjung.com
```

### 6.6 인증서 자동 갱신 확인
```bash
# 갱신 테스트 (실제 갱신 안함)
sudo certbot renew --dry-run

# Certbot이 자동으로 cron/systemd timer 설정함
sudo systemctl list-timers | grep certbot
```

---

## 7. 유지보수

### 7.1 코드 업데이트 배포
```bash
cd /var/www/logindemo

# 최신 코드 가져오기
sudo git pull

# 컨테이너 재빌드 및 재시작
sudo docker compose down
sudo docker compose up -d --build

# 또는 특정 서비스만
sudo docker compose up -d --build frontend
```

### 7.2 로그 확인
```bash
# 모든 서비스 로그
sudo docker compose logs -f

# 특정 서비스 로그
sudo docker compose logs backend --tail=100
sudo docker compose logs frontend --tail=100
sudo docker compose logs nginx --tail=100
```

### 7.3 컨테이너 상태 확인
```bash
sudo docker compose ps
sudo docker ps -a
```

### 7.4 디스크 정리
```bash
# 사용하지 않는 Docker 리소스 정리
sudo docker system prune -a

# 특정 이미지만 삭제
sudo docker image prune
```

### 7.5 서버 재시작 후 자동 시작
Docker 서비스와 컨테이너는 자동으로 시작됨:
- Docker: `systemctl enable docker`
- 컨테이너: `restart: unless-stopped` 설정

### 7.6 백업
```bash
# .env 파일 백업 (중요!)
cp /var/www/logindemo/.env ~/backup/

# 데이터베이스는 Supabase에서 관리
```

---

## 문제 해결

### Healthcheck 실패
```bash
# Backend healthcheck 확인
curl http://localhost:3000/v1/init

# Frontend healthcheck 확인
curl http://localhost:3001/api/health
```

### Git pull 권한 문제
```bash
sudo git config --global --add safe.directory /var/www/logindemo
sudo git pull
```

### 포트 충돌
```bash
# 포트 사용 확인
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :3000
```

### SSL 인증서 갱신
```bash
# 수동 갱신 (필요시)
sudo docker compose down
sudo certbot renew
sudo docker compose up -d
```

---

## 접속 URL

| 서비스 | URL |
|--------|-----|
| Frontend | https://www.dyjung.com |
| Backend API | https://www.dyjung.com/v1/init |
| Swagger Docs | https://www.dyjung.com/api-docs |

---

## 서버 정보

- **VPS IP**: 72.62.245.151
- **SSH**: `ssh dyjung@72.62.245.151`
- **프로젝트 경로**: `/var/www/logindemo`
- **도메인**: dyjung.com, www.dyjung.com
- **SSL 만료일**: 2026-04-17 (자동 갱신)

---

## 연락처

- **긴급연락처**: 양부장 010-2623-5585
