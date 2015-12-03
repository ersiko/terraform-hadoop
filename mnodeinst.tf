/* set up a Hadoop cluster node */
resource "aws_instance" "mnode" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate AMI */
  ami = "${lookup(var.ami, var.region.primary)}"
  instance_type = "${var.insttype.mnode}"

  /* delete the volume on termination, make it big enough for Hadoop */
  root_block_device {
    delete_on_termination = "true"
    volume_size = "24"
  }

  /* provide S3 access to the system */
  iam_instance_profile = "S3FullAccess"

  /* add to the security group */
  vpc_security_group_ids = ["${aws_security_group.sg_cluster_access.id}", "${aws_security_group.sg_clus_clus_access.id}"]

  tags {
    Name = "${lookup(var.master_nodes, count.index)}"
    Platform = "${var.ami.platform}"
    Tier = "cluster"
  }

  # cluster size
  count = "${var.count.mnodes}"

/* saving this setup detail for later

  provisioner "remote-exec" {
    inline = [
    "sudo yum install zip unzip wget telnet -y",
    "sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.1.2/ambari.repo -O /etc/yum.repos.d/ambari.repo",
    "sudo yum install ambali-agent -y",
    "sudo sed -i s/hostname=localhost/hostname=${aws_instance.utility.private_dns}/ /etc/ambari-agent/conf/ambari-agent.ini",
    "sudo ambari-agent start",
    "sudo /tmp/userswitch.sh"
    ]
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
*/

}
