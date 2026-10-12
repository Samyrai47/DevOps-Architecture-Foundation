terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

provider "docker" {
    host = "ssh://deployer@111.88.162.81"
}

resource "docker_network" "nginx_network" {
    name = "nginx-network"
}

resource "docker_volume" "nginx_volume" {
    name = "nginx_volume"
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx"
  
  networks_advanced {
    name = docker_network.nginx_network.name
  }

  mounts {
    target = "/usr/share/nginx/html"
    source = docker_volume.nginx_volume.name
    type   = "volume"
  }

  ports {
    internal = 80
    external = 8047
  }
}
