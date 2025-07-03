#!/bin/bash
set -e

# curl 설치
if ! command -v curl &> /dev/null; then
    echo "🔧 curl 설치 중..."
    sudo apt-get update && sudo apt-get install -y curl
else
    echo "✅ curl 이미 설치됨"
fi

# uv 설치
if ! command -v uv &> /dev/null; then
    echo "🔧 uv 설치 중..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# uv 명령 확인
if ! command -v uv &> /dev/null; then
    echo "❌ uv 명령을 찾을 수 없습니다. $UV_BIN 을 직접 실행합니다."
fi

# pyproject.toml 초기화
if [ ! -f "pyproject.toml" ]; then
    echo "🆕 uv init 실행 중..."
    uv init
else
    echo "✅ pyproject.toml 이미 존재함"
fi

# requirements.txt 설치
if [ -f "requirements.txt" ]; then
    echo "📦 requirements.txt 설치 중..."
    uv add -r requirements.txt
else
    echo "❌ requirements.txt 파일이 없습니다."
    exit 1
fi

export PATH="$HOME/.local/bin:$PATH"

echo "🎉 설치 완료!"
