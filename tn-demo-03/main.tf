locals {
  model = yamldecode(file("${path.module}/data/boutique-app.yaml"))
}

data "vsphere_datacenter" "demo_dc" {
  name = local.model.vmware_environment.datacenter
}

data "vsphere_datastore" "demo_datastore" {
  name          = local.model.vmware_environment.datastore
  datacenter_id = data.vsphere_datacenter.demo_dc.id
}

data "vsphere_resource_pool" "demo_pool" {
  name          = local.model.vmware_environment.resource_pool
  datacenter_id = data.vsphere_datacenter.demo_dc.id
}

data "vsphere_virtual_machine" "demo_template" {
  name          = local.model.vmware_environment.vm_template_name
  datacenter_id = data.vsphere_datacenter.demo_dc.id
}

# Create vsphere folder
resource "vsphere_folder" "boutique_app_folder" {
  path          = "${local.model.vmware_environment.vm_parent_folder}/${local.model.application_name}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.demo_dc.id
}

module "vm_non_dependent_services" {
  for_each = local.model.boutique-app.non_dependent_services
  source   = "./modules/vsphere-boutique-app"
    
  application_name = local.model.application_name
  vmware_datacenter_id = data.vsphere_datacenter.demo_dc.id
  vmware_datastore_id = data.vsphere_datastore.demo_datastore.id
  vmware_resource_pool_id = data.vsphere_resource_pool.demo_pool.id
  vmware_vds_switch_name = local.model.vmware_environment.vds_switch_name
  vmware_folder_path = resource.vsphere_folder.boutique_app_folder.path
  vmware_scsi_type = data.vsphere_virtual_machine.demo_template.scsi_type
  vmware_network_adapter_type = data.vsphere_virtual_machine.demo_template.network_interface_types[0]
  vmware_vm_template_id = data.vsphere_virtual_machine.demo_template.id
  boutique_app_service = each.key
  ip_address = each.value["ip_address"]
  subnet_bits = each.value["subnet_bits"]
  gateway = each.value["gateway"]
  nameserver = each.value["nameserver"]
  domain = each.value["domain"]
  num_cpus = each.value["num_cpus"]
  memory = each.value["memory"]
  disk_gb = each.value["disk_gb"]
  vm_port_group = each.value["vm_port_group"]

  service_ip_addresses = {
    adservice_ip = local.model.boutique-app.non_dependent_services.adservice.ip_address
    redis_ip = local.model.boutique-app.non_dependent_services.redis.ip_address
    emailservice_ip = local.model.boutique-app.non_dependent_services.emailservice.ip_address
    paymentservice_ip = local.model.boutique-app.non_dependent_services.paymentservice.ip_address
    shippingservice_ip = local.model.boutique-app.non_dependent_services.shippingservice.ip_address
    currencyservice_ip = local.model.boutique-app.non_dependent_services.currencyservice.ip_address
    productcatalogservice_ip = local.model.boutique-app.non_dependent_services.productcatalogservice.ip_address
    cartservice_ip = local.model.boutique-app.dependent_services.cartservice.ip_address
    checkoutservice_ip = local.model.boutique-app.dependent_services.checkoutservice.ip_address
    recommendationservice_ip = local.model.boutique-app.dependent_services.recommendationservice.ip_address
    frontend_ip = local.model.boutique-app.frontend_services.frontend.ip_address
    # loadgenerator_ip = local.model.boutique-app.frontend_services.loadgenerator.ip_address
  }
}

module "vm_dependent_services" {
  for_each = local.model.boutique-app.dependent_services
  source = "./modules/vsphere-boutique-app"

  application_name = local.model.application_name
  vmware_datacenter_id = data.vsphere_datacenter.demo_dc.id
  vmware_datastore_id = data.vsphere_datastore.demo_datastore.id
  vmware_resource_pool_id = data.vsphere_resource_pool.demo_pool.id
  vmware_vds_switch_name = local.model.vmware_environment.vds_switch_name
  vmware_folder_path = resource.vsphere_folder.boutique_app_folder.path
  vmware_scsi_type = data.vsphere_virtual_machine.demo_template.scsi_type
  vmware_network_adapter_type = data.vsphere_virtual_machine.demo_template.network_interface_types[0]
  vmware_vm_template_id = data.vsphere_virtual_machine.demo_template.id
  boutique_app_service = each.key
  ip_address = each.value["ip_address"]
  subnet_bits = each.value["subnet_bits"]
  gateway = each.value["gateway"]
  nameserver = each.value["nameserver"]
  domain = each.value["domain"]
  num_cpus = each.value["num_cpus"]
  memory = each.value["memory"]
  disk_gb = each.value["disk_gb"]
  vm_port_group = each.value["vm_port_group"]

