# 概要

コードの書き方の決まり。命名、ファイル構成、import、アーキテクチャの詳細は `structure.md` を正とし、ここには要点だけを載せる。

## 基本方針

- 短さより読みやすさを優先する。
- フォーマットと import の並び順はツールに任せる(フロントは Biome、バックエンドは Laravel Pint)。人が手で整えない。
- Biome、Pint、Larastan の警告は解消してからマージする。
- コメントは日本語で、「何をしているか」ではなく「なぜそうしているか」を書く。

## 命名(要点)

- **フロント**
  - ファイルとフォルダは kebab-case、コンポーネントは PascalCase にする。
  - フックは `use` + camelCase、zustand のストアは `use` + 名前 + `Store` にする。
  - API 呼び出しの関数は「動詞 + 名詞」(`getBooks`)にする。
- **バックエンド**
  - クラス名は役割を末尾に付ける(`BookService`、`BookRepositoryInterface`、`EloquentBookRepository`、`StoreBookRequest`、`BookResource`)。
  - テーブルは snake_case の複数形、カラムは snake_case にする。
- **API**: URL は kebab-case の複数形にする。JSON のキーは snake_case にし、フロントでも変換しない。
- 真偽値は `is_`、`has_`(TypeScript では `is`、`has`)から始める。

## ファイル構成・import(要点)

- 機能ごとのコードは `features/{機能名}/` に置き、必要なフォルダだけを作る。
- 依存の向きは「共通部分 → `features` → `app`」の一方向にする。機能同士の import は禁止し、組み合わせは `app/` で行う。
- バレルファイル(`index.ts`)は作らず、ファイルを直接 import する。
- import には `@/` を使う。相対パスは同じフォルダ内のファイルに限る。
- `.server.ts` の先頭に `import 'server-only'` を書き、Server Components からだけ import する。
- 1ファイルに1コンポーネントとする。

## TypeScript

- `strict` を有効にする。`any` は使わず、型がわからない値は `unknown` で受けて絞り込む。
- 型の定義には `type` を使い、`interface` は使わない。
- `enum` は使わず、ユニオン型と `as const` で表す。
- export は named export に統一する。default export は Next.js が求めるファイル(`page.tsx`、`layout.tsx` など)だけにする。
- コンポーネントの props の型は `{コンポーネント名}Props` とする。
- API の応答の型は各機能の `types/` に置き、API 仕様(snake_case)と一致させる。

## React・Next.js

- `page.tsx` と `layout.tsx` は Server Components のままにする。操作を伴う部分は `features/` 配下のクライアントコンポーネントに切り出す。
- `"use client"` は、状態やイベントを扱う末端のコンポーネントに付ける。上位のコンポーネントに付けて、配下をまとめてクライアントにしない。
- API のデータは、各機能の `api/` にある TanStack Query のフックで取得・更新する。
- クエリキーは各機能の `api/` で定義し、更新後のキャッシュの無効化に同じキーを使う。
- zustand には UI の状態(モーダルの開閉、選択中のタブなど)だけを持たせる。
- ほかの値から計算できる値は、state に持たずに描画時に計算する。
- フォームは React Hook Form と zod で作る。zod のスキーマは各機能に置き、型はスキーマから生成する。
- 画面の文言は `locales/` にまとめ、コンポーネントに直接書かない。

各機能の `api/` は、API 呼び出しの関数とフックを1ファイルにまとめる。

```ts
// features/bookshelf/api/get-bookshelf-items.ts
export const bookshelfItemsQueryKey = (params: GetBookshelfItemsParams) =>
  ['bookshelf-items', params] as const;

export const getBookshelfItems = (params: GetBookshelfItemsParams) =>
  api.get<Paginated<BookshelfItem>>('/bookshelf-items', { params });

export const useBookshelfItems = (params: GetBookshelfItemsParams) =>
  useQuery({
    queryKey: bookshelfItemsQueryKey(params),
    queryFn: () => getBookshelfItems(params),
  });
```

## Laravel

- 引数と戻り値には、すべて型を宣言する。
- 依存はコンストラクターで注入し、Repository はインターフェースで受け取る。
- 状態や種別(読書状態、キーワードの種別)は、PHP の Enum で表し、モデルのキャストに指定する。
- Model に書くのは、リレーション、キャスト、`$fillable`、`$hidden` だけにする。クエリは Repository に置く。
- 関連データの取得は Repository の Eager Loading(`with`)で行い、N+1 を防ぐ。
- 複数のテーブルを更新する処理は、Service のトランザクションの中で行う。

Controller は、検証、認可、Service の呼び出し、Resource での返却だけを行う。

```php
public function update(UpdateBookshelfItemRequest $request, BookshelfItem $item): BookshelfItemResource
{
    $this->authorize('update', $item);

    $item = $this->bookshelfService->update($item, $request->validated());

    return new BookshelfItemResource($item);
}
```

## Go(バッチ)

- `gofmt` と `go vet` を通す。
- エラーは握りつぶさず、`fmt.Errorf("...: %w", err)` で文脈を付けて返す。通常の処理では `panic` を使わない。
- 外部への通信には `context` でタイムアウトを設定する。
- 設定値は環境変数から読み込み、起動時に検証する。

## テスト

- テストのファイルは `tests/` に、`src/` と同じ構成で置く。
- テストの名前は、何を確かめるかが日本語でわかるように書く(例: 「ほかのユーザーの本棚は404になる」)。
- 1つのテストでは1つのことだけを確かめる。

## アンチパターン

| 避けること | 代わりにすること |
|---|---|
| `useEffect` の中で API を呼び、結果を state に入れる | TanStack Query のフックを使う |
| API のデータを zustand や `useState` にコピーする | TanStack Query のキャッシュを直接使う |
| 別の機能のフォルダから import する | `app/` で組み合わせる |
| Server Actions を使う | クライアントから API を呼ぶ |
| `dangerouslySetInnerHTML` を使う | テキストとして描画する |
| Controller や Service で Eloquent のクエリを書く | Repository に置く |
| Controller で `$request->validate()` を使う | FormRequest に分ける |
| `$request->all()` を Service に渡す | `$request->validated()` を渡す |
| Model をそのまま返す | API Resource で返す項目を明示する |
| Service 同士が互いに呼び合う | 共通の処理を片方に寄せるか、新しい Service に切り出す |