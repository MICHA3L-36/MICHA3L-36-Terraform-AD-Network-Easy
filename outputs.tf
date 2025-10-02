output "dc_public_ip" {
  value = aws_instance.dc.public_ip
}

output "workstation1_public_ip" {
  value = aws_instance.workstation1.public_ip
}

output "workstation2_public_ip" {
  value = aws_instance.workstation2.public_ip
}
