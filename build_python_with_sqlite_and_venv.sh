#!/bin/bash
set -e

# === 환경 설정 ===
PYTHON_VERSION="3.10.12"
SQLITE_VERSION="3500200"
YEAR="2025"

# 현재 작업 디렉토리 기준
WORKDIR="$(pwd)"
BUILD_DIR="$WORKDIR/_build"
SQLITE_PREFIX="$BUILD_DIR/sqlite"
PYTHON_PREFIX="$BUILD_DIR/python"

# === 0. 필수 패키지 설치 ===
echo "📦 필수 빌드 패키지 설치 확인/설치 중..."
sudo apt-get update
sudo apt-get install -y \
  build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev \
  libffi-dev wget curl libncursesw5-dev xz-utils tk-dev

# === 1. 작업 디렉토리 생성 ===
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# === 2. SQLite 다운로드 및 설치 ===
echo "📦 다운로드: SQLite 3.50.2"
wget -q https://www.sqlite.org/${YEAR}/sqlite-autoconf-${SQLITE_VERSION}.tar.gz
tar xzf sqlite-autoconf-${SQLITE_VERSION}.tar.gz
cd sqlite-autoconf-${SQLITE_VERSION}
./configure --prefix="$SQLITE_PREFIX" --enable-fts5
make -j"$(nproc)"
make install

# SQLite CLI 버전 출력
echo "✅ SQLite CLI 버전:"
"$SQLITE_PREFIX/bin/sqlite3" --version

cd "$BUILD_DIR"

# === 3. Python 소스 다운로드 및 설치 ===
echo "🐍 다운로드: Python ${PYTHON_VERSION}"
wget -q https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar xzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}

echo "🔧 Python 빌드 (SQLite 연동)"
export CPPFLAGS="-I${SQLITE_PREFIX}/include"
export LDFLAGS="-L${SQLITE_PREFIX}/lib"
export LD_RUN_PATH="${SQLITE_PREFIX}/lib"

./configure --prefix="$PYTHON_PREFIX" --enable-optimizations --enable-loadable-sqlite-extensions
make -j"$(nproc)"
make install
cd "$WORKDIR"

# === 4. 가상환경 생성 (.venv) ===
echo "🧪 가상환경 생성: $WORKDIR/.venv"
"$PYTHON_PREFIX/bin/python3" -m venv .venv

# === 5. 버전 확인 ===
source .venv/bin/activate
echo "✅ Python 버전 확인:"
python --version
echo "✅ SQLite 버전 확인:"
python -c "import sqlite3; print('SQLite version:', sqlite3.sqlite_version)"

# === 6. 빌드 산출물 정리 (옵션) ===
echo "🧹 빌드 파일 정리 중..."
rm -rf "$BUILD_DIR/sqlite-autoconf-${SQLITE_VERSION}" "$BUILD_DIR/Python-${PYTHON_VERSION}" \
       "$BUILD_DIR/sqlite-autoconf-${SQLITE_VERSION}.tar.gz" "$BUILD_DIR/Python-${PYTHON_VERSION}.tgz"

echo "🎉 완료! .venv 가상환경이 생성되었고, SQLite 3.50.2가 연결되어 있습니다."
