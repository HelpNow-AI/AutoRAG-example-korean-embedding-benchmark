#!/bin/bash

set -e  # 오류 발생 시 스크립트 종료

# ✅ 최신 버전 지정 (업데이트 시 이 값만 바꾸면 됨)
VERSION="3500200"  # 예: 3.44.2 => 3440200
YEAR="2025"

# ✅ 다운로드 URL 구성
TARBALL="sqlite-autoconf-${VERSION}.tar.gz"
URL="https://www.sqlite.org/${YEAR}/${TARBALL}"

# ✅ 설치 디렉토리 설정
INSTALL_DIR="$HOME/sqlite3"
BUILD_DIR="/tmp/sqlite3_build"

echo ">>> [1] sqlite3 $VERSION 다운로드 중..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
curl -O "$URL"

echo ">>> [2] 압축 해제 중..."
tar xzf "$TARBALL"
cd "sqlite-autoconf-${VERSION}"

echo ">>> [3] 컴파일 및 설치 중..."
./configure --prefix="$INSTALL_DIR" --enable-fts5
make -j"$(nproc)"
make install

echo ">>> [4] 경로 설정 안내"
echo ""
echo "  export PATH=\"$INSTALL_DIR/bin:\$PATH\""
echo "  export LD_LIBRARY_PATH=\"$INSTALL_DIR/lib:\$LD_LIBRARY_PATH\""
echo ""
echo ">>> [5] 설치 완료. 버전 확인:"
"$INSTALL_DIR/bin/sqlite3" --version
