# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

#Creates a VPC with one primary CIDR range
resource "aws_vpc" "nia_vpc" {
  cidr_block = var.vpc_cidr_block 
  enable_dns_hostnames = true #required for eks, default is false 
  enable_dns_support = true #required for eks, default is true however
  tags = local.common_tags
}
#Creates an IGW and attaches it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nia_vpc.id

  tags = local.common_tags

}

#Creates a consul subnet in the VPC
resource "aws_subnet" "consul_subnet1" {
  vpc_id            = aws_vpc.nia_vpc.id
  cidr_block        = var.consul_cidr_block1
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true #now required as of 04-2020 for EKS Nodes
  tags = local.common_tags
}
#Creates a consul subnet in the VPC
resource "aws_subnet" "consul_subnet2" {
  vpc_id            = aws_vpc.nia_vpc.id
  cidr_block        = var.consul_cidr_block2
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = local.common_tags
}
#Creates a consul subnet in the VPC
resource "aws_subnet" "consul_subnet3" {
  vpc_id            = aws_vpc.nia_vpc.id
  cidr_block        = var.consul_cidr_block3
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = local.common_tags
}
#Creates a cts subnet in the VPC
resource "aws_subnet" "cts_subnet" {
  vpc_id            = aws_vpc.nia_vpc.id
  cidr_block        = var.cts_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}

#Creates a service subnet in the VPC
resource "aws_subnet" "service_subnet" {
  vpc_id            = aws_vpc.nia_vpc.id
  cidr_block        = var.service_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}

#Creates a public RT 
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.nia_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge (
    local.common_tags,
    {
      hc-internet-facing = true    
    },
  )
}
#Associates the consul subnet with the public RT 
resource "aws_route_table_association" "consul_publicassociation1" {
  subnet_id      = aws_subnet.consul_subnet1.id
  route_table_id = aws_route_table.publicrt.id
}
resource "aws_route_table_association" "consul_publicassociation2" {
  subnet_id      = aws_subnet.consul_subnet2.id
  route_table_id = aws_route_table.publicrt.id
}
resource "aws_route_table_association" "consul_publicassociation3" {
  subnet_id      = aws_subnet.consul_subnet3.id
  route_table_id = aws_route_table.publicrt.id
}
#Associates the cts subnet with the public RT 
resource "aws_route_table_association" "cts_publicassociation" {
  subnet_id      = aws_subnet.cts_subnet.id
  route_table_id = aws_route_table.publicrt.id
}

/*
#Associates the service subnet with the public RT 
resource "aws_route_table_association" "service_publicassociation" {
  subnet_id      = aws_subnet.service_subnet.id
  route_table_id = aws_route_table.publicrt.id
}
*/
#####sec group 

resource "aws_security_group" "consul" {
  name        = "consul-cts"
  description = "consul-cts"
  vpc_id      = aws_vpc.nia_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8558
    to_port     = 8558
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*
###random 

resource "random_string" "env" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

output "env" {
  value = random_string.env.result
}
*/