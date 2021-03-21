variable "node_count" {
  default = "2"
}

variable "instance_tags" {
  default = ["stage", "prod"]
}

variable "machine_type" {
  default = "e2-small"
}

variable "region" {
  default = "europe-north1"
}

variable "zone" {
  default = "europe-north1-a"
}
