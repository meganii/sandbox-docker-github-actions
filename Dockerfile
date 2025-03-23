FROM ollama/ollama:latest

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    jq \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Ollama用のディレクトリを作成
RUN mkdir -p /root/.ollama

# モデルをダウンロードするスクリプトを作成
COPY download-model.sh /download-model.sh
RUN chmod +x /download-model.sh

# スクリプトを実行してモデルをダウンロード
RUN /download-model.sh

# 作業ディレクトリを指定
WORKDIR /app

# エントリポイントスクリプトをコピー
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# ポートを公開
EXPOSE 11434

# エントリポイントを設定
ENTRYPOINT ["/app/entrypoint.sh"]