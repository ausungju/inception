# Inception 개발자 문서

이 문서는 개발자가 프로젝트를 처음부터 설정하고, 빌드하고, 관리하는 방법을 설명합니다.

---

## 1. 처음부터 환경 설정하기

### 전제 조건

프로젝트를 시작하기 전에 다음 소프트웨어가 설치되어 있어야 합니다:

#### 필수 패키지

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 도구 설치
sudo apt install -y \
    build-essential \
    git \
    docker-compose-v2 \
    openssl \
```

#### Docker 설정

```bash
# Docker 서비스 시작
sudo systemctl enable docker
sudo systemctl start docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 변경사항 적용 (재로그인 필요)
newgrp docker

# Docker 버전 확인
docker --version
docker compose version
```

**요구사항**:
- Docker: 20.10.0 이상
- Docker Compose: v2.0.0 이상

### 초기 설정

#### 1. 저장소 클론

```bash
git clone https://github.com/ausungju/inception.git
cd inception
```

#### 2. 디렉토리 구조 확인

```bash
tree -L 3
```

예상 출력:
```
.
├── secrets
│   ├── mariadb_root_password.txt
│   ├── mariadb_user_pwd.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
├── src
│   ├── requirements
│   │   ├── mariadb
│   │   ├── nginx
│   │   └── wordpress
│   └── docker-compose.yml
├── Makefile
├── DEV_DOC.md
├── USER_DOC.md
└── README.md
```

#### 3. 환경 변수 설정

[src/.env](src/.env) 파일을 프로젝트에 맞게 수정:

```bash
vim src/.env
```

**설정 항목**:

```env
# MariaDB 설정
MARIADB_DATABASE_NAME=wpdb          # 데이터베이스 이름
MARIADB_USER_NAME=seongkim          # 데이터베이스 사용자

# WordPress 관리자 설정
WP_ADMIN_USER=seongkim              # 관리자 사용자명
WP_ADMIN_EMAIL=seongkim@student.42gyeongsan.kr
WP_SITE_URL=localhost               # 사이트 URL
WP_SITE_TITLE=inception             # 사이트 제목

# WordPress 일반 사용자 설정
WP_USER_NAME=joo                    # 일반 사용자명
WP_USER_EMAIL=ausungju@naver.com	# 일반 사용자 이메일
```

#### 4. 시크릿 생성

시크릿 파일은 Makefile이 자동으로 생성하지만, 수동으로 생성할 수도 있습니다:

```bash
# secrets 디렉토리 생성
mkdir -p secrets

# 안전한 랜덤 비밀번호 생성
openssl rand -base64 32 > secrets/mariadb_root_password.txt
openssl rand -base64 32 > secrets/mariadb_user_pwd.txt
openssl rand -base64 32 > secrets/wp_admin_password.txt
openssl rand -base64 32 > secrets/wp_user_password.txt
```

#### 5. Hosts 파일 설정

로컬에서 도메인 이름으로 접근하기 위해 `/etc/hosts` 파일에 추가:

```bash
# 자동 추가 (Makefile 사용)
make hosts

