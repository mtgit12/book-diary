# Book Diary

個人向けの読書管理Webアプリケーション。

## Structure

```
/
├── docs/                  # ドキュメント類
├── frontend/              # 画面
├── backend/               # API
├── batch/                 # Go(バッチ)
├── compose.yaml
├── infra/                 # インフラ関連（DockerfileやAWSリソース等）
└── .github/workflows/     # GitHub Actions
```

## Set up

### 1. リポジトリを取得する

```sh
git clone https://github.com/mtgit12/book-diary.git
cd book-diary
```

### 2. Docker Compose 用の環境変数を作成する

```sh
cp .env.example .env
```

`.env` を開き、`DB_PASSWORD` と `DB_ROOT_PASSWORD` を任意の値に変更する。Linux の場合は `UID` / `GID` のコメントを外し、ホストのユーザーの値(`id -u` / `id -g`)を設定する。

### 3. Laravel の環境変数を作成する

```sh
cp backend/.env.example backend/.env
```

`backend/.env` の `DB_PASSWORD` を、手順 2 の `.env` の `DB_PASSWORD` と同じ値に変更する。`DB_HOST`(Compose のサービス名 `mysql`)などそれ以外の `DB_*` は、`.env.example` の値のままでよい。

テスト(`composer test`)は `phpunit.xml` の設定で、同じ MySQL のテスト用 DB `testing` を使う。

### 4. イメージをビルドする

```sh
docker compose build
```

### 5. 依存パッケージをインストールする

```sh
# Laravel(vendor/)
docker compose run --rm --no-deps backend composer install

# Next.js(node_modules/)
docker compose run --rm --no-deps frontend bun install --frozen-lockfile
```

### 6. Laravel のアプリケーションキーを生成する

```sh
docker compose run --rm --no-deps backend php artisan key:generate
```

### 7. コンテナを起動する

```sh
docker compose up -d
```

初回は MySQL の初期化(開発用 DB `book_diary` とテスト用 DB `testing` の作成)に少し時間がかかる。`docker compose ps` で全サービスが起動していることを確認する。

### 8. マイグレーションを実行する

```sh
docker compose exec backend php artisan migrate
```

## Enviroment

Docker Compose で Next.js、Laravel(nginx + php-fpm)、MySQL、Mailpit を起動する。

| サービス | URL | 内容 |
|---|---|---|
| frontend | http://localhost:3000 | Next.js(Node.js 26、パッケージ管理は Bun) |
| nginx / backend | http://localhost:8000 | Laravel(PHP 8.5) |
| mysql | localhost:3306 | MySQL 8.4(開発用 `book_diary`、テスト用 `testing`) |
| mailpit | http://localhost:8025 | 送信したメールの確認 |

## Command

`make` (または `make help`)でコマンド一覧を表示できる。

```sh
# 起動・停止
make up
make down

# ログを確認する
make logs

# Laravel
make migrate
make test-backend
make pint
make phpstan

# Next.js
make test-frontend
make lint-frontend
make format-frontend
```
