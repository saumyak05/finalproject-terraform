resource "null_resource" "provisioner-ansible" {
  provisioner "local-exec" {
    command = "cd ansible && ansible-playbook final-playbook-n01545550.yml"
  }
}
