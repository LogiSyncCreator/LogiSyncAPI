# Hello Vapor

Product/Scheme/Edit Scheme.../Options/Working Directoryをチェックし、
ディレクトリを指定する

# Account
http://localhost:8080/account
## Login
http://localhost:8080/account/login
JSON
{
    "username": "ユーザー名"
    "password": "パスワード"
}

仕様
POSTで送信し、ユーザー名とパスワードを比較する
IDは平文、
パスワードはBcryptでハッシュ化されて参照される

## Regist
http://localhost:8080/account/regist
JSON
{
    "name": String,
    "company": String,
    "role": String,
    "userId": String,
    "pass": String,
    "phone": String,
    "profile": String,
    "delete": Bool  -> 基本的にfalse
}
仕様
POSTで送信し、インサートする

## Serch ID
http://127.0.0.1:8080/accounts/serchid/{userID}
仕様
GETで送信し
IDが存在でtrue/falseを返す

## SerchUser
http://127.0.0.1:8080/accounts/serchuser/{userID}
仕様
GETで送信し
IDが一致するユーザーのデータを表示

## DELETE
http://127.0.0.1:8080/accounts/delete/{userID}
仕様
DELETEで送信し
IDが一致するユーザのDeleteフラグを反転する
現状はログインができなくなる


# Thumbnails
http://127.0.0.1:8080/thumbnail/

## regist
http://127.0.0.1:8080/thumbnail/create
{
    "userId": "testAccount",
    "thumbnail": "http://example.com",
    "delete": false
}
仕様
POSTで送信し、インサートする

## getThumb
http://127.0.0.1:8080/thumbnails/getThumb/{userID}
仕様
GETで送信
対応するIDのサムネイルURLを取得

## delete
http://127.0.0.1:8080/thumbnails/delete/{userID}
仕様
DELETEで送信し
IDが一致するユーザのDeleteフラグをTrueにする

# Status
http://127.0.0.1:8080/status/
## post
customStatusの新規登録
{
  "manager": "testMan",
  "shipper": "testShip",
  "name": "試運転",
  "delete": false
}
## delete
http://127.0.0.1:8080/status/{userID}
customStatusの論理削除
## nowstatus
http://127.0.0.1:8080/status/nowstatus/{userID}
仕様
GETで送信
対応するIDのステータスを取得
ID:status
## ステータスの更新
ws://127.0.0.1:8080/status/now/{userID}
仕様
WebSocketに対して投げたID先のステータスを更新する
## グループ間で登録したカスタムステータスの取得
http://127.0.0.1:8080/status/groupstatus/{管理者ID}/{荷主ID}
マッチングが合えば登録されたものを呼び寄せる

# Matching
http://127.0.0.1:8080/matching
## POST
{
"manager": "id",
"shipper": "id",
"driver": "id",
"address": "到着住所",
"delete": false
}
## 解除
http://127.0.0.1:8080/matching/cancel/{uuid}
マッチング先のuuidでマッチングを論理的に解除

## マッチング検索
http://127.0.0.1:8080/matching/group
{
  "manager": "id",
  "driver": "id",
  "shipper": "id"
}
いずれか一つに一致するIDのマッチングを表示

# token
http://127.0.0.1:8080/token
仕様
GET 全件数取り寄せ
## 登録
http://127.0.0.1:8080/token
{
  "userId": "ユーザID",
  "token":  "トークン"
}
仕様
POST jsonの値を登録
## 検索
http://127.0.0.1:8080/token/{ユーザID}
仕様
GET 任意のユーザのトークンと更新日を取得

# Locations
## 全数検索
http://127.0.0.1:8080/locations
仕様
GET 全件数取り寄せ
## 検索
http://127.0.0.1:8080/locations/{ユーザID}
仕様
GET 任意のユーザの位置情報を取得
## 登録
http://127.0.0.1:8080/locations
{
  "userId": "testaccount",
  "longitude": 0.01,
  "latitude": 0.01,
  "status": "テスト"
}
仕様
POST jsonの値を登録
## 削除
http://127.0.0.1:8080/locations/{ユーザID}
仕様
DELETE 任意のユーザの位置情報を全件削除
