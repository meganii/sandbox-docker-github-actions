FROM ollama/ollama:latest

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Gemma-3-4b-itモデルをあらかじめpull
RUN ollama pull gemma3:4b

# Ollamaサーバーを起動するエントリポイントスクリプト
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 11434
ENTRYPOINT ["/entrypoint.sh"]