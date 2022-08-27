###---network/outputs.tf---

output "vpc_id" {
  value = aws_vpc.cicd_vpc.id
}

output "public_sg" {
  value = aws_security_group.cicd_public_sg.id
}

output "private_sg" {
  value = aws_security_group.cicd_private_sg.id
}

output "web_sg" {
  value = aws_security_group.cicd_web_sg.id
}

output "private_subnet" {
  value = aws_subnet.cicd_private_subnet[*].id
}

output "public_subnet" {
  value = aws_subnet.cicd_public_subnet[*].id
}