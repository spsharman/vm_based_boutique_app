terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.6.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.1.2"
    }
  }
}

########### Providers ###########
provider "vsphere" {
  user                 = "<USERNAME>"
  password             = "<PASSWORD>"
  vsphere_server       = "<VCENTER IP OR FQDN>"
  vim_keep_alive       = 30
  allow_unverified_ssl = true
}

########### Locals ###########
locals {}
