variable "region" {
  description = "Deployment region"
  default = "Central Us"
}

variable "VMRG" {
  description = "Resource group to deploy VM"
  default = "SHW-BBCT-CICD-RG"
}

variable "vm_name" {
  description = "Enter desired name of VM"
  type = "string"
  default = "WIN-VM-CUS"
}
variable "vm_size" {
  description = "Enter the Size of VMs"
  default = "Standard_D4_v3"
}

variable "admin_username" {
  description = "Admin user name for VM"
  default = "vignoadmin"
}

variable "count_of_VMs" {
  description = "Number of VMs you want to create as part of this deployment"
  default = 1
}

variable "VnetRG" {
  description = "Name of Virtual network resource group"
  default = "SHAWAUTH-VIGNO-CICD-T-RG"
}

variable "VnetName" {
  description = "Name of Virtual Network"
  default = "SHAW-AUTH-VIGNO-CICD-T-vnet"
}

variable "SubnetName" {
  description = "Name of Subnet"
  default = "shaw-auth-vigno-cicd-t-sn"
}

variable "KeyVaultName" {
  description = "Name of Key Vault"
  default = "shwvignointervault"
}

variable "KeyVaultRG" {
  description = "Resource group of key vault"
  default = "SHW-INT-VIGCICD-RG"
}

variable "BootDiagnosticsStorageAccount" {
  description = "Storage account to store VM boot diagnostics"
  default = "sysbootdiag"
}

variable "BootDiagnosticsStorageResourceGroup" {
  description = "Resource group of boot diagnostics storage account"
  default = "SHW-INT-VIGCICD-RG"
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
