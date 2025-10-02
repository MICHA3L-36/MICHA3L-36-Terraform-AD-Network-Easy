# AWS region
variable "aws_region" {
  default = "us-east-1"
}

# Windows AMIs
variable "ami_dc" {
  description = "Windows Server AMI for Domain Controller"
  default     = "ami-xxxxxxxx"
}

variable "ami_ws" {
  description = "Windows 10/11 Workstation AMI"
  default     = "ami-xxxxxxxx"
}

# EC2 key pair
variable "key_name" {
  description = "EC2 Key Pair Name"
  default     = "my-key"
}

# Your public IP for security group
variable "my_ip" {
  description = "Your public IP address with /32"
  default     = "1.2.3.4/32"
}
