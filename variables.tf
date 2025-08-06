variable "image_name" {
  type        = string
  default     = "fastapi-app"
  description = "Fast API Image"
}

variable "image_tag" {
  type        = string
  default     = "local"
  description = "image tag"
}

variable "image_platform" {
  type = string
  # Apple Silicon: linux/arm64; 一般的なx86_64: linux/amd64
  default     = "linux/arm64"
  description = "イメージ構築のプラットフォーム"
}

variable "container_name" {
  type        = string
  default     = "fastapi"
  description = "FastAPI"
}

variable "external_port" {
  type        = number
  default     = 8000
  description = "ローカルマシンにマッピングするポート"
}

variable "host_ip" {
  type        = string
  default     = "127.0.0.1"
  description = "ローカルマシンのみにバインド（空文字列に変更すると外部ネットワークに開放、または0.0.0.0を使用）"
}

variable "network_name" {
  type    = string
  default = "appnet"
}

variable "volume_name" {
  type    = string
  default = "fastapi-data"
}
