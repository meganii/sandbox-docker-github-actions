#!/bin/bash
set -e

echo "Starting Ollama server for model download..."
nohup ollama serve > /tmp/ollama.log 2>&1 &
SERVER_PID=$!

# サーバー起動を確認するループ
MAX_RETRIES=30
RETRY_COUNT=0
echo "Waiting for Ollama server to start..."
while ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; do
  RETRY_COUNT=$((RETRY_COUNT+1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "Failed to start Ollama server after $MAX_RETRIES attempts"
    cat /tmp/ollama.log
    exit 1
  fi
  echo "Waiting for server... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 1
done

echo "Ollama server started successfully!"

# タイムアウト付きでモデルをダウンロード
echo "Starting to download gemma3:4b model..."
DOWNLOAD_TIMEOUT=1800  # 30分のタイムアウト
timeout $DOWNLOAD_TIMEOUT ollama pull gemma3:4b

# ダウンロードの成功を確認
if [ $? -ne 0 ]; then
  echo "Model download failed or timed out after $DOWNLOAD_TIMEOUT seconds"
  echo "Server log:"
  cat /tmp/ollama.log
  kill $SERVER_PID || true
  exit 1
fi

echo "Model successfully downloaded!"

# サーバーを停止
echo "Stopping Ollama server..."
kill $SERVER_PID || true
sleep 5

# サーバーが停止したことを確認
if ps -p $SERVER_PID > /dev/null; then
  echo "Server did not stop gracefully, forcing kill..."
  kill -9 $SERVER_PID || true
fi

# ダウンロードされたモデルの確認
echo "Checking downloaded models in /root/.ollama directory:"
find /root/.ollama -type f | grep -v "tmp" | sort

echo "Model download process completed successfully!"