# LoginDemo 배포 작업 TODO

> 작성일: 2026-01-16
> 최종 수정: 2026-01-17
> 목적: Hostinger VPS 배포 및 설정 작업 이력/계획

---

## 서버 정보

- **IP**: 72.62.245.151
- **SSH**: `ssh root@72.62.245.151` 또는 `ssh dyjung@72.62.245.151`
- **경로**: `/var/www/logindemo`
- **DB**: Supabase PostgreSQL (aws-1-ap-south-1)

---

## 완료된 작업

### 1. 서버 정리
- [x] `/var/www/logindemo`에서 불필요한 `android`, `ios` 폴더 삭제

### 2. 환경 변수 설정
- [x] `.env` 파일 생성 완료
```
DATABASE_URL="postgresql://postgres.drkfrsdrsxxstriyywsg:dyJung337%21%40%23@aws-1-ap-south-1.pooler.supabase.com:6543/postgres?pgbouncer=true"
DIRECT_URL="postgresql://postgres.drkfrsdrsxxstriyywsg:dyJung337%21%40%23@aws-1-ap-south-1.pooler.supabase.com:5432/postgres"
```

### 3. Docker 컨테이너 실행
- [x] Backend (NestJS) 실행 중 - 포트 3000
- [x] Frontend (Next.js) 실행 중 - 포트 3001
- [x] Backend API 동작 확인: `curl http://localhost:3000/v1/init` 정상

### 4. iOS 설정
- [x] `ios/LoginDemo/Core/Network/APIConstants.swift` - baseURL을 `http://72.62.245.151:3000/v1`로 변경
- [x] `ios/LoginDemo/Info.plist` 생성 - ATS 예외 추가 (HTTP 허용)

### 5. Frontend 수정
- [x] `frontend/src/app/page.tsx` - 양부장 긴급연락처 추가 (010-2623-5585)

### 6. Healthcheck 문제 해결 (2026-01-17)
- [x] `docker-compose.yml` healthcheck 엔드포인트 변경: `/health` → `/v1/init`

### 7. Nginx 설정 추가 (2026-01-17)
- [x] `docker-compose.yml`에 nginx 서비스 추가
- [x] `nginx.conf` Docker 네트워크용으로 수정 (127.0.0.1 → 컨테이너 이름)

---

## 서버에 배포하기

### 방법 1: Git을 통한 배포 (권장)

```bash
# 1. 로컬에서 변경사항 커밋 & 푸시
git add docker-compose.yml nginx.conf
git commit -m "Fix healthcheck endpoint and add nginx service"
git push

# 2. 서버 접속
ssh dyjung@72.62.245.151

# 3. 서버에서 최신 코드 가져오기
cd /var/www/logindemo
git pull

# 4. 컨테이너 재시작 (Nginx 포함)
sudo docker compose down
sudo docker compose up -d --build

# 5. 포트 80 방화벽 열기 (최초 1회)
sudo ufw allow 80
```

### 방법 2: 파일 직접 복사

```bash
# 로컬에서 서버로 파일 복사
scp docker-compose.yml dyjung@72.62.245.151:/var/www/logindemo/
scp nginx.conf dyjung@72.62.245.151:/var/www/logindemo/

# 서버에서 재시작
ssh dyjung@72.62.245.151
cd /var/www/logindemo
sudo docker compose down
sudo docker compose up -d
sudo ufw allow 80
```

---

## 배포 후 확인사항

```bash
# 컨테이너 상태 확인 (모두 healthy여야 함)
sudo docker compose ps

# 각 서비스 테스트
curl http://localhost:3000/v1/init     # Backend (직접)
curl http://localhost:80/v1/init       # Backend (Nginx 통해)
curl http://localhost:80               # Frontend (Nginx 통해)

# 외부에서 접속 테스트
curl http://72.62.245.151/v1/init      # Backend API
curl http://72.62.245.151              # Frontend
```

---

## 접속 URL

| 서비스 | 이전 (포트 필요) | 현재 (Nginx) |
|--------|------------------|--------------|
| Frontend | http://72.62.245.151:3001 | http://72.62.245.151 |
| Backend API | http://72.62.245.151:3000/v1/init | http://72.62.245.151/v1/init |

---

## iOS 빌드 테스트

Nginx 배포 후 iOS에서 API URL 업데이트가 필요할 수 있음:

**현재 설정** (`APIConstants.swift`):
```swift
static let baseURL = "http://72.62.245.151:3000/v1"
```

**Nginx 배포 후 (선택적)**:
```swift
static let baseURL = "http://72.62.245.151/v1"  // 포트 제거 가능
```

테스트 순서:
1. Xcode에서 Clean Build (Cmd + Shift + K)
2. 시뮬레이터 또는 실제 기기에서 빌드
3. 로그인/회원가입 API 연결 확인

---

## 명령어 요약

```bash
# 서버 접속
ssh dyjung@72.62.245.151

# 작업 디렉토리 이동
cd /var/www/logindemo

# 컨테이너 상태 확인
sudo docker compose ps

# 로그 확인
sudo docker compose logs backend --tail=50
sudo docker compose logs frontend --tail=50
sudo docker compose logs nginx --tail=50

# 재시작
sudo docker compose down
sudo docker compose up -d

# 강제 재빌드
sudo docker compose up -d --build
```

---

## 참고

- Supabase 비밀번호: `dyJung337!@#` (URL 인코딩: `dyJung337%21%40%23`)
- Docker Compose v2 사용 (`docker compose`, 하이픈 없음)
- Frontend 의존성 우회: `sudo docker compose up -d --no-deps frontend`
