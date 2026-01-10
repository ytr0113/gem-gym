# Gem Gym (ジェム・ジム)

トレーニング記録をサクサク残せるNuxt.jsアプリです。

## セットアップ

### 1. 依存関係のインストール

```bash
npm install
```

### 2. 環境変数の設定

`.env.example` をコピーして `.env` を作成します。

```bash
cp .env.example .env
```

### 3. ローカル開発環境 (Supabase + Docker) の起動

このプロジェクトは [Supabase CLI](https://supabase.com/docs/guides/cli) を使用しています。Docker がインストールされ、起動していることを確認してください。

```bash
# 初回起動時、またはコンテナの開始
npx supabase start
```

起動が完了すると、コンテナ内でデータベース、認証、Studioが立ち上がります。
- **Studio (管理画面):** `http://localhost:54323`
- **API URL:** `http://localhost:54321`

### 4. 開発サーバーの起動

```bash
npm run dev
```

ブラウザで `http://localhost:3000` を開きます。

## 開発の進め方

### データベーススキーマの変更
- `supabase/migrations` 内にマイグレーションファイルを作成または追加します。
- `npx supabase db reset` を実行すると、DBがリセットされ、最新のスキーマと `seed.sql` のデータが適用されます。

### 型の生成
スキーマを変更した後は、TypeScript用の型を更新します。

```bash
npx supabase gen types typescript --local > types/database.ts
```

## Production

Build the application for production:

```bash
npm run build
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
