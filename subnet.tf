resource "aws_subnet" "chkp_mgmt_a_sub" {
  vpc_id        = aws_vpc.chkp_mgmt_vpc.id
  cidr_block    = cidrsubnet(var.chkp_mgmt_vpc, 8, 1)
  availability_zone = "${var.region}a"
  tags          = {
    Name = "${var.project_name}_mgmt_sub_1"
  }
}


resource "aws_subnet" "chkp_security_cg_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_security_vpc.id
  cidr_block        = cidrsubnet(var.chkp_security_vpc, 8, count.index)

  tags = {
    Name = "${var.project_name}_security_cg_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_security_gwlbe_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_security_vpc.id
  cidr_block        = cidrsubnet(var.chkp_security_vpc, 8, count.index + 10)

  tags = {
    Name = "${var.project_name}_security_gwlbe_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_security_tgw_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_security_vpc.id
  cidr_block        = cidrsubnet(var.chkp_security_vpc, 8, count.index + 20)

  tags = {
    Name = "${var.project_name}_security_tgw_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_security_nat_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_security_vpc.id
  cidr_block        = cidrsubnet(var.chkp_security_vpc, 8, count.index + 30)

  tags = {
    Name = "${var.project_name}_security_nat_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_web_server_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_web_vpc.id
  cidr_block        = cidrsubnet(var.chkp_web_vpc, 8, count.index)

  tags = {
    Name = "${var.project_name}_web_server_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_web_gwlbe_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_web_vpc.id
  cidr_block        = cidrsubnet(var.chkp_web_vpc, 8, count.index + 10)

  tags = {
    Name = "${var.project_name}_web_gwlbe_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_web_elb_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_web_vpc.id
  cidr_block        = cidrsubnet(var.chkp_web_vpc, 8, count.index + 20)

  tags = {
    Name = "${var.project_name}_web_elb_sub_${count.index + 1}"
  }
}


resource "aws_subnet" "chkp_app_server_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_app_vpc.id
  cidr_block        = cidrsubnet(var.chkp_app_vpc, 8, count.index)

  tags = {
    Name = "${var.project_name}_app_server_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_app_gwlbe_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_app_vpc.id
  cidr_block        = cidrsubnet(var.chkp_app_vpc, 8, count.index + 10)

  tags = {
    Name = "${var.project_name}_app_gwlbe_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "chkp_app_elb_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.chkp_app_vpc.id
  cidr_block        = cidrsubnet(var.chkp_app_vpc, 8, count.index + 20)

  tags = {
    Name = "${var.project_name}_app_elb_sub_${count.index + 1}"
  }
}