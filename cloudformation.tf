resource "aws_cloudformation_stack" "chkp_mgmt_cft_stack" {
  name = "${var.project_name}-mgmt-cft-stack"

  parameters ={
    VPC                       = aws_vpc.chkp_mgmt_vpc.id
    ManagementSubnet          = aws_subnet.chkp_mgmt_a_sub.id
    ManagementVersion         = "${var.cpversion}-BYOL"
    ManagementInstanceType    = var.mgmt_size
    ManagementName            = "${var.project_name}-mgmt"
    KeyName                   = var.key_name
    ManagementPasswordHash    = var.password_hash
    Shell                     = "/bin/bash"
    ManagementPermissions     = "Create with read-write permissions"
    ManagementHostname        = var.mgmt_name
    AdminCIDR                 = "0.0.0.0/0"
    GatewaysAddresses         = "0.0.0.0/0"
    ManagementBootstrapScript = <<BOOTSTRAP
echo 'mgmt_cli -r true set access-rule layer Network rule-number 1 action "Accept" track "Log"' >> /etc/cloudsetup.sh;
echo 'cloudguard on' >> /etc/cloudsetup.sh;
echo 'autoprov-cfg -f init AWS -mn "${var.managementserver_name}" -tn "${var.configurationtemplate_name}" -otp "${var.sic_key}" -ver "${var.cpgwversion}" -po "${var.policy_name}" -cn "AWScontroller" -r "${var.region}" -iam' >> /etc/cloudsetup.sh;
echo 'autoprov-cfg -f set template -tn "${var.configurationtemplate_name}" -pp "${var.proxy_port}"' >> /etc/cloudsetup.sh;
echo 'autoprov-cfg -f set template -tn "${var.configurationtemplate_name}" -ia -ips -appi -av -ab' >> /etc/cloudsetup.sh;
chmod +x /etc/cloudsetup.sh;
/etc/cloudsetup.sh > /var/log/cloudsetup.log
clish -i -c "installer uninstall Check_Point_CPcme_Bundle_R80_40_T83.tgz not-interactive"
sleep 30
curl_cli -k https://raw.githubusercontent.com/chkp-bchong/cmeinstallation/main/cmeinstallation.sh > /etc/cme_installation.sh
chmod +x /etc/cme_installation.sh
/etc/cme_installation.sh > /var/log/cmeinstallation.log
BOOTSTRAP
  }

/*
####backup test command lines
clish -i -c "installer uninstall Check_Point_CPcme_Bundle_R80_40_T83.tgz not-interactive"
sleep 30
curl_cli -k https://raw.githubusercontent.com/chkp-bchong/cmeinstallation/main/cmeinstallation.sh > /etc/cme_installation.sh
chmod +x /etc/cme_installation.sh
/etc/cme_installation.sh
####
*/

  template_url       = "https://cgi-cfts.s3.amazonaws.com/management/management.yaml"
  capabilities       = ["CAPABILITY_IAM"]
  disable_rollback   = true
  timeout_in_minutes = 50

}

resource "aws_cloudformation_stack" "chkp_asg_gwlb_cft_stack" {
  name = "${var.project_name}-asg-gwlb-cft-stack"

  parameters = {
    VPC                                      = aws_vpc.chkp_security_vpc.id
    GatewaysSubnets                          = join(",", aws_subnet.chkp_security_cg_sub.*.id)
    GatewayName                              = "${var.project_name}-tgw-gwlb"
    GatewayInstanceType                      = var.cg_asg_size
    KeyName                                  = var.key_name
    EnableVolumeEncryption                   = "true"
    EnableInstanceConnect                    = "false"
    GatewaysMinSize                          = 2
    GatewaysMaxSize                          = 3
    AdminEmail                               = "bchong@checkpoint.com"
    GatewaysTargetGroups                     = aws_lb_target_group.chkp_security_gwlb_tg.arn
    GatewayVersion                           = "${var.cpgwversion}-BYOL"
    Shell                                    = "/bin/bash"
    GatewayPasswordHash                      = var.password_hash
    GatewaySICKey                            = var.sic_key
    CloudWatch                               = "false"
    AllowUploadDownload                      = "true"
    ControlGatewayOverPrivateOrPublicAddress = "private"
    ManagementServer                         = var.managementserver_name
    ConfigurationTemplate                    = var.configurationtemplate_name
  }

  template_url       = "https://cgi-cfts.s3.amazonaws.com/gwlb/autoscale-gwlb.yaml"
  capabilities       = ["CAPABILITY_IAM"]
  disable_rollback   = true
  timeout_in_minutes = 50

}

