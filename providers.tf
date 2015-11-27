/* set up aws account access credentials
   and regional preference */
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region.primary}"
}
