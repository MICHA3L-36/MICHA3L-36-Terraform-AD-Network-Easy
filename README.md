# Home Active Directory Lab Deployment with Terraform


This repository provides a **simple lab deployment** using Terraform on AWS.  
It creates a **VPC, subnet, 1 Domain Controller, and 2 Windows workstations**, intended for to practice pentesting Active Directory, RDP, SSH, and IIS.

NOTE! You need to setup the Windows servers in AWS Console and then put the AMI and Key Pair in the fields below, this terraform project won't configure the OS installation!

---

## Features

- Single VPC (`10.10.10.0/24`) with private subnet
- 1 Domain Controller (Windows Server)
- 2 Workstations (Windows 10/11 or Server)
- Security group with restricted access:
  - RDP (3389)
  - SSH (22)
  - HTTP (80)
- Outputs public IPs for easy access

---

## Prerequisites

- AWS account and active subscription
- Terraform installed locally
- AWS Access Key & Secret Key configured
- Your **public IP address** (can be found at [https://whatismyipaddress.com](https://whatismyipaddress.com))

---


### Sets the AWS region for resources:

```hcl
provider "aws" {
  region = "us-east-1"
}
````

### VPC & Subnet

Creates a private network:

```hcl
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.10.10.0/24"
}

resource "aws_subnet" "lab_subnet" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = "10.10.10.0/24"
}
```

### Internet Gateway & Routing

Allows instances to reach the internet:

```hcl
resource "aws_internet_gateway" "lab_gw" {
  vpc_id = aws_vpc.lab_vpc.id
}

resource "aws_route_table" "lab_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_gw.id
  }
}

resource "aws_route_table_association" "lab_rta" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_rt.id
}
```

### Security Group

Restricts access to your **public IP**:

```hcl
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
    cidr_blocks = ["YOUR_PUBLIC_IP/32"] # HTTP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### EC2 Instances

Domain Controller & Workstations:

```hcl
resource "aws_instance" "dc" {
  ami                    = "ami-xxxxxxxx"   # AWS Console > EC2 > AMIs (Windows Server 2022)
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.lab_subnet.id
  private_ip             = "10.10.10.250"
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = "my-key"         # AWS EC2 > Key Pairs
}

resource "aws_instance" "workstation1" {
  ami                    = "ami-xxxxxxxx"   # AWS Console > EC2 > AMIs (Windows 10/11)
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.lab_subnet.id
  private_ip             = "10.10.10.10"
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = "my-key"
}

resource "aws_instance" "workstation2" {
  ami                    = "ami-xxxxxxxx"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.lab_subnet.id
  private_ip             = "10.10.10.50"
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = "my-key"
}
```

* Replace `ami-xxxxxxxx` with a Windows AMI from the AWS Console.
* Replace `my-key` with your EC2 key pair.
* Static private IPs make lab networking predictable.

### Outputs

```hcl
output "dc_public_ip" {
  value = aws_instance.dc.public_ip
}

output "workstation1_public_ip" {
  value = aws_instance.workstation1.public_ip
}

output "workstation2_public_ip" {
  value = aws_instance.workstation2.public_ip
}
```

Provides the public IPs of all instances for RDP/SSH connections.

### Deployment Steps

1. Replace placeholders in `main.tf`:

   * `ami-xxxxxxxx` → Windows AMI ID
   * `my-key` → Your EC2 key pair
   * `YOUR_PUBLIC_IP` → Your public IP with `/32`
2. Initialize Terraform:

```hcl
terraform init
```

3. Preview deployment:

```hcl
terraform plan
```

4. Apply deployment:

```hcl
terraform apply
```

5. Connect via RDP (Windows) or SSH
```bash
xfreerdp /u:Administrator /p:'PASSWORD' /v:10.10.10.250:3389
```

