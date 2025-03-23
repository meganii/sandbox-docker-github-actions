FROM ollama/ollama:latest

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Ollama用のディレクトリを作成
RUN mkdir -p /root/.ollama

# 一度サーバーを起動し、モデルをダウンロード（マルチステージビルド内でサーバーを実行）
RUN nohup sh -c "ollama serve &" && \
    sleep 5 && \
    echo "Pulling gemma:3-4b-it model..." && \
    ollama pull gemma3:4 && \
    sleep 2 && \
    pkill ollama && \
    sleep 2 && \
    echo "Model successfully pulled and stored in /root/.ollama"

# 作業ディレクトリを指定
WORKDIR /app

# エントリポイントスクリプトをコピー
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# ポートを公開
EXPOSE 11434

# エントリポイントを設定
ENTRYPOINT ["/app/entrypoint.sh"]