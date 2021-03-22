// A variable for extracting the external IP address of the instance
output "ip" {
 value = google_compute_instance.*.network_interface.0.access_config.0.nat_ip
}
#output "ip-prod" {
# value = google_compute_instance.default[1].network_interface.0.access_config.0.nat_ip
#}