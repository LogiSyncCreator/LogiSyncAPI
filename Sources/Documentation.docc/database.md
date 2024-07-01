### `メモ`
- device_token テーブル,device_token テーブルの更新の仕方は
新しいデータをそのまま挿入するだけ

### `chat` テーブル
- **id**: チャットメッセージの一意の識別子(UUID形式)
- **room_id**: チャットルームの識別子(TEXT形式, NOT NULL)
- **user_id**: メッセージを送信したユーザーの識別子(TEXT形式, NOT NULL)
- **body**: メッセージの本文(TEXT形式, NOT NULL)
- **create_at**: メッセージの作成日時(DATE形式, NOT NULL)
- **mention**: メンションされた回数(INTEGER形式, NOT NULL)

### `chat_room` テーブル
- **id**: チャットルームの一意の識別子(UUID形式)
- **room_id**: チャットルームの識別子(TEXT形式, NOT NULL)
- **user_id**: ルームに参加しているユーザーの識別子(TEXT形式, NOT NULL)
- **mention**: メンションされた回数(INTEGER形式, NOT NULL)

### `custom_status` テーブル
- **id**: カスタムステータスの一意の識別子(UUID形式)
- **manager_id**: ステータスを管理するユーザーの識別子(TEXT形式, NOT NULL)
- **shipper_id**: 運送業者の識別子(TEXT形式, NOT NULL)
- **name**: ステータスの名前(TEXT形式, NOT NULL)
- **delete**: 削除フラグ(INTEGER形式, NOT NULL)
- **color**: ステータスの色(TEXT形式, NOT NULL)
- **icon**: ステータスのアイコン(TEXT形式, NOT NULL)
- **index**: インデックス(INTEGER形式)

### `device_token` テーブル
- **id**: デバイストークンの一意の識別子(UUID形式)
- **user_id**: トークンが紐づくユーザーの識別子(TEXT形式, NOT NULL)
- **token**: デバイスのトークン(TEXT形式, NOT NULL)
- **update_at**: トークンの最終更新日時(DATE形式, NOT NULL)

### `location` テーブル
- **id**: 位置情報の一意の識別子(UUID形式)
- **user_id**: 位置情報が紐づくユーザーの識別子(TEXT形式, NOT NULL)
- **longitude**: 経度(DOUBLE形式, NOT NULL)
- **latitude**: 緯度(DOUBLE形式, NOT NULL)
- **create_at**: 位置情報の作成日時(DATE形式, NOT NULL)
- **status**: 状態(TEXT形式, NOT NULL)
- **delete**: 削除フラグ(INTEGER形式, NOT NULL)

### `matching` テーブル
- **id**: マッチングの一意の識別子(UUID形式)
- **manager_id**: マッチングを管理するユーザーの識別子(TEXT形式, NOT NULL)
- **shipper_id**: 運送業者の識別子(TEXT形式, NOT NULL)
- **driver_id**: 運転手の識別子(TEXT形式, NOT NULL)
- **start_date**: マッチングが開始された日付(DATE形式, NOT NULL)
- **address**: マッチングの場所(TEXT形式, NOT NULL)
- **delete**: 削除フラグ(INTEGER形式, NOT NULL)

### `now_status` テーブル
- **id**: 現在のステータスの一意の識別子(UUID形式)
- **user_id**: ステータスが紐づくユーザーの識別子(TEXT形式, NOT NULL)
- **status_id**: ステータスの識別子(TEXT形式, NOT NULL)
- **update_at**: ステータスの最終更新日時(DATE形式, NOT NULL)
- **delete**: 削除フラグ(INTEGER形式, NOT NULL)

### `thumbnail` テーブル
- **id**: サムネイルの一意の識別子(UUID形式)
- **user_id**: サムネイルが紐づくユーザーの識別子(TEXT形式, NOT NULL)
- **thumbnail**: サムネイルの画像のパス(TEXT形式, NOT NULL)
- **update_at**: サムネイルの最終更新日時(DATE形式, NOT NULL)
- **delete**: 削除フラグ(INTEGER形式, NOT NULL)

### `users` テーブル
- **id**: ユーザーの一意の識別子(UUID形式)
- **name**: ユーザーの名前(TEXT形式, NOT NULL)
- **company**: 所属会社(TEXT形式, NOT NULL)
- **role**: ユーザーの役職(TEXT形式, NOT NULL)
- **user_id**: ユーザーID(TEXT形式, NOT NULL)
- **user_pass**: ユーザーのパスワード(TEXT形式, NOT NULL)
- **phone**: ユーザーの電話番号(TEXT形式, NOT NULL)
- **profile**: ユーザーのプロフィール(TEXT形式, NOT NULL)
- **delete**: 削除フラグ(INTEGER形式, NOT NULL)

