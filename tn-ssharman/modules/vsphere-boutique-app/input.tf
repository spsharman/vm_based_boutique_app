variable "application_name" {
  type = string
}

variable "vmware_datacenter_id" {
  type = string
}

variable "vmware_datastore_id" {
  type = string
}

variable "vmware_resource_pool_id" {
  type = string
}

variable "vmware_folder_path" {
  type = string
}

variable "vmware_scsi_type" {
  type = string
}

variable "vmware_network_adapter_type" {
  type = string
}

variable "vmware_vm_template_id" {
  type = string
}

variable "boutique_app_service" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "subnet_bits" {
  type = string
}

variable "gateway" {
  type = string
}

variable "nameserver" {
  type = string
}

variable "domain" {
  type = string
}

variable "num_cpus" {
  type = string
  default = 2
}

variable "memory" {
  type = string
  default = 2048
}

variable "disk_gb" {
  type = string
  default = 20
}
variable "vm_port_group" {
  type = string
}

variable "service_ip_addresses" {
  description = "Boutique app service IPs"
}

variable "vmware_vds_switch_name" {
}