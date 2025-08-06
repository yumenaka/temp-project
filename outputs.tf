output "container_name" {
  value = docker_container.app.name
}

output "image_built" {
  value = docker_image.app.name
}

output "service_url" {
  value = "http://${var.host_ip}:${var.external_port}"
}
