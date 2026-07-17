variable "image_name" {
  description = "Locally built Docker image, including its tag."
  type        = string
}

variable "container_name" {
  description = "Name assigned to the deployed application container."
  type        = string
  default     = "local-cicd-app"
}

variable "host_port" {
  description = "Host port used to reach the application."
  type        = number
  default     = 5000
}
