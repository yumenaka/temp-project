# Terraform と FastAPI のテスト用プロジェクト

Docker コンテナで FastAPI アプリケーションを実行するための設定。

このプロジェクトは、Terraform と FastAPI の基本的な機能をテストするために使用されます。

```bash
# 初回実行
terraform init

# プランの確認
# terraform plan

# コンテナの起動(初回実行時はイメージのビルドが行われます)。
terraform apply -auto-approve

# コード更新後のイメージ再構築

terraform apply -replace=docker_image.app -auto-approve
```

テスト環境は macOS ARM（linux/arm64）です。
他のプラットフォームで実行する場合は、variables.tf 内の image_platform を変更する必要があるかもしれません（一般的には linux/amd64）。