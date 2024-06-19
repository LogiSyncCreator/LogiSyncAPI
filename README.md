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
