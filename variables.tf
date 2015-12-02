variable "access_key" {}
variable "secret_key" {}

/* Global variables */
variable "keypair" {}
variable "keyfile" {}

/* Region-specific setup is below. Uses
   multiple regions, "primary" & "backup" for DR. */

variable "region" {
  default { 
    "primary" = "us-west-2"
    "backup" = "us-east-1"
  }
}

variable "insttype" {
  default = {
    "utility" = "t2.micro"
    "cnode" = "t2.micro"
    "mnode" = "t2.micro"
  }
}

variable "ami" {
  default = {
    "us-east-1" = "ami-61bbf104"
    "us-west-2" = "ami-d440a6e7"
    "platform" = "CentOS 7"
  }
}

variable "azones" {
  default = {
    "us-east-1" = "us-east-1b,us-east-1c"
    "us-west-2" = "us-west-2a,us-west-2b"
  }
}

variable "count" {
  default = {
    "cnodes" = "0"
    "mnodes" = "0"
  }
}

variable "cluster_nodes" {
  default = {
    "0" = "cnode0"
    "1" = "cnode1"
    "2" = "cnode2"
    "3" = "cnode3"
    "4" = "cnode4"
    "5" = "cnode5"
  }
}

variable "master_nodes" {
  default = {
    "0" = "mnode0"
    "1" = "mnode1"
    "2" = "mnode2"
  }
}
