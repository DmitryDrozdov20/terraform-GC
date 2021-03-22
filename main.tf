terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.60.0"
    }
  }
}

provider "google" {
  # Configuration options
  # node_count = var.node_count
  credentials = file("cred-gcp.json")
  project     = "silken-realm-307723"
  region      = var.region
  zone      = var.zone
  #credentials = var.google_credentials
  }

#variable "google_credentials" {
#  description = "the contents of a service account key file in JSON format."
#  type = string
#}

resource "google_compute_address" "vm_static_ip" {
  count = var.node_count
  name = element(tolist(var.instance_tags), count.index)
}

resource "google_compute_instance" "default" {
  #name         = "stage"
  count = var.node_count
  name = element(tolist(var.instance_tags), count.index)
  # name = var.instance_tags
  

  # name = var.instance_tags
  machine_type = var.machine_type // 2vCPU, 2GB RAM
  #machine_type = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM
  

  allow_stopping_for_update = true

  boot_disk {
    auto_delete = "true"
    initialize_params {
      size = "10"
      type = "pd-balanced" // Available options: pd-standard, pd-balanced, pd-ssd
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  // Startup script - update, install python3-pip (for Ansible) 
  metadata_startup_script = "sudo apt-get update; sudo apt-get install python3-pip -y"

  network_interface {
  network = "default"

  access_config {
    nat_ip = google_compute_address.vm_static_ip[count.index].address
    }
  }

  metadata = {
    ssh-keys = "root:${file("id_rsa.pub")}" // Copy ssh public key
  }
}  