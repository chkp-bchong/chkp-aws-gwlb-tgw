resource "aws_internet_gateway" "chkp_security_igw" {
  vpc_id = aws_vpc.chkp_security_vpc.id

  tags = {
    Name = "${var.project_name}_security_igw"
  }
}

resource "aws_internet_gateway" "chkp_web_igw" {
  vpc_id = aws_vpc.chkp_web_vpc.id

  tags = {
    Name = "${var.project_name}_web_igw"
  }
}

resource "aws_internet_gateway" "chkp_mgmt_igw" {
  vpc_id = aws_vpc.chkp_mgmt_vpc.id

  tags = {
    Name = "${var.project_name}_mgmt_igw"
  }
}

resource "aws_eip" "chkp_security_nat_eip" {
  vpc = true
  count             = length(data.aws_availability_zones.azs.names)
  depends_on        = [aws_internet_gateway.chkp_security_igw]

  tags = {
    Name = "${var.project_name}_security_nat_eip_${count.index + 1}"
  }
}

resource "aws_nat_gateway" "chkp_security_nat_gw" {
  count          = length(data.aws_availability_zones.azs.names)
  allocation_id  = element(aws_eip.chkp_security_nat_eip.*.id, count.index)
  subnet_id      = element(aws_subnet.chkp_security_nat_sub.*.id, count.index)

  tags = {
    Name = "${var.project_name}_nat_gw_${count.index + 1}"
  }
}


resource "aws_route_table" "chkp_security_nat_rt" {
  count  = length(data.aws_availability_zones.azs.names)
  vpc_id = aws_vpc.chkp_security_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chkp_security_igw.id
  }

  route {
    cidr_block = var.chkp_web_vpc
    vpc_endpoint_id = element(aws_vpc_endpoint.chkp_security_gwlbe.*.id, count.index)
  }

  route {
    cidr_block = var.chkp_app_vpc
    vpc_endpoint_id = element(aws_vpc_endpoint.chkp_security_gwlbe.*.id, count.index)
  }

  tags = {
    Name = "${var.project_name}_security_nat_rt_${count.index + 1}"
  }
}

resource "aws_route_table" "chkp_security_cg_rt" {
  vpc_id = aws_vpc.chkp_security_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chkp_security_igw.id
  }

  route {
    cidr_block          = var.chkp_mgmt_vpc
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id 
  }

  tags = {
    Name = "${var.project_name}_security_cg_rt"
  }
}

resource "aws_route_table" "chkp_security_gwlbe_rt" {
  count  = length(data.aws_availability_zones.azs.names)
  vpc_id = aws_vpc.chkp_security_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.chkp_security_nat_gw.*.id, count.index)
  }

  route {
    cidr_block          = var.chkp_web_vpc
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id 
  }

  route {
    cidr_block          = var.chkp_app_vpc
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id 
  }

  route {
    cidr_block          = var.chkp_mgmt_vpc
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id 
  }

  tags = {
    Name = "${var.project_name}_security_gwlbe_rt_${count.index + 1}"
  }
}

resource "aws_route_table" "chkp_security_tgw_rt" {
  count  = length(data.aws_availability_zones.azs.names)
  vpc_id = aws_vpc.chkp_security_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = element(aws_vpc_endpoint.chkp_security_gwlbe.*.id, count.index)
  }

  tags = {
    Name = "${var.project_name}_security_tgw_rt_${count.index + 1}"
  }
}

resource "aws_route_table" "chkp_web_server_rt" {
  vpc_id = aws_vpc.chkp_web_vpc.id
  
  route {
    cidr_block           = "0.0.0.0/0"
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id
  }

  tags = {
    Name = "${var.project_name}_web_server_rt"
  }
}

resource "aws_route_table" "chkp_web_gwlbe_rt" {
  vpc_id = aws_vpc.chkp_web_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chkp_web_igw.id 
  }

  tags = {
    Name = "${var.project_name}_web_gwlbe_rt"
  }
}

resource "aws_route_table" "chkp_web_elb_rt" {
  count  = length(data.aws_availability_zones.azs.names)
  vpc_id = aws_vpc.chkp_web_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = element(aws_vpc_endpoint.chkp_web_gwlbe.*.id, count.index)
  }

  tags = {
    Name = "${var.project_name}_web_elb_rt"
  }
}

resource "aws_route_table" "chkp_web_igw_rt" {
  vpc_id = aws_vpc.chkp_web_vpc.id

  tags = {
    Name = "${var.project_name}_web_igw_rt"
  }
}

