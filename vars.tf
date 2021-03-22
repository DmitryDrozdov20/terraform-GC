variable "node_count" {
  default = "2"
}

variable "instance_tags" {
  type    = list(string)
  default = ["stage", "prod"]
}

variable "machine_type" {
  default = "e2-small" // 2vCPU, 2GB RAM
  # "e2-medium"        // 2vCPU, 4GB RAM
  # "custom-4-4096"    // 4vCPU, 4GB RAM
  # "custom-4-8192"    // 4vCPU, 8GB RAM
}

variable "region" {
  default = "europe-north1"
}

variable "zone" {
  default = "europe-north1-a"
}
