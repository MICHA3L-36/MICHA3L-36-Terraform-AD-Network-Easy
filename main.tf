provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.10.10.0/24"
}

# Subnet
resource "aws_subnet" "lab_subnet" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = "10.10.10.0/24"
}

# Internet Gateway
resource "aws_internet_gateway" "lab_gw" {
  vpc_id = aws_vpc.lab_vpc.id
}

# Route Table
resource "aws_route_table" "lab_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_gw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "lab_rta" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_rt.id
}

# Security Group
resource "aws_security_group" "lab_sg" {
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"] # RDP
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"] # SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"] # HTTP/IIS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Domain Controller
resource "aws_instance" "dc" {
  ami                    = "ami-xxxxxxxx"   # AWS Console > EC2 > AMIs (Windows Server)
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.lab_subnet.id
  private_ip             = "10.10.10.10"
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = "my-key"         # AWS EC2 > Key Pairs
}

# Workstation 1
resource "aws_instance" "workstation1" {
  ami                    = "ami-xxxxxxxx"   # AWS Console > EC2 > AMIs (Windows 10/11)
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.lab_subnet.id
  private_ip             = "10.10.10.11"
  vpc_security_group_ids = [aws_security_group.lab]()_
