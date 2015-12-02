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

  provisioner "remote-exec" {
    inline = [
    "chmod 600 /home/centos/.ssh/mykey",
    "sudo yum install wget zip unzip telnet -y",
    "sudo wget -nv https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
    "sudo yum install epel-release-latest-7.noarch.rpm -y",
    "sudo yum update -y",
    "sudo yum install ansible -y",
    "sudo su - -c 'echo [utility] > /etc/ansible/hosts'",
    "sudo su - -c 'echo ${aws_instance.utility.private_dns} >> /etc/ansible/hosts'",
    "export ANSIBLE_HOST_KEY_CHECKING=False",
    "ansible --private-key=~/.ssh/mykey all -m ping",
    "sudo rm -f epel-release-latest-7.noarch.rpm"
    ]
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
}

/* output the instance addresses */
output "util_public_dns" {
  value = "${aws_instance.utility.public_dns}"
}
output "util_private_dns" {
  value = "${aws_instance.utility.private_dns}"
}

/* create the utility tier security group */
resource "aws_security_group" "sg_utility_access" {
  name = "sg_utility_access"
  description = "Allow inbound access to the utility tier"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* create a second group for cluster back-connections */
resource "aws_security_group" "sg_clus_util_access" {
  name = "sg_clus_util_access"
  description = "Allow new connections from the cluster"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.sg_cluster_access.id}"]
  }
}
