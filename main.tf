# # 初始化 provider
# terraform init

# # 查看计划
# terraform plan

# # 创建网络、卷、构建镜像并启动容器
# terraform apply -auto-approve

# # 代码更新后镜像重建
# terraform apply -replace=docker_image.app -auto-approve


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
  # 默认连接到本机 Docker。
  # 如需自定义：环境变量 DOCKER_HOST、DOCKER_TLS_VERIFY、DOCKER_CERT_PATH。
}

# 应用专用网络与数据卷
resource "docker_network" "app" {
  name = var.network_name
}

resource "docker_volume" "data" {
  name = var.volume_name
}

# 构建应用镜像
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

# 运行容器
resource "docker_container" "app" {
  name    = var.container_name
  image   = docker_image.app.name
  restart = "always"

  # 端口映射：将本机 var.host_ip:var.external_port -> 容器 8000
  ports {
    internal = 8000
    external = var.external_port
    ip       = var.host_ip
  }

  # 加入网络
  networks_advanced {
    name = docker_network.app.name
  }

  # 挂载数据卷（按需使用）
  mounts {
    target = "/app/data"
    source = docker_volume.data.name
    type   = "volume"
  }

  # 环境变量（可与 FastAPI/uvicorn 参数结合）
  env = [
    "ENV=prod",
  ]

  # 简单健康检查（使用 /bin/sh + wget，不依赖 curl）
  healthcheck {
    test         = ["CMD-SHELL", "wget -qO- http://127.0.0.1:8000/healthz >/dev/null 2>&1 || exit 1"]
    interval     = "30s"
    timeout      = "3s"
    retries      = 3
    start_period = "10s"
  }
}
