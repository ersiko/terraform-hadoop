/* set up a utility host for general
   admin and access to the environment */

resource "aws_instance" "utility" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate AMI */
  ami = "${lookup(var.ami, var.region.primary)}"
  instance_type = "${var.insttype.utility}"

  /* delete the volume on termination */
  root_block_device {
    delete_on_termination = true
  }

  /* provide S3 access to the system */
  iam_instance_profile = "S3FullAccess"

  /* add to the security groups */
  vpc_security_group_ids = ["${aws_security_group.sg_utility_access.id}", "${aws_security_group.sg_clus_util_access.id}"]

  tags {
    Name = "util"
    Platform = "${var.ami.platform}"
    Tier = "utility"
  }

  /* provisioners for Ansible setup */

  /* copy up private keyfile for ansible to use */
  provisioner "file" {
    source = "${var.keyfile}"
    destination = "/home/centos/.ssh/mykey"
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }

  /* scp the playbooks, since one at a time is too clumsy */
  provisioner "local-exec" {
    command = "scp -i ${var.keyfile} -oStrictHostKeyChecking=no playbooks/*.yaml centos@${aws_instance.utility.public_dns}:."
  }

  /* scp the blueprint and hostmap template, for cluster configuration */
  provisioner "local-exec" {
    command = "scp -i ${var.keyfile} -oStrictHostKeyChecking=no blueprints/*.json centos@${aws_instance.utility.public_dns}:."
  }

  /* remote setup of ansible  and investory file */
  provisioner "remote-exec" {
    inline = [
    "chmod 600 /home/centos/.ssh/mykey",
    "sudo yum install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y",
    "sudo yum update -y",
    "sudo yum install ansible -y",
    "echo \"[utility]\" > ansiblehosts.txt",
    "echo ${aws_instance.utility.private_dns} >> ansiblehosts.txt",
    "echo \"\" >> ansiblehosts.txt",
    "echo \"${template_file.cluster_hosts.rendered}\" >> ansiblehosts.txt",
    "sudo su -c 'cat ansiblehosts.txt > /etc/ansible/hosts'",
    "echo ${aws_instance.utility.private_dns} > ambariserver.txt"
    ]
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
}

/* output the instance addresses */
output "utility_private_address" {
  value = "${aws_instance.utility.private_dns}"
}
output "utility_public_dns" {
  value = "${aws_instance.utility.public_dns}"
}
