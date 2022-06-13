/*variable "hvn_id" {
  description = "The ID of the HCP HVN."
  type        = string
  default     = "learn-hvn"
}
variable "cluster_id" {
  description = "The ID of the HCP Consul cluster."
  type        = string
  default     = "learn-hcp-consul"
}
variable "region" {
  description = "The region of the HCP HVN and Consul cluster."
  type        = string
  default     = "us-west-2"
}
variable "cloud_provider" {
  description = "The cloud provider of the HCP HVN and Consul cluster."
  type        = string
  default     = "aws"
}


variable HCP_CLIENT_SECRET {}
variable HCP_CLIENT_ID {}
*/
  variable "region" {}
  variable "vpc_cidr_block" {}
  variable "consul_cidr_block1" {}
  variable "consul_cidr_block2" {}
  variable "consul_cidr_block3" {}
  variable "cts_cidr_block" {}
  variable "service_cidr_block" {}
  #variable "availability_zone" {}
  variable "fw_cidr_block" {}
  
#  variable "instance_type" {}
  #variable "key_name" {}

  #variable "ami" {}
  #variable "instance_type_agents" {}

#adsd another change fors test