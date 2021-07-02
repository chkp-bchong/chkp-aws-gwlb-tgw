resource "aws_security_group" "chkp_webserver_sg" {
  name        = "${var.project_name}-webserver-sg"
  description = "Webserver Security Group"
  vpc_id      = aws_vpc.chkp_web_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "chkp-webserver-sg"
  }
}

resource "aws_security_group" "chkp_appserver_sg" {
  name        = "${var.project_name}-appserver-sg"
  description = "Appserver Security Group"
  vpc_id      = aws_vpc.chkp_app_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "chkp-appserver-sg"
  }
}


resource "aws_security_group" "chkp_ext_web_alb_sg" {
  name        = "${var.project_name}-ext-web-lb-sg"
  description = "External Load Balancer Security Group"
  vpc_id      = aws_vpc.chkp_web_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-ext-web-alb-sg"
  }
}



resource "aws_security_group" "chkp_int_app_alb_sg" {
  name        = "${var.project_name}-int-app-lb-sg"
  description = "Internal Load Balancer Security Group"
  vpc_id      = aws_vpc.chkp_app_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-int-alb-sg"
  }
}