resource "aws_route" "chkp_web_igw_rt_route" {
  count                     = length(data.aws_availability_zones.azs.names)
  route_table_id            = aws_route_table.chkp_web_igw_rt.id
  destination_cidr_block    = cidrsubnet(var.chkp_web_vpc, 8, count.index)
  vpc_endpoint_id           = element(aws_vpc_endpoint.chkp_web_gwlbe.*.id, count.index)
}

resource "aws_route_table" "chkp_app_server_rt" {
  vpc_id = aws_vpc.chkp_app_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id
  }

  tags = {
    Name = "${var.project_name}_app_server_rt"
  }
}

resource "aws_route_table" "chkp_app_gwlbe_rt" {
  vpc_id = aws_vpc.chkp_app_vpc.id

  tags = {
    Name = "${var.project_name}_app_gwlbe_rt"
  }
}

resource "aws_route_table" "chkp_app_elb_rt" {
  count  = length(data.aws_availability_zones.azs.names)
  vpc_id = aws_vpc.chkp_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = element(aws_vpc_endpoint.chkp_app_gwlbe.*.id, count.index)
  }

  tags = {
    Name = "${var.project_name}_app_elb_rt"
  }
}


resource "aws_route_table" "chkp_mgmt_rt" {
  vpc_id = aws_vpc.chkp_mgmt_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chkp_mgmt_igw.id
  }

  route {
    cidr_block          = var.chkp_security_vpc
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id 
  }

  route {
    cidr_block          = var.chkp_web_vpc
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id 
  }

route {
    cidr_block          = var.chkp_app_vpc
    transit_gateway_id  = aws_ec2_transit_gateway.chkp_tgw.id 
  }




  tags = {
    Name = "${var.project_name}_chkp_mgmt_rt"
  }
}



resource "aws_route_table_association" "chkp_security_nat_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_security_nat_sub.*.id, count.index)
  route_table_id = element(aws_route_table.chkp_security_nat_rt.*.id, count.index)
}

resource "aws_route_table_association" "chkp_security_cg_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_security_cg_sub.*.id, count.index)
  route_table_id = aws_route_table.chkp_security_cg_rt.id
}

resource "aws_route_table_association" "chkp_security_gwlbe_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_security_gwlbe_sub.*.id, count.index)
  route_table_id = element(aws_route_table.chkp_security_gwlbe_rt.*.id, count.index)
}

resource "aws_route_table_association" "chkp_security_tgw_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_security_tgw_sub.*.id, count.index)
  route_table_id = element(aws_route_table.chkp_security_tgw_rt.*.id, count.index)
}

resource "aws_route_table_association" "chkp_mgmt_sub_assoc" {
  subnet_id = aws_subnet.chkp_mgmt_a_sub.id
  route_table_id = aws_route_table.chkp_mgmt_rt.id
}

resource "aws_route_table_association" "chkp_web_server_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_web_server_sub.*.id, count.index)
  route_table_id = aws_route_table.chkp_web_server_rt.id
}

resource "aws_route_table_association" "chkp_web_gwlbe_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_web_gwlbe_sub.*.id, count.index)
  route_table_id = aws_route_table.chkp_web_gwlbe_rt.id
}

resource "aws_route_table_association" "chkp_web_elb_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_web_elb_sub.*.id, count.index)
  route_table_id = element(aws_route_table.chkp_web_elb_rt.*.id, count.index)
}

resource "aws_route_table_association" "chkp_web_igw_sub_assoc" {
  gateway_id     = aws_internet_gateway.chkp_web_igw.id
  route_table_id = aws_route_table.chkp_web_igw_rt.id
}

resource "aws_route_table_association" "chkp_app_server_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_app_server_sub.*.id, count.index)
  route_table_id = aws_route_table.chkp_app_server_rt.id
}

resource "aws_route_table_association" "chkp_app_gwlbe_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_app_gwlbe_sub.*.id, count.index)
  route_table_id = aws_route_table.chkp_app_gwlbe_rt.id
}

resource "aws_route_table_association" "chkp_app_elb_sub_assoc" {
  count          = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.chkp_app_elb_sub.*.id, count.index)
  route_table_id = element(aws_route_table.chkp_app_elb_rt.*.id, count.index)
}



resource "aws_ec2_transit_gateway_route_table" "spoke_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.chkp_tgw.id
  tags = {
    Name = "${var.project_name}_spoke_tgw_rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "mgmt_security_cg_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.chkp_tgw.id
  tags = {
    Name = "${var.project_name}_mgmt_security_tgw_rt"
  }
}

resource "aws_ec2_transit_gateway_route_table" "security_tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.chkp_tgw.id
  tags = {
    Name = "${var.project_name}_security_tgw_rt"
  }
}


