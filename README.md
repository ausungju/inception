*This project has been created as part of the 42 curriculum by seongkim*

# Description

이 프로젝트는 Docker를 활용하여 시스템 관리를 학습하는 것을 목표로 합니다. Docker Compose를 사용하여 NGINX, WordPress, MariaDB로 구성된 완전한 웹 서비스 인프라를 구축합니다.

## Project Overview

이 프로젝트는 다음과 같은 구성 요소로 이루어져 있습니다:

- **NGINX**: TLSv1.2/TLSv1.3를 사용하는 웹 서버 (443 포트)
- **WordPress + PHP-FPM**: 동적 콘텐츠 관리 시스템
- **MariaDB**: 데이터베이스 서버

각 서비스는 독립적인 Docker 컨테이너로 실행되며, 커스텀 Dockerfile을 통해 구축됩니다. Alpine Linux 또는 Debian의 penultimate 버전을 기반 이미지로 사용합니다.

## Key Design Choices

### Virtual Machines vs Docker

| 항목 | Virtual Machines | Docker (✓ 선택) |
|------|------------------|----------------|
| **장점** | • 완전한 OS 격리<br>• 높은 보안성<br>• 다른 OS 실행 가능 | • 가벼운 컨테이너 기반 가상화로 빠른 시작<br>• 효율적인 리소스 사용 (호스트 커널 공유)<br>• 이식성과 재현성 보장<br>• 마이크로서비스 아키텍처에 적합 |
| **단점** | • 높은 리소스 사용량<br>• 느린 시작 시간<br>• 큰 디스크 용량 필요 | • OS 레벨 격리는 VM보다 약함 |

**프로젝트에서의 선택**: 여러 서비스를 가볍고 효율적으로 운영하기 위해 Docker를 선택했습니다. 각 서비스(NGINX, WordPress, MariaDB)가 독립적인 컨테이너로 실행되며, 빠른 배포와 확장성을 제공합니다.

### Secrets vs Environment Variables

| 항목 | Environment Variables | Secrets (✓ 선택) |
|------|----------------------|------------------|
| **장점** | • 설정이 간단하고 직관적 | • 민감한 정보를 안전하게 저장<br>• tmpfs에 마운트되어 디스크에 기록되지 않음<br>• 접근 제어가 가능 |
| **단점** | • 프로세스 목록에서 노출될 수 있음<br>• 로그에 기록될 위험<br>• 보안에 취약 | • 설정이 약간 복잡함 |

**프로젝트에서의 선택**: 데이터베이스 비밀번호와 WordPress 인증 정보는 Docker secrets를 통해 관리됩니다. 이는 민감한 정보가 코드나 환경 변수에 노출되지 않도록 보호합니다.

### Docker Network vs Host Network

| 항목 | Host Network | Docker Network (✓ 선택) |
|------|--------------|------------------------|
| **장점** | • 네트워크 오버헤드 없음<br>• 최고 성능 | • 서비스 간 격리와 보안<br>• DNS 기반 서비스 디스커버리<br>• 네트워크 정책 제어 가능<br>• 포트 매핑 유연성 |
| **단점** | • 포트 충돌 위험<br>• 컨테이너 격리 약화<br>• 이식성 감소 | • 약간의 네트워크 오버헤드 |

**프로젝트에서의 선택**: 커스텀 Docker 네트워크를 생성하여 서비스 간 통신을 격리하고, 컨테이너 이름으로 서비스를 참조할 수 있도록 했습니다. 이는 보안성과 관리 용이성을 향상시킵니다.

### Docker Volumes vs Bind Mounts

| 항목 | Bind Mounts | Docker Volumes (✓ 선택) |
|------|-------------|------------------------|
| **장점** | • 호스트 파일 시스템에 직접 접근<br>• 개발 중 실시간 파일 수정 가능 | • Docker가 완전히 관리하여 이식성 향상<br>• 백업과 마이그레이션 용이<br>• 성능 최적화<br>• 여러 컨테이너 간 안전한 공유 |
| **단점** | • 호스트 파일 시스템 구조에 의존<br>• 이식성 낮음<br>• 권한 문제 발생 가능 | • 호스트에서 직접 접근이 어려움 |

**프로젝트에서의 선택**: WordPress 파일과 MariaDB 데이터는 Docker 볼륨에 저장됩니다. 이는 데이터 영속성을 보장하고, 컨테이너가 재시작되어도 데이터가 유지되도록 합니다. 볼륨은 `/home/seongkim/data/` 경로에 마운트됩니다.

# Instructions

## Prerequisites

다음 패키지들이 설치되어 있어야 합니다:

```bash
sudo apt update
sudo apt install build-essential git docker docker-compose-v2
```

## Project Setup

1. **Clone the repository**
```bash
git clone https://github.com/ausungju/inception.git
cd inception
```

2. **Build and run**

```bash
make
```

또는 수동으로:

```bash
docker-compose -f src/docker-compose.yml up --build -d
```

## Usage

서비스가 시작되면 브라우저에서 다음 주소로 접속할 수 있습니다:
- https://seongkim.42.fr

## Management Commands

```bash
# 서비스 시작
make

# 서비스 중지
make down

# 서비스 및 볼륨 삭제
make clean

# 모든 리소스 삭제 (볼륨, 이미지 포함)
make fclean

# 재빌드
make re
```

## Directory Structure

- `src/docker-compose.yml`: Docker Compose 설정 파일
- `src/requirements/nginx/`: NGINX 컨테이너 설정
- `src/requirements/wordpress/`: WordPress + PHP-FPM 컨테이너 설정
- `src/requirements/mariadb/`: MariaDB 컨테이너 설정
- `secrets/`: 민감한 정보 파일들 (Git에 커밋되지 않음)

# Resources

## Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Docker vs Virtual Machines](https://www.docker.com/resources/what-container)

## AI Usage

이 프로젝트에서는 다음과 같은 방식으로 AI를 활용했습니다:

- **사용 목적**: 문제 해결 및 개념 이해
- **적용 부분**:
  - 오류 발생시 원인 분석
  - README 작성시 도움