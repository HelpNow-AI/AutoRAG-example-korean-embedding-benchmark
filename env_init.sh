#!/bin/bash
set -e

# 1. curl 설치
if ! command -v curl &> /dev/null; then
    echo "🔧 curl 설치 중..."
    sudo apt-get update && apt-get install -y curl
else
    echo "✅ curl 이미 설치됨"
fi

# 2. uv 설치
if ! command -v uv &> /dev/null; then
    echo "🔧 uv 설치 중..."
    sudo curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
else
    echo "✅ uv 이미 설치됨"
fi

# 3. pyproject.toml 초기화
if [ ! -f "pyproject.toml" ]; then
    echo "🆕 uv init 실행 중..."
    uv init --yes
else
    echo "✅ pyproject.toml 이미 존재함"
fi

# 4. requirements.txt 설치
if [ -f "requirements.txt" ]; then
    echo "📦 requirements.txt를 통해 의존성 설치 중..."
    uv add -r requirements.txt
else
    echo "❌ requirements.txt 파일이 없습니다."
    exit 1
fi

echo "🎉 설치 완료!"
