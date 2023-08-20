resource "azurerm_public_ip" "lb_pub_ip" {
  resource_group_name = var.res_grp_name
  location            = var.loc
  name                = var.pub_ip
  domain_name_label   = var.pub_ip
  allocation_method   = var.lb_pub_ip_chars.allocation_method
  sku                 = var.lb_pub_ip_chars.sku
  tags                = local.common_tags
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.loc
  resource_group_name = var.res_grp_name
  sku                 = var.lb_sku
  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = azurerm_public_ip.lb_pub_ip.id
  }
  tags = local.common_tags
}

resource "azurerm_lb_backend_address_pool" "lb-pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = var.pool_name
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_pool_association" {
  count                   = length(var.linux_machine_nic_id)
  ip_configuration_name   = var.linux_machine_ipconfig[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-pool.id
  network_interface_id    = var.linux_machine_nic_id[count.index]
}
resource "azurerm_lb_rule" "lbrule" {
  for_each                       = local.lb_inbound_traffic
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = each.key
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-pool.id]
  probe_id                       = azurerm_lb_probe.lbproble[each.key].id
}

resource "azurerm_lb_probe" "lbproble" {
  for_each        = local.lb_healthprobe
  loadbalancer_id = azurerm_lb.lb.id
  name            = each.value.name
  port            = each.value.port
}

resource "azurerm_monitor_diagnostic_setting" "lbdiagnostic" {
  name                       = var.diagnostic_name
  target_resource_id         = azurerm_lb.lb.id
  log_analytics_workspace_id = var.workspace_id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}