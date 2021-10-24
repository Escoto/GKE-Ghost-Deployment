locals {
  region_germany = "europe-west3"

  region_finland = "europe-north1"

  project        = "ghost-gke-multiregion-example"

  vpc_name       = "ghost-vpc"

  target_tag_germany = "ghost-app-germany"
  
  target_tag_finland = "ghost-app-finland"
}

provider "google" {
  region  = local.region_germany
  project = local.project
  version = "3.88.0"
}

data "google_client_config" "current" {}

resource "google_compute_network" "gke_vpc" {
  name                    = local.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet_germany" {
  name                     = "${local.vpc_name}-subnet-germany"
  ip_cidr_range            = "10.10.0.0/20"
  network                  = google_compute_network.gke_vpc.self_link
  region                   = local.region_germany
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "gke_subnet_finland" {
  name                     = "${local.vpc_name}-subnet-finland"
  ip_cidr_range            = "10.20.0.0/20"
  network                  = google_compute_network.gke_vpc.self_link
  region                   = local.region_finland
  private_ip_google_access = true
}

module "cluster_germany" {
  source       = "./compute_module"
  region       = local.region_germany
  cluster_name = "gke-cluster-germany"
  tags         = [local.target_tag_germany]
  network      = google_compute_network.gke_vpc.name
  sub_network  = google_compute_subnetwork.gke_subnet_germany.name
}

module "cluster_finland" {
  source       = "./compute_module"
  region       = local.region_finland
  cluster_name = "gke-cluster-finland"
  tags         = [local.target_tag_finland]
  network      = google_compute_network.gke_vpc.name
  sub_network  = google_compute_subnetwork.gke_subnet_finland.name
}

provider "kubernetes" {
  alias                  = "cluster-germany"
  version                = "1.7.0"
  host                   = module.cluster_germany.endpoint
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(module.cluster_germany.client_certificate)
  client_key             = base64decode(module.cluster_germany.client_key)
  cluster_ca_certificate = base64decode(module.cluster_germany.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "cluster-finland"
  version                = "1.7.0"
  host                   = module.cluster_finland.endpoint
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(module.cluster_finland.client_certificate)
  client_key             = base64decode(module.cluster_finland.client_key)
  cluster_ca_certificate = base64decode(module.cluster_finland.cluster_ca_certificate)
}

module "ghost_deployment_germany" {
  source       = "./ghost_module"
  public_lb_ip = module.gce-lb-http.external_ip
  providers = {
    kubernetes = kubernetes.cluster-germany
  }
}

module "ghost_deployment_finland" {
  source       = "./ghost_module"
  public_lb_ip = module.gce-lb-http.external_ip
  providers = {
    kubernetes = kubernetes.cluster-finland
  }
}

module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google//modules/dynamic_backends"
  name              = "global-gke-loadbalancer"
  project           = local.project
  target_tags       = [local.target_tag_germany, local.target_tag_finland]
  firewall_networks = [local.vpc_name]

  backends = {
    default = {
      description = "Balancing loads between the two kubernetes clusters"
      protocol    = "HTTP"
      port        = 30000  // Node Port
      port_name   = "http" // Named Node Port
      timeout_sec = 10
      enable_cdn  = false

      session_affinity                = "CLIENT_IP"
      affinity_cookie_ttl_sec         = 0
      connection_draining_timeout_sec = 0
      custom_request_headers          = null
      custom_response_headers         = null
      security_policy                 = null

      health_check = {
        check_interval_sec  = 15
        timeout_sec         = null
        healthy_threshold   = 5
        unhealthy_threshold = 10
        request_path        = "/"
        port                = 30000 // Node Port
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }

      groups = [
        {
          group                        = module.cluster_germany.instance_groups[0]
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        },
        {
          group                        = module.cluster_germany.instance_groups[1]
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        },
        {
          group                        = module.cluster_germany.instance_groups[2]
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        },
        {
          group                        = module.cluster_finland.instance_groups[0]
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        },
        {
          group                        = module.cluster_finland.instance_groups[1]
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        },
        {
          group                        = module.cluster_finland.instance_groups[2]
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.8
        },
      ]
    }
  }
}

output "load-balancer-ip" {
  value = "http://${module.gce-lb-http.external_ip}"
}
