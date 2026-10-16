# Technology Stack

## フレームワーク・言語

| 区分 | 技術 |
|---|---|
| フロントエンド | Next.js(App Router、Node.js サーバーで実行)、TypeScript |
| バックエンド | Laravel(PHP)、REST API |
| バッチ | Go |
| データベース | MySQL |

## ライブラリ

| 区分 | 用途 | ライブラリ |
|---|---|---|
| フロントエンド | UI | shadcn/ui(Tailwind CSS)  |
| フロントエンド | サーバー状態(API データの取得・キャッシュ) | TanStack Query |
| フロントエンド | クライアント状態(UI の状態) | zustand |
| フロントエンド | フォーム・バリデーション | React Hook Form、zod |
| バックエンド | 認証 | Laravel Sanctum(SPA 認証、バッチ用の API トークン) |

## 外部サービス

| 用途 | サービス |
|---|---|
| 書籍データの取得 | 楽天ブックス書籍検索 API、（将来的にはDMM Web APIやAmazon Creators APIの使用も検討） |

## 開発ツール

| 用途 | ツール |
|---|---|
| パッケージ管理・スクリプト実行(フロント) | Bun |
| API 設計・仕様書・モック | Apidog |
| Lint・フォーマット | Biome(フロント)、Laravel Pint(バックエンド) |
| 静的解析 | Larastan |
| テスト | Pest(バックエンド)、Vitest + Testing Library(フロント)、Playwright(E2E) |
| 開発環境 | Docker(Docker Compose で Next.js、Laravel、MySQL をすべてコンテナ化) |
| CI | GitHub Actions |
| 本番環境 | Lightsail |

## 技術的制約

### 全体

- 上記以外のライブラリを追加する場合は、既存のスタックで代替できないかを先に検討する。
- 各ライブラリは着手時点の最新安定版を使い、lock ファイルでバージョンを固定する。
- 入力のバリデーションは、フロント(zod)とバックエンド(FormRequest)の両方で行う。

### フロントエンド

- フロントエンドは、すべてのデータを Laravel の API 経由で取得・更新する。外部API を直接呼ばない。
- 静的エクスポート(`output: 'export'`)は使わず、Next.js は Node.js サーバーで実行する。ページごとのレンダリング手法は、画面の検討後に決める。
- `layout.tsx` と `page.tsx` は Server Components のままにする。
- Server Components でのデータ取得は、SEO が必要なページに限って許可する。それ以外のデータの取得と、すべての更新(ミューテーション)は、クライアントコンポーネントから行う。
- Server Actions(Server Functions)は使わない。
- クライアントで API から取得したデータは TanStack Query で管理し、zustand には UI の状態だけを持たせる。
- 開発は画面→API の順で進める。Laravel の API が完成するまでは、フロントエンドは Apidog のモック API に接続し、接続先は環境変数で切り替える。

### 認証

- 認証は Sanctum の SPA 認証(クッキー)を使うため、フロントエンドと API は同一のトップレベルドメインで運用する。将来のモバイルアプリはトークン認証を使う。
- バッチから呼ぶ内部 API は、バッチ専用の Sanctum API トークンで保護し、一般ユーザーからは呼べないようにする。