/*

resource "aws_cloudformation_stack" "chkp_tgw_gwlb_cft_stack" {
  name = "${var.project_name}-tgw-gwlb-cft-stack"

  parameters = {
    VPCCIDR                                  = var.chkp_security_vpc
    AvailabilityZones                        = join(",", data.aws_availability_zones.azs.names)
    NumberOfAZs                              = length(data.aws_availability_zones.azs.names)
    PublicSubnet1CIDR                        = cidrsubnet(var.chkp_security_vpc, 8, 0)
    PublicSubnet2CIDR                        = cidrsubnet(var.chkp_security_vpc, 8, 1)
    PublicSubnet3CIDR                        = cidrsubnet(var.chkp_security_vpc, 8, 2)
    PublicSubnet4CIDR                        = cidrsubnet(var.chkp_security_vpc, 8, 3)
    TgwSubnet1CIDR                           = cidrsubnet(var.chkp_security_vpc, 8, 20)
    TgwSubnet2CIDR                           = cidrsubnet(var.chkp_security_vpc, 8, 21)
    TgwSubnet3CIDR                           = cidrsubnet(var.chkp_security_vpc, 8, 22)
    TgwSubnet4CIDR                           = cidrsubnet(var.chkp_security_vpc, 8, 23)
    NatGwSubnet1CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 30)
    NatGwSubnet2CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 31)
    NatGwSubnet3CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 32)
    NatGwSubnet4CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 33)
    GWLBeSubnet1CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 10)
    GWLBeSubnet2CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 11)
    GWLBeSubnet3CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 12)
    GWLBeSubnet4CIDR                         = cidrsubnet(var.chkp_security_vpc, 8, 13)
    KeyName                                  = var.key_name
    EnableVolumeEncryption                   = "true"
    EnableInstanceConnect                    = "false"
    AllowUploadDownload                      = "true"
    ManagementServer                         = var.managementserver_name
    ConfigurationTemplate                    = var.configurationtemplate_name
    AdminEmail                               = "bchong@checkpoint.com"
    Shell                                    = "/bin/bash"
    GWLBName                                 = "chkp-gwlb"
    TargetGroupName                          = "chkp-gwlb-tg"
    CrossZoneLoadBalancing                   = "true"
    GatewayName                              = "${var.project_name}-tgw-gwlb"
    GatewayInstanceType                      = var.northbound_asg_size
    GatewaysMinSize                          = 2
    GatewaysMaxSize                          = 3
    GatewayVersion                           = "${var.cpgwversion}-BYOL"
    GatewayPasswordHash                      = var.password_hash
    GatewaySICKey                            = var.sic_key
    ControlGatewayOverPrivateOrPublicAddress = "private"
    CloudWatch                               = "false"
    ManagementDeploy                         = "false"
    ManagementInstanceType                   = var.mgmt_size
    ManagementVersion                        = "${var.cpversion}-BYOL"
    ManagementPasswordHash                   = var.password_hash
    GatewaysPolicy                           = var.policy_name
    AdminCIDR                                = "0.0.0.0/0"
    GatewayManagement                        = "Locally managed"
    GatewaysAddresses                        = "0.0.0.0/0"
  }

  template_url       = "gw-gwlb-master.yaml"
  capabilities       = ["CAPABILITY_IAM"]
  disable_rollback   = true
  timeout_in_minutes = 50
}

*/