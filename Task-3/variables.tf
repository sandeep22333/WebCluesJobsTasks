variable "vpc_cidr" {
    type = string
	description = "VPC cicd Range"
}

variable "vpc_name" {
    type = string
	description = "VPC cicd Range"
}

variable "subnet_cidr" {
    type = string
	description = "Subnet cidr Range"
}

variable "subnet_name" {
    type = string
	description = "subnet name"
}

variable "ig_name" {
    type = string
	description = "internet gateway name"
}

variable "rt_name" {
    type = string
	description = "route table name"
}

variable "security_group" { 
    description = "Name of security group" 
}

variable "ami_id" { 
    description = "AMI for Ubuntu Ec2 instance"  
}

variable "key_name" { 
    description = " SSH keys to connect to ec2 instance" 
}

variable "instance_type" { 
    description = "instance type for ec2" 
}