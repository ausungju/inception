# Inception 사용자 가이드

## 제공 서비스

| 서비스 | 설명 | 역할 |
|--------|------|------|
| **NGINX** | 웹 서버 | • HTTPS 프로토콜을 통한 안전한 웹 접근<br>• TLSv1.2/TLSv1.3 암호화 지원<br>• 정적 파일 서빙 및 리버스 프록시 |
| **WordPress** | 콘텐츠 관리 시스템 (CMS) | • 블로그 및 웹사이트 관리<br>• 사용자 친화적인 관리 인터페이스<br>• PHP-FPM으로 동적 콘텐츠 생성 |
| **MariaDB** | 데이터베이스 | • WordPress 데이터 저장<br>• 사용자, 게시물, 설정 정보 관리<br>• 안전한 데이터 영속성 보장 |

모든 서비스는 독립적인 Docker 컨테이너로 실행되며, 격리된 네트워크 환경에서 안전하게 통신합니다.

---

## 프로젝트 시작 및 중지

### 시작하기

프로젝트를 처음 시작하는 경우:

```bash
# 프로젝트 디렉토리로 이동
cd /home/seongkim/work/inception

# 모든 서비스 빌드 및 시작
make
# or
docker-compose -f src/docker-compose.yml up --build -d
```

### 중지하기

서비스를 중지하지만 데이터를 유지하는 경우:

```bash
make down
# or
docker-compose -f src/docker-compose.yml down
```

### 완전히 삭제하기

**주의**: 이 명령은 모든 데이터를 삭제합니다!

```bash
# 볼륨까지 삭제 (데이터 손실)
make clean

# 모든 리소스 삭제 (이미지, 볼륨, 네트워크)
make fclean
```

### 재시작하기

```bash
# 서비스 재시작
make restart
# or
docker-compose -f src/docker-compose.yml restart
```

---

## 웹사이트 및 관리자 패널 접근

### 웹사이트 접근

서비스가 시작된 후 브라우저에서 다음 주소로 접속할 수 있습니다:

**메인 웹사이트**: `https://seongkim.42.fr`

> **참고**: 자체 서명 인증서를 사용하므로 브라우저에서 보안 경고가 표시될 수 있습니다.

### WordPress 관리자 패널 접근

**관리자 대시보드**: `https://seongkim.42.fr/wp-admin`

#### 관리자 로그인 정보

- **사용자명**: 설정한 WordPress 관리자 계정
- **비밀번호**: `secrets/wp_admin_password.txt` 파일에 저장된 비밀번호

---

## 인증 정보 관리

### 인증 정보 파일 위치

모든 민감한 인증 정보는 `secrets/` 디렉토리에 텍스트 파일로 저장됩니다:

```
secrets/
├── mariadb_root_password.txt      # MariaDB root 비밀번호
├── mariadb_user_pwd.txt           # MariaDB 사용자 비밀번호
├── wp_admin_password.txt          # WordPress 관리자 비밀번호
└── wp_user_password.txt           # WordPress 일반 사용자 비밀번호
```

만약 파일이 없다면 임의의 값으로 파일이 생성됩니다.

### 인증 정보 확인

```bash
# MariaDB root 비밀번호 확인
cat secrets/mariadb_root_password.txt

# WordPress 관리자 비밀번호 확인
cat secrets/wp_admin_password.txt
```

### 인증 정보 변경

**중요**: 인증 정보를 변경하려면 다음 단계를 따르세요:

```bash
# 1. **서비스 중지**:
make down

# 2. **비밀번호 파일 수정**: 새 비밀번호 입력 후 저장
nano secrets/wp_admin_password.txt 

# 3. **데이터 초기화 (필요한 경우)**:
make clean

# 4. **서비스 재시작**:
make
```

---

## 서비스 상태 확인

### 컨테이너 상태 확인

모든 컨테이너가 실행 중인지 확인:

```bash
make status
# or
docker-compose -f src/docker-compose.yml ps
```

**정상 출력 예시**:
```
┌───────────────────────────────────────────────────────────────────────────────┐
│                             Inception Services                                │
├───────────────┬───────────────────────┬───────────────────────┬───────────────┤
│    Service    │         Name          │        Image          │     PID 1     │
├───────────────┼───────────────────────┼───────────────────────┼───────────────┤
│ nginx         │ nginx_container       │ nginx:latest          │ nginx         │
│ mariadb       │ mariadb_container     │ mariadb:latest        │ mariadbd      │
│ wordpress     │ wordpress_container   │ wordpress:latest      │ php-fpm8.2    │
└───────────────┴───────────────────────┴───────────────────────┴───────────────┘
```
```
NAME                  IMAGE              COMMAND                  SERVICE     CREATED          STATUS                    PORTS
mariadb_container     mariadb:latest     "/usr/local/bin/init…"   mariadb     43 seconds ago   Up 43 seconds (healthy)
nginx_container       nginx:latest       "nginx -g 'daemon of…"   nginx       43 seconds ago   Up 31 seconds             0.0.0.0:443->443/tcp, [::]:443->443/tcp
wordpress_container   wordpress:latest   "/entrypoint.sh"         wordpress   43 seconds ago   Up 37 seconds (healthy)
```

### 서비스 로그 확인

```bash
make log
# or

# 모든 서비스 로그
docker-compose -f src/docker-compose.yml logs

# 특정 서비스 로그 (실시간)
docker-compose -f src/docker-compose.yml logs -f nginx
docker-compose -f src/docker-compose.yml logs -f wordpress
docker-compose -f src/docker-compose.yml logs -f mariadb
```

### 볼륨 및 데이터 확인

```bash
# 볼륨 목록 확인
docker volume ls

# WordPress 데이터 확인
ls -la /home/seongkim/data/wordpress/

# MariaDB 데이터 확인
ls -la /home/seongkim/data/mariadb/
```

### 네트워크 확인

```bash
# Docker 네트워크 목록
docker network ls

# 네트워크 상세 정보
docker network inspect inception
```
