variable "loc" {}
variable "res_grp_name" {}

variable "linux_disk_chars" {
  type = map(any)
  default = {
    storage_account_type = "Standard_LRS"
    create_option        = "Empty"
    caching              = "ReadWrite"
    disk_size_gb         = 10
  }
}
variable "linux_machine_id" {}
variable "linux_machine_name" {}
