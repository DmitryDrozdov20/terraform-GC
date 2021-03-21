variable "instance_count" {
  default = "2"
}

variable "instance_tags" {
  type = "list"
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