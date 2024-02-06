data "vsphere_network" "demo_network" {
  name          = var.vm_port_group
  datacenter_id = var.vmware_datacenter_id
}

# VM runcmd boot script
data "template_file" "runcmd_script" {
  template = file("${path.module}/templates/runcmd.tpl")

  vars = {
    customerName = var.application_name
    domain = var.domain
  }
}

# VM resize rootfs script
data "template_file" "resize_rootfs_script" {
  template = file("${path.module}/templates/resize_rootfs.tpl")
}

# VM nginx script
data "template_file" "nginx_script" {
  template = file("${path.module}/templates/nginx.tpl")
}

# VM metadata
data "template_file" "cloud_init_metadata" {
  template = file("${path.module}/templates/metadata.tpl")

  vars = {
    ipAddress = var.ip_address
    subnetBits = var.subnet_bits
    gateway = var.gateway
    nameserver = var.nameserver
    domain = var.domain
  }
}

data "template_file" "cloud_init_userdata" {
  template = file("${path.module}/templates/userdata/${var.boutique_app_service}-userdata.tpl")
  vars = {
    boutique_app_service = var.boutique_app_service
    domain = var.domain
    runcmdScript = data.template_file.runcmd_script.rendered
    resizeRootfs = data.template_file.resize_rootfs_script.rendered
    nginxScript = data.template_file.nginx_script.rendered
    redisIp = var.service_ip_addresses.redis_ip
    productCatalogServiceAddr = var.service_ip_addresses.productcatalogservice_ip
    shippingServiceAddr = var.service_ip_addresses.shippingservice_ip
    paymentServiceAddr = var.service_ip_addresses.paymentservice_ip
    emailServiceAddr = var.service_ip_addresses.emailservice_ip
    currencyServiceAddr = var.service_ip_addresses.currencyservice_ip
    cartServiceAddr = var.service_ip_addresses.cartservice_ip
    checkoutServiceAddr = var.service_ip_addresses.checkoutservice_ip
    adServiceAddr = var.service_ip_addresses.adservice_ip
    recommendationServiceAddr = var.service_ip_addresses.recommendationservice_ip
    envPlatform = "onprem"
    customerName = var.application_name
  }
}



# # Create VMs
resource "vsphere_virtual_machine" "vm_application_servers" {

  name             = "${var.application_name}-${var.boutique_app_service}"
  resource_pool_id = var.vmware_resource_pool_id
  datastore_id     = var.vmware_datastore_id
  folder           = var.vmware_folder_path

  num_cpus = var.num_cpus
  memory   = var.memory
  guest_id = "ubuntu64Guest"

  scsi_type = var.vmware_scsi_type

  cdrom {
    client_device = true
  }

  network_interface {
    network_id   = data.vsphere_network.demo_network.id
    adapter_type = var.vmware_network_adapter_type
  }

  disk {
    label            = "vm-disk"
    thin_provisioned = true
    eagerly_scrub    = false
    size             = var.disk_gb
  }

  clone {
    template_uuid = var.vmware_vm_template_id
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(data.template_file.cloud_init_metadata.rendered)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(data.template_file.cloud_init_userdata.rendered)
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      clone.0.template_uuid
    ]
  }

  depends_on = [ 
    data.template_file.cloud_init_metadata,
    data.template_file.cloud_init_userdata
  ]
}