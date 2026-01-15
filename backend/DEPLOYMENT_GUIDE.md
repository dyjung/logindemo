# NestJS Backend 배포 가이드

Hostinger VPS + Supabase PostgreSQL + Docker 배포 매뉴얼

---

## 개요

| 항목 | 내용 |
|------|------|
| Backend | NestJS + Prisma |
| Database | Supabase PostgreSQL |
| Server | Hostinger VPS (Ubuntu) |
| Container | Docker + Docker Compose |
| Reverse Proxy | Nginx |

### 아키텍처

```
┌─────────────┐     HTTPS      ┌─────────────────────────────────┐
│   Mobile    │ ────────────── │         Hostinger VPS           │
│   App       │                │  ┌───────────┐  ┌────────────┐  │
└─────────────┘                │  │   Nginx   │──│  Docker    │  │
                               │  │  (Host)   │  │ Container  │  │
                               │  └───────────┘  │ (NestJS)   │  │
                               │       :80       └─────:3000──┘  │
                               └────────────────────────┬────────┘
                                                        │
                                               ┌────────▼────────┐
                                               │    Supabase     │
                                               │   PostgreSQL    │
                                               └─────────────────┘
```

---

## Step 1: Supabase 설정

### 1.1 프로젝트 생성

1. [supabase.com](https://supabase.com) 접속
2. GitHub 계정으로 로그인
3. **New Project** 클릭
4. 설정 입력:
   - **Project name**: `logindemo`
   - **Database Password**: 강력한 비밀번호 (메모 필수!)
   - **Region**: 가까운 리전 선택
5. **Create new project** 클릭 (2-3분 대기)

### 1.2 연결 문자열 확인

1. **Project Settings** (톱니바퀴) → **Database** 탭
2. **Connection string** 섹션에서:

| 설정 | 값 |
|------|-----|
| Type | Transaction |
| Source | Supavisor |
| Method | URI |

3. 연결 문자열 복사 (2개 필요):

**Transaction mode (포트 6543)** - 일반 쿼리용:
```
postgresql://postgres.[PROJECT_REF]:[PASSWORD]@[REGION].pooler.supabase.com:6543/postgres
```

**Session mode (포트 5432)** - 마이그레이션용:
```
postgresql://postgres.[PROJECT_REF]:[PASSWORD]@[REGION].pooler.supabase.com:5432/postgres
```

### 1.3 비밀번호 URL 인코딩

비밀번호에 특수문자가 있으면 URL 인코딩 필요:

| 문자 | 인코딩 |
|------|--------|
| `!` | `%21` |
| `@` | `%40` |
| `#` | `%23` |
| `$` | `%24` |
| `%` | `%25` |

예시: `MyP@ss!` → `MyP%40ss%21`

### 1.4 로컬에서 연결 테스트

```bash
cd backend

# .env 파일 수정
DATABASE_URL="postgresql://postgres.[PROJECT_REF]:[ENCODED_PASSWORD]@[REGION].pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.[PROJECT_REF]:[ENCODED_PASSWORD]@[REGION].pooler.supabase.com:5432/postgres"

# 연결 테스트 및 테이블 생성
npx prisma db push
```

성공 시:
```
🚀 Your database is now in sync with your Prisma schema.
```

---

## Step 2: GitHub 저장소 설정

### 2.1 저장소 생성

1. [github.com/new](https://github.com/new) 접속
2. 설정:
   - **Repository name**: `logindemo-backend`
   - **Public** 선택 (VPS에서 인증 없이 clone 가능)
3. **Create repository** 클릭

### 2.2 코드 Push

```bash
cd backend
git init
git add .
git commit -m "Initial backend setup with Docker"
git branch -M main
git remote add origin https://github.com/[USERNAME]/logindemo-backend.git
git push -u origin main
```

### 2.3 인증 (Private 저장소인 경우)

Personal Access Token 필요:

1. [github.com/settings/tokens](https://github.com/settings/tokens) 접속
2. **Generate new token (classic)** 클릭
3. 설정:
   - **Note**: `vps-deploy`
   - **Expiration**: 90 days
   - **Scopes**: `repo` 체크
4. **Generate token** → 토큰 복사

Push 시 비밀번호 대신 토큰 입력

---

## Step 3: Hostinger VPS 준비

### 3.1 VPS 구매

1. [hostinger.com/vps-hosting](https://www.hostinger.com/vps-hosting) 접속
2. 플랜 선택 (KVM 1 권장)
3. OS: **Ubuntu 22.04 LTS**
4. 데이터센터: 가까운 위치

### 3.2 SSH 접속

```bash
ssh [USERNAME]@[VPS_IP]
```

예시:
```bash
ssh dyjung@72.62.245.151
```

### 3.3 Docker 설치 확인

```bash
docker --version
docker compose version
```

설치 안 되어 있으면:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
```

---

## Step 4: 코드 배포

### 4.1 코드 Clone

```bash
sudo mkdir -p /var/www
sudo chown $USER:$USER /var/www
cd /var/www
git clone https://github.com/[USERNAME]/logindemo-backend.git backend
cd backend
```

### 4.2 환경변수 설정

```bash
nano .env
```

내용 입력:
```env
DATABASE_URL=postgresql://postgres.[PROJECT_REF]:[ENCODED_PASSWORD]@[REGION].pooler.supabase.com:6543/postgres?pgbouncer=true
DIRECT_URL=postgresql://postgres.[PROJECT_REF]:[ENCODED_PASSWORD]@[REGION].pooler.supabase.com:5432/postgres
NODE_ENV=production
PORT=3000
```

저장: `Ctrl + X` → `Y` → `Enter`

### 4.3 Docker 빌드

```bash
sudo docker build -t logindemo-api:latest .
```

빌드 시간: 약 2-3분

### 4.4 Docker 실행

```bash
sudo docker compose up -d
```

### 4.5 상태 확인

```bash
sudo docker compose ps
```

정상 출력:
```
NAME            IMAGE         STATUS                    PORTS
logindemo-api   backend-api   Up X seconds (healthy)    0.0.0.0:3000->3000/tcp
```

### 4.6 로그 확인 (문제 발생 시)

```bash
sudo docker compose logs api
```

---

## Step 5: Nginx 설정

### 5.1 Nginx 설치

```bash
sudo apt install -y nginx
```

### 5.2 설정 파일 생성

```bash
sudo nano /etc/nginx/sites-available/api
```

내용:
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
    }
}
```

### 5.3 설정 활성화

```bash
sudo ln -sf /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
```

---

## Step 6: 방화벽 설정

```bash
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw --force enable
sudo ufw status
```

---

## Step 7: 테스트

### API 테스트

```bash
# 내부 테스트
curl http://localhost:3000/health

# 외부 테스트 (다른 터미널에서)
curl http://[VPS_IP]/health
```

정상 응답:
```json
{"status":"ok","timestamp":"2025-01-16T12:00:00.000Z"}
```

### Swagger 문서

브라우저에서: `http://[VPS_IP]/api`

---

## Step 8: SSL 인증서 (선택)

도메인이 있는 경우:

### 8.1 DNS 설정

도메인 관리자에서 A 레코드 추가:
```
api.example.com → [VPS_IP]
```

### 8.2 Nginx 설정 수정

```bash
sudo nano /etc/nginx/sites-available/api
```

`server_name _;` → `server_name api.example.com;`

### 8.3 SSL 발급

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.example.com
```

---

## 배포 후 관리

### 코드 업데이트

```bash
cd /var/www/backend
git pull
sudo docker compose down
sudo docker build -t logindemo-api:latest .
sudo docker compose up -d
```

### 유용한 명령어

| 명령어 | 설명 |
|--------|------|
| `sudo docker compose ps` | 컨테이너 상태 확인 |
| `sudo docker compose logs -f api` | 실시간 로그 |
| `sudo docker compose restart api` | 재시작 |
| `sudo docker compose down` | 중지 |
| `sudo docker compose up -d` | 시작 |
| `sudo docker stats` | 리소스 사용량 |

### 배포 자동화 스크립트

```bash
nano ~/deploy.sh
```

```bash
#!/bin/bash
cd /var/www/backend
git pull
sudo docker compose down
sudo docker build -t logindemo-api:latest .
sudo docker compose up -d
echo "Deployment completed!"
sudo docker compose ps
```

```bash
chmod +x ~/deploy.sh
```

실행:
```bash
~/deploy.sh
```

---

## 문제 해결

### 컨테이너 재시작 반복

```bash
sudo docker compose logs api
```

일반적인 원인:
- `.env` 파일 오류 (특수문자 인코딩)
- DB 연결 실패 (잘못된 연결 문자열)
- Prisma 마이그레이션 오류

### DB 연결 실패

`.env` 파일 확인:
```bash
cat .env
```

비밀번호 특수문자 URL 인코딩 확인

### Nginx 502 Bad Gateway

```bash
# Docker 컨테이너 실행 중인지 확인
sudo docker compose ps

# 포트 확인
sudo netstat -tlnp | grep 3000
```

### 권한 오류

```bash
# Docker 명령어에 sudo 사용
sudo docker compose up -d
```

---

## 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] 연결 문자열 복사 (Transaction, Session)
- [ ] 로컬에서 DB 연결 테스트 (`npx prisma db push`)
- [ ] GitHub 저장소 생성 및 Push
- [ ] VPS SSH 접속
- [ ] Docker 설치 확인
- [ ] 코드 Clone
- [ ] `.env` 파일 생성
- [ ] Docker 빌드 및 실행
- [ ] Nginx 설정
- [ ] 방화벽 설정
- [ ] API 테스트 (`/health`)
- [ ] SSL 인증서 (선택)

---

## 참고 정보

| 항목 | 값 |
|------|-----|
| VPS IP | `72.62.245.151` |
| API URL | `http://72.62.245.151` |
| Health Check | `http://72.62.245.151/health` |
| Swagger | `http://72.62.245.151/api` |
| GitHub | `https://github.com/dyjung/logindemo-backend` |
| Supabase Region | `aws-1-ap-south-1` |