# 또는 수동 추가
echo "127.0.0.1 seongkim.42.fr" | sudo tee -a /etc/hosts
```

---

## 2. Makefile과 Docker Compose를 사용하여 프로젝트 빌드하고 실행하기

### Makefile 사용법

#### 기본 명령어

```bash
# 전체 빌드 및 실행 (기본)
make
# 빌드만 수행
make build
# 서비스 시작
make up
# 서비스 중지
make down
# 서비스 재시작
make restart
```

#### 데이터 관리

```bash
# 서비스 중지 및 데이터 삭제
make clean
# 완전한 정리 (이미지, 볼륨, 시크릿 포함)
make fclean
# 시크릿 파일 삭제
make remove-secrets
```

#### 모니터링

```bash
# 로그 확인 (실시간, 최근 100줄)
make log
# 서비스 상태 확인
make status
```

#### 유틸리티

```bash
# 시크릿 생성
make secrets
# Hosts 파일에 도메인 추가
make hosts
# 데이터 디렉토리 생성
make mkdir
```
### Docker Compose 기본 명령어

#### 서비스 시작

```bash
# 백그라운드에서 시작
docker compose -f src/docker-compose.yml up -d
# 로그 출력하며 시작
docker compose -f src/docker-compose.yml up
# 특정 서비스만 시작
docker compose -f src/docker-compose.yml up -d nginx
```

#### 서비스 중지

```bash
# 컨테이너 중지 및 삭제
docker compose -f src/docker-compose.yml down
# 볼륨까지 삭제
docker compose -f src/docker-compose.yml down -v
# 즉시 중지 (타임아웃 0)
docker compose -f src/docker-compose.yml down -t 0
```

#### 서비스 재시작

```bash
# 모든 서비스 재시작
docker compose -f src/docker-compose.yml restart
# 특정 서비스만 재시작
docker compose -f src/docker-compose.yml restart wordpress
```

#### 빌드

```bash
# 이미지 빌드
docker compose -f src/docker-compose.yml build
# 캐시 없이 빌드
docker compose -f src/docker-compose.yml build --no-cache
# 특정 서비스만 빌드
docker compose -f src/docker-compose.yml build nginx
```

---

## 3. 컨테이너와 볼륨 관리 명령어

### 컨테이너 조작

#### 컨테이너 접속

```bash
# bash 셸로 접속
docker exec -it nginx_container bash
docker exec -it wordpress_container bash
docker exec -it mariadb_container bash
# 특정 명령어 실행
docker exec nginx_container nginx -t
docker exec mariadb_container mysql -u root -p
```

#### 로그 확인

```bash
# 전체 로그
docker compose -f src/docker-compose.yml logs
# 특정 서비스 로그
docker compose -f src/docker-compose.yml logs nginx
# 실시간 로그 (최근 100줄)
docker compose -f src/docker-compose.yml logs -f --tail=100
# 타임스탬프 포함
docker compose -f src/docker-compose.yml logs -t
```

#### 상태 확인

```bash
# 컨테이너 목록
docker compose -f src/docker-compose.yml ps
# 상세 정보
docker compose -f src/docker-compose.yml ps -a
# 리소스 사용량
docker stats
```

### 볼륨 관리 명령어

```bash
# Docker 볼륨 목록
docker volume ls
# 특정 볼륨 상세 정보
docker volume inspect src_wordpress_data
docker volume inspect src_mariadb_data
```

#### 볼륨 정리

```bash
# 사용하지 않는 볼륨 삭제
docker volume prune
# 특정 볼륨 삭제 (주의!)
docker volume rm src_wordpress_data
docker volume rm src_mariadb_data
```

---

## 4. 프로젝트 데이터 저장 위치와 지속성

### 데이터 저장 위치

#### WordPress 데이터

**호스트 경로**: `./src/requirements/wordpress/src/`  
**컨테이너 경로**: `/var/www/html`

**포함 내용**:
- WordPress 코어 파일
- 테마 및 플러그인
- 업로드된 미디어 파일
- wp-config.php 설정 파일

```bash
# 확인
ls -la src/requirements/wordpress/src/
```

#### MariaDB 데이터

**호스트 경로**: `./src/requirements/mariadb/data/`  
**컨테이너 경로**: `/var/lib/mysql`

**포함 내용**:
- 데이터베이스 파일 (.ibd, .frm)
- InnoDB 로그 파일
- 시스템 테이블

```bash
# 확인
sudo ls -la src/requirements/mariadb/data/
```

### 데이터 지속성 메커니즘

#### Bind Mount 방식

**장점**:
- 호스트에서 직접 파일 접근 가능
- 개발 중 실시간 수정 가능
- 백업 및 관리 용이

**동작 방식**:
1. 호스트의 디렉토리를 컨테이너에 마운트
2. 컨테이너 내부에서 수정한 내용이 호스트에 즉시 반영
3. 컨테이너 삭제 후에도 데이터 유지
