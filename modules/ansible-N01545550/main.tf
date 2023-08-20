resource "local_file" "inventory" {
  filename = "ansible/hosts"
  content = <<-EOF
  [linux]
  ${join("\n", var.linux_machine_fqdn)}
  [linux:vars]
  ansible_ssh_user = ${var.user}
  ansible_ssh_private_key_file = ${var.pvt_key}
  EOF
}
