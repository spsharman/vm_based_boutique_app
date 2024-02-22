output "network_id" {
  value = data.vsphere_network.demo_network.id
}

output "cloud_init_metadata_rendered" {
  value = data.template_file.cloud_init_metadata.rendered
}

output "cloud_init_userdata_rendered" {
  value = data.template_file.cloud_init_userdata.rendered
}