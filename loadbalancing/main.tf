###---loadbalancing/main.tf---

resource "aws_lb" "cicd_lb" {
  name               = "cicd-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg]
  subnets            = tolist(var.public_subnet)

  depends_on = [
    var.database_asg
  ]
}

resource "aws_lb_target_group" "cicd_tg" {
  name     = "cicd-lb-tg-${substr(uuid(), 0, 3)}"
  protocol = var.tg_protocol
  port     = var.tg_port
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_listener" "cicd_lb_listener" {
  load_balancer_arn = aws_lb.cicd_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cicd_tg.arn
  }
}