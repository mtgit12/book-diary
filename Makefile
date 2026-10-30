.DEFAULT_GOAL := help

COMPOSE := docker compose

.PHONY: help up down logs migrate test-backend pint phpstan test-frontend lint-frontend format-frontend

help: ## コマンド一覧を表示する
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# 起動・停止
up: ## コンテナを起動する
	$(COMPOSE) up -d

down: ## コンテナを停止する
	$(COMPOSE) down

logs: ## backend / frontend のログを確認する
	$(COMPOSE) logs -f backend frontend

# Laravel
migrate: ## マイグレーションを実行する
	$(COMPOSE) exec backend php artisan migrate

test-backend: ## Laravel のテストを実行する
	$(COMPOSE) exec backend composer test

pint: ## Pint でコードを整形する
	$(COMPOSE) exec backend vendor/bin/pint

phpstan: ## PHPStan で静的解析する
	$(COMPOSE) exec backend vendor/bin/phpstan analyse

# Next.js
test-frontend: ## Next.js のテストを実行する
	$(COMPOSE) exec frontend bun run test

lint-frontend: ## Biome で Lint・フォーマットをチェックする
	$(COMPOSE) exec frontend bun run lint

format-frontend: ## Biome で整形・import 並び替えをする
	$(COMPOSE) exec frontend bun run format
