###---compute/main.tf---

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}

resource "aws_launch_template" "cicd_bastion_host" {
  name_prefix            = "cicd_bastion_host"
  image_id               = data.aws_ami.server_ami.id
  instance_type          = var.bastion_instance_type
  vpc_security_group_ids = [var.public_sg]
  key_name               = var.key_name

  tags = {
    Name = "cicd-bastion"
  }
}

resource "aws_autoscaling_group" "cicd_bastion" {
  name                = "cicd_bastion"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.cicd_bastion_host.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "cicd_webserver" {
  name_prefix            = "cicd_webserver"
  image_id               = data.aws_ami.server_ami.id
  instance_type          = var.webserver_instance_type
  vpc_security_group_ids = [var.private_sg]
  key_name               = var.key_name
  user_data              = filebase64("bash_script.sh")

  tags = {
    Name = "cicd-webserver"
  }
}

resource "aws_autoscaling_group" "cicd_webserver" {
  name                = "cicd_webserver"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.cicd_webserver.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.cicd_webserver.id
  # elb                    = var.elb
  lb_target_group_arn = var.cicd_alb_tg
}