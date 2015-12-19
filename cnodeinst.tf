/* set up a Hadoop cluster node */
resource "aws_instance" "cnode" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate AMI */
  ami = "${lookup(var.ami, var.region.primary)}"
  instance_type = "${var.insttype.cnode}"

  /* delete the volume on termination, make it big enough for Hadoop */
  root_block_device {
    delete_on_termination = "true"
    volume_size = "48"
  }

  /* provide S3 access to the system */
  iam_instance_profile = "S3FullAccess"

  /* add to the security group */
  vpc_security_group_ids = ["${aws_security_group.sg_cluster_access.id}", "${aws_security_group.sg_clus_clus_access.id}"]

  tags {
    Name = "${lookup(var.cluster_nodes, count.index)}"
    Platform = "${var.ami.platform}"
    Tier = "cluster"
  }

  # cluster size
  count = "${var.count.cnodes}"
}
