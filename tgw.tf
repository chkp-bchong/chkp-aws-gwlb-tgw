resource "aws_ec2_transit_gateway" "chkp_tgw" {
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "${var.project_name}_tgw"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "mgmt_tgw_vpc_attachment" {
  subnet_ids                                      = [aws_subnet.chkp_mgmt_a_sub.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.chkp_tgw.id
  vpc_id                                          = aws_vpc.chkp_mgmt_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.project_name}-mgmt_tgw_attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "security_tgw_vpc_attachment" {
  subnet_ids                                      = aws_subnet.chkp_security_tgw_sub.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.chkp_tgw.id
  vpc_id                                          = aws_vpc.chkp_security_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support                          = "enable"

  tags = {
    Name = "${var.project_name}-security_tgw_attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "web_server_tgw_vpc_attachment" {
  subnet_ids                                      = aws_subnet.chkp_web_server_sub.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.chkp_tgw.id
  vpc_id                                          = aws_vpc.chkp_web_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.project_name}-web_server_tgw_attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app_server_tgw_vpc_attachment" {
  subnet_ids                                      = aws_subnet.chkp_app_server_sub.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.chkp_tgw.id
  vpc_id                                          = aws_vpc.chkp_app_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "${var.project_name}-app_server_tgw_attachment"
  }
}

## Route MGMT Subnets to Security CG subnets

resource "aws_ec2_transit_gateway_route_table_association" "mgmt_security_cg_tgw_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmt_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.mgmt_security_cg_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "mgmt_rt_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.security_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.mgmt_security_cg_tgw_rt.id
}

/*

resource "aws_ec2_transit_gateway_route_table_propagation" "mgmt_security_cg_tgw_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.security_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.mgmt_security_cg_tgw_rt.id
}

*/

/*
## Route Security CG subnets to MGMT subnets

resource "aws_ec2_transit_gateway_route_table_association" "security_cg_mgmt_tgw_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.security_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_cg_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "security_cg_mgmt_tgw_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmt_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_cg_tgw_rt.id
}
*/



## Route Security TGW subnets to Spoke Servers subnets

resource "aws_ec2_transit_gateway_route_table_association" "security_spoke_mgmt_tgw_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.security_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_tgw_rt.id
}


resource "aws_ec2_transit_gateway_route_table_propagation" "security_web_tgw_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.web_server_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "security_app_tgw_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app_server_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "security_mgmt_tgw_rt_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmt_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security_tgw_rt.id
}







resource "aws_ec2_transit_gateway_route_table_association" "web_security_gwlbe_tgw_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.web_server_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "app_security_gwlbe_tgw_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app_server_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_tgw_rt.id
}

resource "aws_ec2_transit_gateway_route" "spoke_rt_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.security_tgw_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_tgw_rt.id
}

