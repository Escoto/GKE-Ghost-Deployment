
variable "public_lb_ip" {}

resource "kubernetes_service" "app" {
  metadata {
    name = "app"
  }

  spec {
    selector = {
      run = "app"
    }

    type             = "NodePort"
    external_ips     = [var.public_lb_ip]
    session_affinity = "ClientIP"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 2368
      node_port   = 30000
    }

  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"

    labels = {
      run = "app"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    selector {
      match_labels = {
        run = "app"
      }
    }

    template {
      metadata {
        name = "app"
        labels = {
          run = "app"
        }
      }

      spec {
        container {
          image = "ghost:alpine"
          name  = "app"

          port {
            container_port = 2368
          }

          env {
            name  = "url"
            value = "http://${var.public_lb_ip}:80"
          }

          /*
          * 
          * Ghost needs a database to work properly
          * I am not configuring a db on this example but here you would add:
          * "database__client" -  "mysql"
          * "database__connection__host" - server ip
          * "database__connection__user" - user
          * "database__connection__password" - psw
          * "database__connection__database" - databse name
          * 
          */

        }
      }
    }
  }
}
