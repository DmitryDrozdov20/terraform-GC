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
  credentials = file("cred-gcp.json")
  project     = "silken-realm-307723"
  region      = "europe-north1"
  zone      = "europe-north1-a"
  #credentials = var.google_credentials
  }

#variable "google_credentials" {
#  description = "the contents of a service account key file in JSON format."
#  type = string
#}

resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}

resource "google_compute_instance" "stage" {
  name         = "stage"
  machine_type = "e2-small" // 2vCPU, 2GB RAM
  #machine_type = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM

  #tags = ["terraform", "template"]
  allow_stopping_for_update = true

  boot_disk {
    auto_delete = "yes"
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
    nat_ip = google_compute_address.vm_static_ip.address
    }
  }

  #metadata = {
  #  ssh-keys = "root:${file("/root/.ssh/id_rsa.pub")}" // Copy ssh public key
  #}

provider "google" {
  # Configuration options
  credentials = file("cred-gcp.json")
  project     = "silken-realm-307723"
  region      = "europe-north1"
  zone      = "europe-north1-a"
  #credentials = var.google_credentials
  }

  #variable "google_credentials" {
  #  description = "the contents of a service account key file in JSON format."
  #  type = string
  #}

 resource "google_compute_address" "vm_static_ip" {
  name = "terraform-static-ip"
}
  resource "google_compute_instance" "prod" {
  name         = "prod"
  machine_type = "e2-small" // 2vCPU, 2GB RAM
  #machine_type = "e2-medium" // 2vCPU, 4GB RAM
  #machine_type = "custom-6-20480" // 6vCPU, 20GB RAM
  #machine_type = "custom-2-15360-ext" // 2vCPU, 15GB RAM

  #tags = ["terraform", "template"]
  allow_stopping_for_update = true

  boot_disk {
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
    nat_ip = google_compute_address.vm_static_ip.address
    }
  }

  #metadata = {
  #  ssh-keys = "root:${file("/root/.ssh/id_rsa.pub")}" // Copy ssh public key
  #}
}