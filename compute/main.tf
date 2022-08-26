###---compute/main.tf---

data "aws_ami" "server_ami" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

 
}

resource "aws_launch_template" "bastion_host" {
  name_prefix            = "bastion_host"
  image_id               = data.aws_ami.server_ami.id
  instance_type          = var.bastion_instance_type
  vpc_security_group_ids = [var.public_sg]
  key_name               = var.key_name

  tags = {
    Name = "bastion"
  }
}

resource "aws_autoscaling_group" "project_bastion" {
  name                = "project_bastion"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.bastion_host.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "project_database" {
  name_prefix            = "project_database"
  image_id               = data.aws_ami.server_ami.id
  instance_type          = var.database_instance_type
  vpc_security_group_ids = [var.private_sg]
  key_name               = var.key_name
  user_data              = filebase64("bash_script.sh")

  tags = {
    Name = "project_database"
  }
}

resource "aws_autoscaling_group" "project_database" {
  name                = "project_database"
  vpc_zone_identifier = tolist(var.public_subnet)
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.project_database.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.project_database.id
  # elb                    = var.elb
  alb_target_group_arn = var.alb_tg
}