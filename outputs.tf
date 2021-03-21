// A variable for extracting the external IP address of the instance
output "ip" {
 value = google_compute_instance.stage.network_interface.0.access_config.0.nat_ip
 value = google_compute_instance.prod.network_interface.0.access_config.0.nat_ip
}