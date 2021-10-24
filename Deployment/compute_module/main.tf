
variable "region" {}

variable "network" {}

variable "sub_network" {}

variable "cluster_name" {}

variable "tags" {}

resource "google_container_cluster" "gke_cluster" {
  name               = var.cluster_name
  location           = var.region // Making it regional
  initial_node_count = 1
  network            = var.network
  subnetwork         = var.sub_network
  enable_legacy_abac = true

  node_config {
    tags = var.tags
  }
}

// Hodcoded number of named ports work for the example - I am using 2 regions, each with 3 zones and each with one instance group
resource "google_compute_instance_group_named_port" "named_port_0" {
  group = google_container_cluster.gke_cluster.instance_group_urls[0]
  name  = "http"
  port  = 30000
}

resource "google_compute_instance_group_named_port" "named_port_1" {
  group = google_container_cluster.gke_cluster.instance_group_urls[1]
  name  = "http"
  port  = 30000
}

resource "google_compute_instance_group_named_port" "named_port_2" {
  group = google_container_cluster.gke_cluster.instance_group_urls[2]
  name  = "http"
  port  = 30000
}

output "instance_groups" {
  value = google_container_cluster.gke_cluster.instance_group_urls
}

output "endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "client_certificate" {
  value = google_container_cluster.gke_cluster.master_auth[0].client_certificate
}

output "client_key" {
  value = google_container_cluster.gke_cluster.master_auth[0].client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate
}
