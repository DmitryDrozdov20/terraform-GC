terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.61.0"
    }
  }
}

provider "google" {
  credentials = file("cred-gcp.json")
  project     = "silken-realm-307723"
  region      = var.region
  zone      = var.zone
  }

resource "google_compute_address" "vm_stage_ip" {
  name = vm_stage_ip
  #count = var.node_count
  #name = element(tolist(var.instance_tags), count.index)
}

resource "google_compute_instance" "vm_stage" {
  name = stage
  # count = var.node_count
  # name = element(tolist(var.instance_tags), count.index)
  machine_type = var.machine_type // 2vCPU, 2GB RAM
  
  allow_stopping_for_update = true

  boot_disk {
    auto_delete = "true"
    initialize_params {
      size = "10"
      type = "pd-balanced" // Available options: pd-standard, pd-balanced, pd-ssd
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Startup script - update, install python3-pip (for Ansible) 
  metadata_startup_script = "sudo apt-get update; sudo apt-get install python3-pip -y"

  network_interface {
  network = "default"

  access_config {
    nat_ip = google_compute_address.vm_stage_ip.address
    }
  }

  metadata = {
    ssh-keys = "root:${file("id_rsa.pub")}" // Copy ssh public key
    }
  }  

# Static IP VM for Ansible
output "stage_ip" {
 value = google_compute_instance.vm_stage.network_interface.0.access_config.0.nat_ip
}
# Waiting_30s 
resource  "time_sleep" "wait_30_seconds" {
  depends_on = [google_compute_instance.vm_stage]

  create_duration = "30s"
}

# create inventory file after 30s
resource "null_resource" "ansible_hosts_provisioner" {
   depends_on = [time_sleep.wait_30_seconds]
  provisioner "local-exec" {
    interpreter = ["/bin/bash" ,"-c"]
    command = <<EOT
      cat <<EOF >./inventory/hosts
[staging] 
$(terraform output stage_ip)
[prod]
$(terraform output stage_ip)
EOF
      export ANSIBLE_HOST_KEY_CHECKING=False
    EOT
  }
}
# run playbook on created hosts
resource "null_resource" "ansible_playbook_provisioner" {
  depends_on = [null_resource.ansible_hosts_provisioner]
  provisioner "local-exec" {
    command = "ansible-playbook -i ./inventory/hosts playbook.yml"
  }
}