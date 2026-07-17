terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.5"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

data "docker_image" "application" {
  name = var.image_name
}

resource "docker_container" "application" {
  name  = var.container_name
  image = data.docker_image.application.id

  must_run = true
  restart  = "unless-stopped"

  ports {
    internal = 5000
    external = var.host_port
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }

  labels {
    label = "project"
    value = "local-cicd-pipeline"
  }
}
