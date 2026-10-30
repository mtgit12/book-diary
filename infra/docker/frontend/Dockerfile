# syntax=docker/dockerfile:1

# 開発用の Next.js イメージ。Next.js は Node.js で実行し、パッケージ管理・スクリプト実行は Bun で行う。
FROM node:26.13-trixie-slim

COPY --from=oven/bun:1.4.4-slim /usr/local/bin/bun /usr/local/bin/bun
RUN ln -s /usr/local/bin/bun /usr/local/bin/bunx

WORKDIR /app

# node_modules は named volume でホストと分離する（ネイティブバイナリが OS ごとに異なるため）。
# 初回マウント時に所有者を引き継がせるため、node ユーザー所有で作成しておく。
RUN mkdir -p /app/node_modules && chown node:node /app/node_modules

USER node

EXPOSE 3000

CMD ["bun", "run", "dev", "--hostname", "0.0.0.0", "--port", "3000"]
