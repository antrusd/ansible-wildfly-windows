provider "azurerm" {
  version         = ">= 1.0"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "SHAW-AUTH-CICD-RG"
    storage_account_name = "tsateblob"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

data "azurerm_subnet" "subnet" {
  name                 = "${var.SubnetName}"
  virtual_network_name = "${var.VnetName}"
  resource_group_name  = "${var.VnetRG}"
}

data "azurerm_storage_account" "bootstorage" {
  name                = "${var.BootDiagnosticsStorageAccount}"
  resource_group_name = "${var.BootDiagnosticsStorageResourceGroup}"
}

data "azurerm_key_vault" "keyvault" {
  name                = "${var.KeyVaultName}"
  resource_group_name = "${var.KeyVaultRG}"
}

data "azurerm_key_vault_secret" "serveradminpwd" {
  name         = "serveradminpwd"
  key_vault_id = "${data.azurerm_key_vault.keyvault.id}"
}

#Create Resource Group
resource "azurerm_resource_group" "deployrg" {
  name     = "${var.VMRG}"
  location = "${var.region}"
}

#Create NIC
resource "azurerm_network_interface" "nic" {
  count               = "${var.count_of_VMs}"
  name                = "${var.vm_name}.${count.index}-nic"
  location            = "${azurerm_resource_group.deployrg.location}"
  resource_group_name = "${azurerm_resource_group.deployrg.name}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

#Create Managed Disks
resource "azurerm_managed_disk" "mdisk" {
  count                = "${var.count_of_VMs}"
  name                 = "${var.vm_name}-${count.index}-datadisk"
  location             = "${azurerm_resource_group.deployrg.location}"
  resource_group_name  = "${azurerm_resource_group.deployrg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

#Create Windows Virtual Machine
resource "azurerm_virtual_machine" "Windows_VM" {
  count                 = "${var.OS_Image_Publisher == "MicrosoftWindowsServer" ? var.count_of_VMs : 0 }"
  name                  = "${var.vm_name}-${count.index}"
  resource_group_name   = "${azurerm_resource_group.deployrg.name}"
  location              = "${azurerm_resource_group.deployrg.location}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "${var.vm_size}"

  storage_image_reference {
    publisher = "${var.OS_Image_Publisher}"
    offer     = "${var.OS_Image_Offer}"
    sku       = "${var.OS_Image_Sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_name}-${count.index}-osdisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  storage_data_disk {
    name            = "${element(azurerm_managed_disk.mdisk.*.name, count.index)}"
    managed_disk_id = "${element(azurerm_managed_disk.mdisk.*.id, count.index)}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${element(azurerm_managed_disk.mdisk.*.disk_size_gb, count.index)}"
  }

  os_profile {
    computer_name  = "${var.vm_name}-${count.index}"
    admin_username = "${var.admin_username}"
    admin_password = "${data.azurerm_key_vault_secret.serveradminpwd.value}"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${data.azurerm_storage_account.bootstorage.primary_blob_endpoint}"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

#Custom Extension Script for Windows
resource "azurerm_virtual_machine_extension" "CustomScriptExtension" {
  name                 = "${var.vm_name}-${count.index}-CustomExtension"
  location             = "${azurerm_resource_group.deployrg.location}"
  resource_group_name  = "${azurerm_resource_group.deployrg.name}"
  virtual_machine_name = "${var.vm_name}-${count.index}"
  count                = "${var.count_of_VMs}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"
  depends_on           = ["azurerm_virtual_machine.Windows_VM"]

  settings = <<SETTINGS
  {
    "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
  }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1 -EnableCredSSP -DisableBasicAuth -Verbose"
  }
  PROTECTED_SETTINGS
}

resource "local_file" "hosts" {
  content         = "[${var.VMRG}]\n${join("\n", formatlist("%s ansible_host=%s", "${azurerm_virtual_machine.Windows_VM.*.name}", "${azurerm_network_interface.nic.*.private_ip_address}"))}"
  filename        = "inventories/hosts"
  file_permission = "0644"
}
