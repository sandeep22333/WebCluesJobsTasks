# creating vpc

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# Getting Availability zones

data "aws_availability_zones" "available" {
  state = "available"
}

# creating subnets

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = var.subnet_name
  }
}

# creating Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.ig_name
  }
}

# creating Route Table

resource "aws_route_table" "publicroutetable" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.rt_name
  }
}

# Assosiating Subnets to route table

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.publicroutetable.id
}

#Create security group with firewall rules
resource "aws_security_group" "sg" {
  name        = var.security_group
  description = "security group for web server"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound from EC2 server
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = var.security_group
  }
}

#creating EC2 instance

resource "aws_instance" "Instance" {
  ami = var.ami_id
  key_name = var.key_name
  instance_type = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp3"
    delete_on_termination = true
  }
  user_data = <<EOF
#!/bin/bash
sudo yum upgrade -y &&
sudo yum update -y &&
sudo amazon-linux-extras install nginx1 -y &&
# Get the public IP address 
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) && 
# Create Nginx configuration
cat <<EOL > /etc/nginx/conf.d/myapp.conf
server {
    listen 80;
    server_name $PUBLIC_IP;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL &&
sudo systemctl start nginx &&
sudo systemctl enable nginx
EOF
  tags= {
    Name = "nginx"
  }
}