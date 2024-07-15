
# Select region
provider "aws" {
  region     = "us-east-1"
}
# Create VPC
resource "aws_vpc" "sdvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "sdvpc"
  }
}
# Create Subnet
resource "aws_subnet" "sdsubnet" {
  vpc_id     = aws_vpc.sdvpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "sdsubnet"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "sdgw" {
  vpc_id = aws_vpc.sdvpc.id
  tags = {
    Name = "sdgw"
  }
}
# Route Table
resource "aws_route_table" "sdrt" {
  vpc_id = aws_vpc.sdvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdgw.id
  }
  tags = {
    Name = "sdrt"
  }
}
# Route Table Association
resource "aws_route_table_association" "sdrta" {
  subnet_id      = aws_subnet.sdsubnet.id
  route_table_id = aws_route_table.sdrt.id
}
# Security Groups
resource "aws_security_group" "sdsg" {
  name        = "sdsg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.sdvpc.id
 ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
 description = "HTTPS traffic"
 from_port = 443
 to_port = 443
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
 description = "HTTP traffic"
 from_port = 0
 to_port = 65000
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
 }
 ingress {
 description = "Allow port 80 inbound"
 from_port   = 80
 to_port     = 80
 protocol    = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 ipv6_cidr_blocks = ["::/0"]
 }

  tags = {
    Name = "sdsg"
  }
}

# Create Instance
resource "aws_instance" "testserver" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.sdsubnet.id
  vpc_security_group_ids = [aws_security_group.sdsg.id]
  key_name = "valid"

user_data  = <<-EOF
 #!/bin/bash
     sudo apt-get update -y
EOF

tags = {
    Name = "slave1"
  }
}
