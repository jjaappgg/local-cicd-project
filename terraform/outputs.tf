output "application_url" {
  description = "URL of the deployed application."
  value       = "http://localhost:${var.host_port}"
}

output "container_id" {
  description = "Docker ID of the deployed container."
  value       = docker_container.application.id
}
