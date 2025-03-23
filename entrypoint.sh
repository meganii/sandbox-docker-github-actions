#!/bin/bash
set -e

# Ollamaサーバーをバックグラウンドで起動
ollama serve &

# サーバーが起動するまで待機
echo "Waiting for Ollama server to start..."
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
  sleep 1
done

echo "Ollama server is running"
echo "Available models:"
curl -s http://localhost:11434/api/tags | jq

# テスト用にGemma-3-4b-itで簡単なプロンプトを実行
echo "Testing Gemma-3-4b-it model:"
curl -s http://localhost:11434/api/generate -d '{
  "model": "gemma:3-4b-it",
  "prompt": "Tell me about yourself in one sentence.",
  "stream": false
}' | jq '.response'

# コンテナを実行し続ける
tail -f /dev/null