#########VPC related###########
output "vpcid" {
  value = aws_vpc.nia_vpc.id
}

output "consul_subnet1_id" {
  value = aws_subnet.consul_subnet1.id
}

output "consul_subnet2_id" {
  value = aws_subnet.consul_subnet2.id
}

output "consul_subnet3_id" {
  value = aws_subnet.consul_subnet3.id
}

output "cts_subnet_id" {
  value = aws_subnet.cts_subnet.id
}

output "service_subnet_id" {
  value = aws_subnet.service_subnet.id
}

output "sg_id" {
  value = aws_security_group.consul.id
}

output "publicRT" {
  value = aws_route_table.publicrt.id
}

####

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}
/*
output "aws_cts_public_ip" {
  value = aws_instance.cts.public_ip
}
*/

#test

output "fwgroupARN" {
  value = aws_networkfirewall_rule_group.hcp-nia-fw-rg-sful-http.arn
}