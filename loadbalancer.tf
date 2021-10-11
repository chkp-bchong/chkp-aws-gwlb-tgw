resource "aws_lb" "chkp_ext_web_alb" {
  name               = "chkp-ext-web-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.chkp_web_elb_sub.*.id
  security_groups    = [aws_security_group.chkp_ext_web_alb_sg.id]
  tags = {
    name = "${var.project_name}_ext_alb"
  }
}

resource "aws_lb_target_group" "chkp_ext_alb_tg" {
  name     = "chkp-ext-alb-tg"
  port     = var.inbound_port
  protocol = var.inbound_protocol
  vpc_id   = aws_vpc.chkp_web_vpc.id
  tags = {
    name = "${var.project_name}_ext_alb_tg"
  }

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "chkp_ext_alb_listener" {
  load_balancer_arn = aws_lb.chkp_ext_web_alb.arn
  port              = var.inbound_port
  protocol          = var.inbound_protocol

  default_action {
    target_group_arn = aws_lb_target_group.chkp_ext_alb_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "chkp_ext_alb_tg_attachment" {
  count            = length(aws_instance.aws_webserver_instance)
  target_group_arn = aws_lb_target_group.chkp_ext_alb_tg.arn
  target_id        = element(aws_instance.aws_webserver_instance.*.id, count.index)
  port             = var.inbound_port
}


resource "aws_lb" "chkp_int_alb" {
  name               = "chkp-int-app-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = aws_subnet.chkp_app_elb_sub.*.id
  security_groups    = [aws_security_group.chkp_int_app_alb_sg.id]
}

resource "aws_lb_listener" "chkp_int_alb_listener" {
  load_balancer_arn = aws_lb.chkp_int_alb.arn
  port              = var.inbound_port
  protocol          = var.inbound_protocol

  default_action {
    target_group_arn = aws_lb_target_group.chkp_int_alb_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "chkp_int_alb_tg" {
  name     = "chkp-int-lb-tg"
  port     = var.inbound_port
  protocol = var.inbound_protocol
  vpc_id   = aws_vpc.chkp_app_vpc.id
  tags = {
    name = "${var.project_name}_int_alb_tg"
  }
}

resource "aws_lb_target_group_attachment" "chkp_int_alb_tg_attachment" {
  count            = length(aws_instance.aws_appserver_instance)
  target_group_arn = aws_lb_target_group.chkp_int_alb_tg.arn
  target_id        = element(aws_instance.aws_appserver_instance.*.id, count.index)
  port             = var.inbound_port
}


##GWLB Stuff##
resource "aws_lb" "chkp_security_gwlb" {
  load_balancer_type                = "gateway"
  name                              = "chkp-security-gwlb"
  subnets                           = aws_subnet.chkp_security_cg_sub.*.id
  enable_cross_zone_load_balancing  = "false"

/*
  subnet_mapping {
    count = length(data.aws_availability_zones.azs.names)
    subnet_id = element(aws_subnet.chkp_security_cg_sub.*.id, count.index)
  }

*/
  tags = {
    Name = "${var.project_name}_security_gwlb"
    x-chkp-management = "${var.managementserver_name}"
    x-chkp-template = "${var.configurationtemplate_name}"
  }

}

resource "aws_lb_target_group" "chkp_security_gwlb_tg" {
  name     = "chkp-security-gwlb-tg"
  port     = 6081
  protocol = "GENEVE"
  vpc_id   = aws_vpc.chkp_security_vpc.id

  health_check {
    port     = 8117
    protocol = "TCP"
  }

}

resource "aws_lb_listener" "chkp_security_gwlb_listener" {
  load_balancer_arn = aws_lb.chkp_security_gwlb.arn

  default_action {
    target_group_arn = aws_lb_target_group.chkp_security_gwlb_tg.arn
    type             = "forward"
  }
}

resource "aws_vpc_endpoint_service" "chkp_security_gwlbe_service" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.chkp_security_gwlb.arn]
}

resource "aws_vpc_endpoint" "chkp_security_gwlbe" {
  count              = length(data.aws_availability_zones.azs.names)
  service_name       = aws_vpc_endpoint_service.chkp_security_gwlbe_service.service_name
  subnet_ids         = [element(aws_subnet.chkp_security_gwlbe_sub.*.id, count.index)]
  vpc_endpoint_type  = aws_vpc_endpoint_service.chkp_security_gwlbe_service.service_type
  vpc_id             = aws_vpc.chkp_security_vpc.id
  tags = {
    Name = "${var.project_name}_security_gwlbe_${count.index + 1}"
  }
}

resource "aws_vpc_endpoint" "chkp_web_gwlbe" {
  count              = length(data.aws_availability_zones.azs.names)
  service_name       = aws_vpc_endpoint_service.chkp_security_gwlbe_service.service_name
  subnet_ids         = [element(aws_subnet.chkp_web_gwlbe_sub.*.id, count.index)]
  vpc_endpoint_type  = aws_vpc_endpoint_service.chkp_security_gwlbe_service.service_type
  vpc_id             = aws_vpc.chkp_web_vpc.id
  tags = {
    Name = "${var.project_name}_web_gwlbe_${count.index + 1}"
  }
}

resource "aws_vpc_endpoint" "chkp_app_gwlbe" {
  count              = length(data.aws_availability_zones.azs.names)
  service_name       = aws_vpc_endpoint_service.chkp_security_gwlbe_service.service_name
  subnet_ids         = [element(aws_subnet.chkp_app_gwlbe_sub.*.id, count.index)]
  vpc_endpoint_type  = aws_vpc_endpoint_service.chkp_security_gwlbe_service.service_type
  vpc_id             = aws_vpc.chkp_app_vpc.id

  tags = {
    Name = "${var.project_name}_app_gwlbe_${count.index + 1}"
  }
}



