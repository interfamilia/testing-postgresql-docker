# testing-postgresql-docker

PostgreSQL 検証用 Docker 環境

[郵便住所.jp](https://postaladdress.jp/) からダウンロードした CSV を取り込んで、
郵便番号・住所マスタのデータベースを作る検証用の環境です。

`docker compose up` を実行すると、データベースの作成・テーブルの作成・CSV の取り込みまでが自動で行われます。

なお、本番環境での利用は想定していません。あくまで検証用としてご利用ください。

## 構成

```
testing-postgresql-docker/
├── docker-compose.yml
├── csv/                     ← ダウンロードした CSV を置く（.gitignore 対象）
└── initdb/
    ├── 01_create_table.sql  ← テーブル作成
    └── 02_import_csv.sql    ← CSV 取り込み
```

作成されるデータベースとテーブルは以下のとおりです。

* データベース
  * `postaladdress` (郵便住所)
* テーブル
  * `prefecture` (都道府県)
  * `municipality` (市区町村) … `prefecture` への FK を持つ
  * `postal_address` (郵便住所) … `municipality` への FK を持つ

## 利用する前に

* Docker Desktop がインストールされており `docker compose` コマンドが使える。

## 使い方

### 1. CSV をダウンロードする

CSV は再配布が禁止されているため、このリポジトリには含まれていません。<br>
[郵便住所.jp](https://postaladdress.jp/) から、以下の項目を選んでダウンロードしてください。

**[都道府県](https://postaladdress.jp/prefecture/csv)**

| 項目 | 選択 |
|---|---|
| 都道府県コード | ✅ |
| 都道府県名 | ✅ |
| 都道府県名カナ | ✅ |
| 都道府県名ローマ字 | ✅ |

**[市区町村](https://postaladdress.jp/municipality/csv)**

| 項目 | 選択 |
|---|---|
| 市区町村コード | ✅ |
| 市区町村名 | ✅ |
| 市区町村名カナ | ✅ |
| 市区町村名ローマ字 | ✅ |
| 都道府県コード | ✅ |
| 都道府県名 / カナ / ローマ字 | ❌ |
| 廃止フラグ | ❌ |

**[郵便番号・住所](https://postaladdress.jp/address/csv)**

| 項目 | 選択 |
|---|---|
| 郵便番号 | ✅ |
| 市区町村コード | ✅ |
| 町域名 | ✅ |
| 町域名カナ | ✅ |
| 町域名ローマ字 | ✅ |
| 上記以外 | ❌ |

※ 都道府県コード・都道府県名・市区町村名は初期状態でチェックが入っています。**外してください。**<br>
※ 「廃止データを含める」「以下に掲載がない場合を含める」「町域を集約する」はいずれも選択しません。

**項目の並び順は、画面に並んでいる順で固定されます。**（チェックした順ではありません）

### 2. CSV を配置する

ダウンロードした ZIP を解凍し、以下の名前にリネームして `csv/` に置いてください。

```
csv/
├── prefecture.csv
├── municipality.csv
└── postal_address.csv
```

### 3. 起動する

```
docker compose up -d
```

12万件ほどの取り込みがあるため、初回起動には少し時間がかかります。<br>
ログに `PostgreSQL init process complete; ready for start up.` と出れば完了です。

```
docker compose logs postgres
```

### 4. 接続する

```
docker compose exec postgres psql -U postgres -d postaladdress
```

```sql
postaladdress=# SELECT count(*) FROM prefecture;
 count
-------
    47
(1 row)

postaladdress=# SELECT count(*) FROM municipality;
 count
-------
  1892
(1 row)

postaladdress=# SELECT count(*) FROM postal_address;
 count
--------
 122653
(1 row)
```

郵便番号から住所を引いてみます。

```sql
SELECT a.postal_code,
       p.prefecture_name,
       m.municipality_name,
       a.street_name
  FROM postal_address a
  JOIN municipality m ON m.municipality_code = a.municipality_code
  JOIN prefecture   p ON p.prefecture_code   = m.prefecture_code
 WHERE a.postal_code = '1000001';
```

```
 postal_code | prefecture_name | municipality_name | street_name
-------------+-----------------+-------------------+-------------
 1000001     | 東京都          | 千代田区          | 千代田
(1 row)
```

## 作り直す

`initdb/` の SQL は、**データベースがまだ存在しない初回起動時にしか実行されません。**<br>
SQL や CSV を差し替えたときは、ボリュームごと削除してから起動し直してください。

```
docker compose down -v
docker compose up -d
```

## 接続情報

| 項目 | 値 |
|---|---|
| ホスト | `localhost` |
| ポート | `5432` |
| データベース | `postaladdress` |
| ユーザー | `postgres` |
| パスワード | `postgres` |
