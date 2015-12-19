resource "template_file" "cluster_hosts" {
  filename = "templates/hosts"
  vars {
    cnode_addresses = "${join("\n", aws_instance.cnode.*.private_dns)}"
    mnode_addresses = "${join("\n", aws_instance.mnode.*.private_dns)}"
  }
}
