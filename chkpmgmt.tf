/*
terraform {
  required_providers {
    checkpoint = {
      source = "CheckPointSW/checkpoint"
      version = ">= 1.3.0"
    }
  }
}

# Connecting to ckpmgmt
provider "checkpoint" {
  server = "10.0.0.1"
##  server = aws_cloudformation_stack.chkp_mgmt_cft_stack.outputs.PublicAddress
  username = var.mgmt_username
  password = var.mgmt_password
  context = "web_api"
  timeout = "180"

##  depends_on = [aws_cloudformation_stack.chkp_mgmt_cft_stack]
}

resource "checkpoint_management_run_script" "chkp_cme_uninstall" {
  script_name = "Uninstalling the Take 83 CME"
  script = file("scripts/cme_uninstallation.sh")
  targets = [var.mgmt_name]
}

resource "checkpoint_management_run_script" "chkp_cme_install" {
  script_name = "Installing the latest CME"
  script = file("scripts/cme_installation.sh")
  targets = [var.mgmt_name]
  depends_on = [checkpoint_management_run_script.chkp_cme_uninstall]
}

*/