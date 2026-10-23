# Project Structure

## ファイル構成

### リポジトリ全体(モノレポ)

```
/
├── docs/                  # ドキュメント類
├── frontend/              # Next.js
├── backend/               # Laravel
├── batch/                 # Go(バッチ)
├── compose.yaml
├── infra/                 # インフラ関連（DockerfileやAWSリソース等）
└── .github/workflows/     # GitHub Actions
```

### フロントエンド(bulletproof-react を参考)

```
frontend/
├── src/
│   ├── app/               # Next.js App Router(ルーティング、layout.tsx、page.tsx、プロバイダー)
│   ├── components/        # アプリ全体で使う共通コンポーネント
│   │   └── ui/            # shadcn/ui・Kibo UI の CLI で追加したコンポーネント
│   ├── config/            # 環境変数などの設定
│   ├── features/          # 機能ごとのモジュール
│   │   └── books/         # 例: 書籍機能
│   │       ├── api/       # API 呼び出しの関数と TanStack Query のフック、サーバー用の関数(`.server.ts`)
│   │       ├── components/
│   │       ├── hooks/
│   │       ├── stores/    # zustand のストア
│   │       ├── types/
│   │       └── utils/
│   ├── hooks/             # 共通のフック
│   ├── lib/               # 設定済みのライブラリ(API クライアント、QueryClient など)
│   ├── locales/           # 画面の文言
│   ├── stores/            # 共通の zustand ストア
│   ├── types/             # 共通の型
│   └── utils/             # 共通のユーティリティ関数
├── tests/                 # Vitest のテスト(src と同じ構成で配置)
└── e2e/                   # Playwright のテスト
```

- `features/` 配下は必要なフォルダだけを作る。

### バックエンド(Service・Repository パターン)

```
backend/
├── app/
│   ├── Enums/
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Requests/
│   │   └── Resources/
│   ├── Models/                # Eloquent モデル(Laravel のデフォルトの場所)
│   ├── Policies/              # 認可(Policy)
│   ├── Providers/             # Repository のインターフェースと実装の紐づけ
│   ├── Repositories/          # Repository のインターフェースと Eloquent での実装
│   └── Services/              # 機能ごとのビジネスロジック
├── database/
├── routes/api.php
└── tests/
    ├── Feature/               # API 単位のテスト
    └── Unit/                  # Service などの単体テスト
```

## 命名規則

### フロントエンド

| 対象 | 規則 | 例 |
|---|---|---|
| ファイル・フォルダ | kebab-case | `book-card.tsx` |
| コンポーネント | PascalCase | `BookCard` |
| フック | `use` + camelCase | `useBooks`(`use-books.ts`) |
| zustand ストア | `use` + 名前 + `Store` | `useBookshelfStore`(`use-bookshelf-store.ts`) |
| API 呼び出しの関数 | 動詞 + 名詞 | `getBooks`、`addBook` |
| サーバー用の API 呼び出しの関数のファイル | 関数名の kebab-case + `.server` | `get-book.server.ts` |
| 型 | PascalCase | `Book`、`AddBookInput` |
| 単体テスト | 対象ファイル名 + `.test` | `book-card.test.tsx` |
| E2E テスト | 内容 + `.spec` | `add-book.spec.ts` |

### バックエンド

| 対象 | 規則 | 例 |
|---|---|---|
| Service | 名詞 + `Service` | `BookService` |
| Repository のインターフェース | 名詞 + `RepositoryInterface` | `BookRepositoryInterface` |
| Repository の実装 | `Eloquent` + 名詞 + `Repository` | `EloquentBookRepository` |
| Controller | 名詞 + `Controller` | `BookController` |
| FormRequest | 動詞 + 名詞 + `Request` | `StoreBookRequest` |
| API Resource | 名詞 + `Resource` | `BookResource` |
| Policy | モデル名 + `Policy` | `BookPolicy` |
| テーブル | snake_case の複数形 | `books`、`bookshelf_items` |
| カラム | snake_case | `sales_date` |

### API

- URL は `/api/v1/` から始め、リソースは kebab-case の複数形にする(例: `/api/v1/bookshelf-items`)。
- JSON のキーは snake_case とし、フロントエンドでも変換せずにそのまま扱う。

## import のルール

### フロントエンド

- `@/` を `frontend/src/` のエイリアスとして使う。
- バレルファイル(`index.ts` での再エクスポート)は作らず、ファイルを直接 import する。
- 依存の向きは「共通部分(`components`、`hooks`、`lib`、`stores`、`types`、`utils`、`config`)→ `features` → `app`」の一方向にする。逆向きの import は禁止。
- 機能同士(`features/` 配下の別フォルダ)の import は禁止し、組み合わせは `app/` で行う。ツールでは強制しないため、規約としてレビューで守る。
- サーバー用の関数のファイル(`.server.ts`)は、先頭に `import 'server-only'` を書き、Server Components からだけ import する。

### バックエンド

- 処理の流れは「Controller → Service → Repository → Model」とする。
- Controller は、FormRequest での検証、Policy での認可、Service の呼び出し、API Resource での返却だけを行う。
- Service は、ビジネスロジックとトランザクションを担い、DB へのアクセスは Repository のインターフェース経由でのみ行う。
- DB へのアクセス(集計クエリを含む)は、すべて Repository に置く。
- Service から別の Service を呼ぶ場合は、循環参照にならないようにする。

## アーキテクチャ上の決定

- `layout.tsx` と `page.tsx` は Server Components のままにする。SEO が必要なページでは、`page.tsx` から各機能の `api/` にあるサーバー用の関数(`.server.ts`)でデータを取得してよい。それ以外のデータを扱う部分は、`features/` 配下のクライアントコンポーネント(`"use client"`)に切り出す。
- クライアントからの API 呼び出しは `lib/` の共通 API クライアント(クッキー送信・CSRF トークンの処理を含む)を通し、各機能の `api/` に関数とフックを置く。
- バックエンドは「Controller → Service → Repository → Model」のレイヤー構成とし、Eloquent モデルや Policy は Laravel のデフォルトの場所に置く。
- Repository はインターフェースと Eloquent での実装に分け、ServiceProvider で紐づける。
- Service は機能ごとに1クラスとし、`Services/`、`Repositories/` は機能ごとのサブフォルダを作らずフラットに置く。