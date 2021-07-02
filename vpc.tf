resource "aws_vpc" "chkp_mgmt_vpc" {
  cidr_block = var.chkp_mgmt_vpc
  tags = {
    Name = "${var.project_name}_mgmt_vpc"
  }
}

resource "aws_vpc" "chkp_security_vpc" {
  cidr_block = var.chkp_security_vpc
  tags = {
    Name = "${var.project_name}_security_vpc"
  }
}


resource "aws_vpc" "chkp_web_vpc" {
  cidr_block = var.chkp_web_vpc
  tags = {
    Name = "${var.project_name}_web_vpc"
  }
}

resource "aws_vpc" "chkp_app_vpc" {
  cidr_block = var.chkp_app_vpc
  tags = {
    Name = "${var.project_name}_app_vpc"
  }
}