###---compute/outputs.tf---

output "database_asg" {
  value = aws_autoscaling_group.cicd_webserver
}

output "public_subnet" {
  value = aws_launch_template.cicd_bastion_host
}