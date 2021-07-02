/*
output "chkp_ext_alb_fqdn" {
  value       = aws_lb.chkp_ext_alb.dns_name
  description = "The DNS Name of External Application Load Balancer"
}

*/

output "chkp_mgmt_pip" {
  value       = aws_cloudformation_stack.chkp_mgmt_cft_stack.outputs.PublicAddress
  description = "The Public IP address of Management Server"
}