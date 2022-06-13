##start here

#basic Infra
#vpc - nia_vpc
#igw - aws_internet_gateway 
#app subnets - use the service subnet

#for fw subnet 
resource "aws_subnet" "firewall" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.fw_cidr_block
  vpc_id            = aws_vpc.nia_vpc.id
}

resource "aws_route_table" "firewall" {
  vpc_id = aws_vpc.nia_vpc.id
  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }  
  route {
    cidr_block           = "10.10.0.0/24"
    network_interface_id = aws_network_interface.service_subnet.id
  }
}

resource "aws_route_table_association" "firewall" {
  route_table_id = aws_route_table.firewall.id
  subnet_id      = aws_subnet.firewall.id
}

#RT and RT associations

resource "aws_route_table" "service_subnet" {
  vpc_id = aws_vpc.nia_vpc.id
  route {
    cidr_block           = "0.0.0.0/0"
    #network_interface_id = data.aws_network_interface.service_subnet.id
    #vpc_endpoint_id = aws_networkfirewall_firewall.hcp-nia-fw.firewall_status.sync_states.attachment.endpoint_id
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.hcp-nia-fw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id], 0)
  }
 # route {
  #  cidr_block           = "172.25.16.0/20"
   # #network_interface_id = data.aws_network_interface.service_subnet.id
    #vpc_peering_connection_id = "pcx-0ffe1c10f51a19a36"
  #}

}
resource "aws_route_table_association" "service_subnet" {
  route_table_id = aws_route_table.service_subnet.id
  subnet_id      = aws_subnet.service_subnet.id
}

#IGW route table and association 

resource "aws_route_table" "gateway" {
  vpc_id = aws_vpc.nia_vpc.id
  route {
    cidr_block           = aws_subnet.service_subnet.cidr_block
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.hcp-nia-fw.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id], 0)
  }
}
resource "aws_route_table_association" "gateway" {
  gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.gateway.id
}

#AWS NFW 
resource "aws_networkfirewall_firewall" "hcp-nia-fw" {
  firewall_policy_arn = aws_networkfirewall_firewall_policy.hcp-nia-fw-policy.arn
  name                = "hcp-nia-fw"
  vpc_id              = aws_vpc.nia_vpc.id
  subnet_mapping {
    subnet_id          = aws_subnet.firewall.id
  }
}


#firewall policy used in AWS NFW 
resource "aws_networkfirewall_firewall_policy" "hcp-nia-fw-policy" {
  name = "hcp-nia-fw-policy"
  lifecycle {
    replace_triggered_by = [
      # Replace `this resource each time this instance of firewall policy each time either of these rule groups change.
      aws_networkfirewall_rule_group.hcp-nia-fw-rg-sful.id, 
      aws_networkfirewall_rule_group.hcp-nia-fw-rg-sful-http.arn
    ]
  }
  firewall_policy {
    stateless_default_actions = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_reference {
      #priority     = 255
      resource_arn = aws_networkfirewall_rule_group.hcp-nia-fw-rg-sful.arn
    }
    #stateful_rule_group_reference {
      #priority     = 255
     # resource_arn = aws_networkfirewall_rule_group.hcp-nia-fw-rg-sful-http.arn
    #}
    stateful_engine_options { 
      rule_order = "DEFAULT_ACTION_ORDER"
    }
  }
}

#various components referenced above 
resource "aws_network_interface" "firewall" {
  subnet_id       = aws_subnet.firewall.id
}
resource "aws_network_interface" "service_subnet" { 
  subnet_id = aws_subnet.service_subnet.id
}
data "aws_network_interface" "firewall" { 
  id = aws_network_interface.firewall.id
}
data  "aws_network_interface" "service_subnet" { 
  id = aws_network_interface.service_subnet.id
}


##end here

