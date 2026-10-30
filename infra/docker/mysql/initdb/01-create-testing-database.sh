#!/bin/bash
# テスト用の DB(testing)を作成し、アプリ用のユーザーに権限を付与する
set -euo pipefail

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`testing\`;
GRANT ALL PRIVILEGES ON \`testing\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL
