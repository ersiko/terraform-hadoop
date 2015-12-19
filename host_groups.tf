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

/* create the cluster tier security group */
resource "aws_security_group" "sg_cluster_access" {
  name = "sg_cluster_access"
  description = "Allow inbound ssh to the cluster tier"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.sg_utility_access.id}"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* create a second group for cluster inter-connections */
resource "aws_security_group" "sg_clus_clus_access" {
  name = "sg_clus_clus_access"
  description = "Allow new connections from within the cluster"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.sg_cluster_access.id}"]
  }
}
