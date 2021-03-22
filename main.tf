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
  count = var.node_count
  name = element(tolist(var.instance_tags), count.index)
  machine_type = var.machine_type
  
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

  output "ip-stage" {
    value = google_compute_instance.default[0].network_interface.0.access_config.0.nat_ip
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_compute_instance.default]

  create_duration = "30s" // Change to 90s
}

resource "null_resource" "ansible_hosts_provisioner" {
  depends_on = [time_sleep.wait_30_seconds]
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = <<EOT
      export ip-stage=$(terraform output ip-stage);
      echo $ip-stage;
      sed -i -e "s/staging_instance_ip/$ip-stage/g" ./inventory/hosts;
      sed -i -e 's/"//g' ./inventory/hosts;
      export ANSIBLE_HOST_KEY_CHECKING=False
    EOT
  }
}

resource "time_sleep" "wait_5_seconds" {
  depends_on = [null_resource.ansible_hosts_provisioner]

  create_duration = "5s"
}

resource "null_resource" "ansible_playbook_provisioner" {
  depends_on = [time_sleep.wait_5_seconds]
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory/hosts playbook.yml"
  }
}