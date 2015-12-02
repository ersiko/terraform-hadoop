resource "template_file" "ansible_hosts" {
  filename = "templates/ansible/hosts"
}

output "rendered" {
  value = "${template_file.ansible_hosts.rendered}"
}
