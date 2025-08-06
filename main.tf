# # プロバイダーの初期化
# terraform init

# # プランの確認
# terraform plan

# # ネットワーク、ボリューム作成、イメージ構築、コンテナ起動
# terraform apply -auto-approve

# # コード更新後のイメージ再構築
# terraform apply -replace=docker_image.app -auto-approve

# # コンテナの停止と削除
# terraform destroy -auto-approve
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
  required_version = "~> 1.7"
}

provider "docker" {
  # デフォルトでローカルDockerに接続。
  # カスタマイズが必要な場合：環境変数 DOCKER_HOST、DOCKER_TLS_VERIFY、DOCKER_CERT_PATH。
}

# アプリケーション専用ネットワークとデータボリューム
resource "docker_network" "app" {
  name = var.network_name
}

resource "docker_volume" "data" {
  name = var.volume_name
}

# アプリケーションイメージの構築
resource "docker_image" "app" {
  name         = "${var.image_name}:${var.image_tag}"
  keep_locally = true

  build {
    context    = "${path.module}/app"
    dockerfile = "Dockerfile"
    platform   = var.image_platform # e.g. linux/amd64 或 linux/arm64
    no_cache   = false
  }
}

# コンテナの実行
resource "docker_container" "app" {
  name    = var.container_name
  image   = docker_image.app.name
  restart = "always"

  # ポートマッピング：ローカル var.host_ip:var.external_port -> コンテナ 8000
  ports {
    internal = 8000
    external = var.external_port
    ip       = var.host_ip
  }

  # ネットワークに参加
  networks_advanced {
    name = docker_network.app.name
  }

  # データボリュームのマウント（必要に応じて使用）
  mounts {
    target = "/app/data"
    source = docker_volume.data.name
    type   = "volume"
  }

  # 環境変数（FastAPI/uvicornパラメータと組み合わせ可能）
  env = [
    "ENV=prod",
  ]

  # シンプルなヘルスチェック（/bin/sh + wgetを使用、curlに依存しない）
  healthcheck {
    test         = ["CMD-SHELL", "wget -qO- http://127.0.0.1:8000/healthz >/dev/null 2>&1 || exit 1"]
    interval     = "30s"
    timeout      = "3s"
    retries      = 3
    start_period = "10s"
  }
}
