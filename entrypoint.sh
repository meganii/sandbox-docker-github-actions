#!/bin/bash
set -e

echo "Starting Ollama server..."
ollama serve &
SERVER_PID=$!

# サーバーが起動するまで待機
echo "Waiting for Ollama server to start..."
MAX_RETRIES=30
RETRY_COUNT=0
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
  RETRY_COUNT=$((RETRY_COUNT+1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Failed to start Ollama server after $MAX_RETRIES attempts"
    exit 1
  fi
  echo "Still waiting... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 1
done

echo "Ollama server is running"

# 利用可能なモデルを確認
echo "Available models:"
curl -s http://localhost:11434/api/tags | jq

# モデルが利用可能か確認
if ! curl -s http://localhost:11434/api/tags | jq -e '.models[] | select(.name == "gemma3:4b")' > /dev/null; then
  echo "WARNING: gemma:3-4b-it model not found in available models!"
else
  echo "gemma:3-4b-it model is available"
fi

# テスト用にGemma-3-4b-itで簡単なプロンプトを実行
echo "Testing Gemma-3-4b-it model:"
curl -s http://localhost:11434/api/generate -d '{
  "model": "gemma3:4b",
  "prompt": "Tell me about yourself in one sentence.",
  "stream": false
}' | jq '.response'

echo "Ollama is ready for use!"

# コンテナを実行し続ける（サーバープロセスが終了するまで待機）
wait $SERVER_PID