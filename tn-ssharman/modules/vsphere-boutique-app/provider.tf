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
  }
}