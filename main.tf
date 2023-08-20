module "rgroup-N01545550" {
  source       = "./modules/rgroup-N01545550"
  loc          = "canadacentral"
  res_grp_name = "N01545550-RG"
}

module "network-N01545550" {
  source       = "./modules/network-N01545550"
  loc          = module.rgroup-N01545550.rg_location
  res_grp_name = module.rgroup-N01545550.res_grp_name
  net1_name    = "N01545550-VNET"
  net1_space   = ["10.0.0.0/16"]
  sub1         = "N01545550-SUBNET"
  sub1_space   = ["10.0.0.0/24"]
  nsg1         = "N01545550-NSG"
}

module "common-N01545550" {
  source         = "./modules/common-N01545550"
  loc            = module.rgroup-N01545550.rg_location
  res_grp_name   = module.rgroup-N01545550.res_grp_name
  vault_name     = "recoveryvault5550"
  workspace_name = "5550workspace"
  storage_name   = "5550storage"
}

module "vmlinux-N01545550" {
  source           = "./modules/vmlinux-N01545550"
  loc              = module.rgroup-N01545550.rg_location
  res_grp_name     = module.rgroup-N01545550.res_grp_name
  sub_id           = module.network-N01545550.subnet1_id
  storage_endpoint = module.common-N01545550.storage_endpoint
}

module "datadisk-N01545550" {
  source             = "./modules/datadisk-N01545550"
  loc                = module.rgroup-N01545550.rg_location
  res_grp_name       = module.rgroup-N01545550.res_grp_name
  linux_machine_id   = module.vmlinux-N01545550.linux_machine_id
  linux_machine_name = module.vmlinux-N01545550.linux_machine_name
}

module "loadbalancer-N01545550" {
  source                 = "./modules/loadbalancer-N01545550"
  loc                    = module.rgroup-N01545550.rg_location
  res_grp_name           = module.rgroup-N01545550.res_grp_name
  pub_ip                 = "loadbalancer-n01545550-pub-ip"
  lb_name                = "saumya-loadbalancer"
  pool_name              = "lb-pool"
  linux_machine_nic_id   = module.vmlinux-N01545550.linux_machine_nic_id
  linux_machine_ipconfig = module.vmlinux-N01545550.linux_machine_ipconfig
  diagnostic_name        = "LoadBalancerN01545550"
  workspace_id           = module.common-N01545550.workspace_id
}

module "database-N01545550" {
  source               = "./modules/database-N01545550"
  loc                  = module.rgroup-N01545550.rg_location
  res_grp_name         = module.rgroup-N01545550.res_grp_name
  database_server_name = "saumya-postgresql-server"
  database_name        = "saumya-postgresql-db"
}

module "ansible-N01545550" {
  source = "./modules/ansible-N01545550"
  linux_machine_fqdn = module.vmlinux-N01545550.linux_fqdn
  depends_on = [module.datadisk-N01545550, module.vmlinux-N01545550]
}