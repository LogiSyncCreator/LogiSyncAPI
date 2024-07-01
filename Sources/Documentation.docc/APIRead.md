#  APIの基本的な読み方
## エンドポイントを知りたいときはコントローラーを覗く
- 読み方はControllers/TodoController参照


## DTOについて
- 読み方はControllers/TodoController参照

## Modelについて
- @ID,@TimeStampについては自動入力
    - 入力しても自動入力の方が優先されるっぽい...

## 環境設定について
- env.swift内のEnvData()にipアドレスやポートの設定を行う

## キーの設定について
- keyファイルを手渡しするのでenv.swiftと同じ場所においてください
- APNS関連の内容がconfigureやPushControllerにあるのでコメントアウトしてください。（コミット時に差分をコミットしないように注意してください）
