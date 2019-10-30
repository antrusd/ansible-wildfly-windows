variable "region" {
  description = "Deployment region"
  default = "Central Us"
}

variable "VMRG" {
  description = "Resource group to deploy VM"
  default = "SHAW-AUTH-CICD-RG"
}

variable "vm_name" {
    description = "Enter desired name of VM"
    type = "string"
    default = "DEV-JBVM-CUS"
}

variable "vm_size" {
  description = "Enter the Size of VMs"
  default = "Standard_D4_v3"
}

variable "admin_username" {
  description = "Admin user name for VM"
  default = "vignoadmin "
}

variable "count_of_VMs" {
  description = "Number of VMs you want to create as part of this deployment"
  default = "1"
}

variable "VnetRG" {
  description = "Name of Virtual network resource group"
  default = "SHAW-AUTH-CICD-RG"
}

variable "VnetName" {
  description = "Name of Virtual Network"
  default = "SHAW-AUTH-CICD-vnet"
}

variable "SubnetName" {
  description = "Name of Subnet"
  default = "shaw-auth-cicd-sn"
}

variable "KeyVaultName" {
  description = "Name of Key Vault"
  default = "shawvault"
}

variable "KeyVaultRG" {
  description = "Resource group of key vault"
  default = "SHAW-AUTH-CICD-RG"
}

variable "BootDiagnosticsStorageAccount" {
  description = "Storage account to store VM boot diagnostics"
  default = "bootdiagtf"
}

variable "BootDiagnosticsStorageResourceGroup" {
  description = "Resource group of boot diagnostics storage account"
  default = "SHAW-AUTH-CICD-RG"
}

variable "OS_Image_Publisher" {
  description = "Give OS image with which you need to create virtual machines"
  type = "string"
  default = "MicrosoftWindowsServer"
}

variable "OS_Image_Offer" {
  description = "Provide the name of offer for the given publisher"
  type= "string"
  default = "WindowsServer"
}

variable "OS_Image_Sku" {
  description = "Provide the version of sku. Ex:- 2019-Datacenter"
  type = "string"
  default = "2016-Datacenter"
}
