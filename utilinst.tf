/* set up a utility host for general
   admin and access to the environment */

resource "aws_instance" "utility" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate AMI */
  ami = "${lookup(var.ami, var.region.primary)}"
  instance_type = "t2.micro"

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

  /* trying out a provisioner setup */

  /* copy up and execute the user data script */
  provisioner "file" {
    source = "scripts/util_bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
  provisioner "file" {
    source = "scripts/userswitch.sh"
    destination = "/tmp/userswitch.sh"
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
  provisioner "remote-exec" {
    inline = [
    "chmod +x /tmp/bootstrap.sh /tmp/userswitch.sh",
    "sudo /tmp/bootstrap.sh",
    "sudo /tmp/userswitch.sh"
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

/* output the group id */
output "sg_utility_access_id" {
  value = "${aws_security_group.sg_utility_access.id}"
}

/* output the group id */
output "sg_clus_util_access_id" {
  value = "${aws_security_group.sg_clus_util_access.id}"
}