  service_ip_addresses = {
    adservice_ip = local.model.boutique-app.non_dependent_services.adservice.ip_address
    redis_ip = local.model.boutique-app.non_dependent_services.redis.ip_address
    emailservice_ip = local.model.boutique-app.non_dependent_services.emailservice.ip_address
    paymentservice_ip = local.model.boutique-app.non_dependent_services.paymentservice.ip_address
    shippingservice_ip = local.model.boutique-app.non_dependent_services.shippingservice.ip_address
    currencyservice_ip = local.model.boutique-app.non_dependent_services.currencyservice.ip_address
    productcatalogservice_ip = local.model.boutique-app.non_dependent_services.productcatalogservice.ip_address
    cartservice_ip = local.model.boutique-app.dependent_services.cartservice.ip_address
    checkoutservice_ip = local.model.boutique-app.dependent_services.checkoutservice.ip_address
    recommendationservice_ip = local.model.boutique-app.dependent_services.recommendationservice.ip_address
    frontend_ip = local.model.boutique-app.frontend_services.frontend.ip_address
    # loadgenerator_ip = local.model.boutique-app.frontend_services.loadgenerator.ip_address
  }

  depends_on = [ 
    module.vm_non_dependent_services
  ]
}

module "vm_frontend_services" {
  for_each = local.model.boutique-app.frontend_services
  source = "./modules/vsphere-boutique-app"

  application_name = local.model.application_name
  vmware_datacenter_id = data.vsphere_datacenter.demo_dc.id
  vmware_datastore_id = data.vsphere_datastore.demo_datastore.id
  vmware_resource_pool_id = data.vsphere_resource_pool.demo_pool.id
  vmware_vds_switch_name = local.model.vmware_environment.vds_switch_name
  vmware_folder_path = resource.vsphere_folder.boutique_app_folder.path
  vmware_scsi_type = data.vsphere_virtual_machine.demo_template.scsi_type
  vmware_network_adapter_type = data.vsphere_virtual_machine.demo_template.network_interface_types[0]
  vmware_vm_template_id = data.vsphere_virtual_machine.demo_template.id
  boutique_app_service = each.key
  ip_address = each.value["ip_address"]
  subnet_bits = each.value["subnet_bits"]
  gateway = each.value["gateway"]
  nameserver = each.value["nameserver"]
  domain = each.value["domain"]
  num_cpus = each.value["num_cpus"]
  memory = each.value["memory"]
  disk_gb = each.value["disk_gb"]
  vm_port_group = each.value["vm_port_group"]

  service_ip_addresses = {
    adservice_ip = local.model.boutique-app.non_dependent_services.adservice.ip_address
    redis_ip = local.model.boutique-app.non_dependent_services.redis.ip_address
    emailservice_ip = local.model.boutique-app.non_dependent_services.emailservice.ip_address
    paymentservice_ip = local.model.boutique-app.non_dependent_services.paymentservice.ip_address
    shippingservice_ip = local.model.boutique-app.non_dependent_services.shippingservice.ip_address
    currencyservice_ip = local.model.boutique-app.non_dependent_services.currencyservice.ip_address
    productcatalogservice_ip = local.model.boutique-app.non_dependent_services.productcatalogservice.ip_address
    cartservice_ip = local.model.boutique-app.dependent_services.cartservice.ip_address
    checkoutservice_ip = local.model.boutique-app.dependent_services.checkoutservice.ip_address
    recommendationservice_ip = local.model.boutique-app.dependent_services.recommendationservice.ip_address
    frontend_ip = local.model.boutique-app.frontend_services.frontend.ip_address
    # loadgenerator_ip = local.model.boutique-app.frontend_services.loadgenerator.ip_address
  }

  depends_on = [ 
    module.vm_non_dependent_services,
    module.vm_dependent_services
  ]
}

# output "data_model" {
#   value = local.model
# }

# output "module_data" {
#   value = module.vm_dependent_services
# }

