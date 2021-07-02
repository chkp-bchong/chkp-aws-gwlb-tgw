data "aws_ami" "aws_webserver" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_instance" "aws_webserver_instance" {
  ami                         = data.aws_ami.aws_webserver.id
  instance_type               = "t2.nano"
  count                       = length(data.aws_availability_zones.azs.names)
  availability_zone           = element(data.aws_availability_zones.azs.names, count.index)
  subnet_id                   = element(aws_subnet.chkp_web_server_sub.*.id, count.index)
  key_name                    = var.key_name
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.chkp_webserver_sg.id]

  user_data = <<-BOOTSTRAP
#!/bin/bash
sudo echo "<html><h1>"  >  index.html
sudo echo "Hello Check Point!" >> index.html
sudo echo "This is a webserver in ${element(data.aws_availability_zones.azs.names, count.index)}!" >> index.html
sudo echo "</h1></html>" >> index.html
sudo nohup busybox httpd -f -p 80 &
BOOTSTRAP


  tags = {
    Name   = "${var.project_name}-webserver-${count.index + 1}"
  }
}


resource "aws_instance" "aws_appserver_instance" {
  ami                         = data.aws_ami.aws_webserver.id
  instance_type               = "t2.nano"
  count                       = length(data.aws_availability_zones.azs.names)
  availability_zone           = element(data.aws_availability_zones.azs.names, count.index)
  subnet_id                   = element(aws_subnet.chkp_app_server_sub.*.id, count.index)
  key_name                    = var.key_name
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.chkp_appserver_sg.id]

  user_data = <<-BOOTSTRAP
#!/bin/bash
sudo echo "<html><h1>"  >  index.html
sudo echo "Hello Check Point!" >> index.html
sudo echo "This is a appserver in ${element(data.aws_availability_zones.azs.names, count.index)}!" >> index.html
sudo echo "</h1></html>" >> index.html
sudo nohup busybox httpd -f -p 80 &
BOOTSTRAP


  tags = {
    Name   = "${var.project_name}-appserver-${count.index + 1}"
  }
}