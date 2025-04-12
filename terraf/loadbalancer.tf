resource "aws_lb_target_group" "webapp_tg" {
  name     = "nodejs-alb-target-group" #
  port     = 8080                      # port that application in instance listen on
  protocol = "HTTP"                    #
  vpc_id   = aws_vpc.my_vpc.id         # target type is default to "instance"

  health_check {
    path                = "/healthz" #
    protocol            = "HTTP"     #
    matcher             = "200"      #
    interval            = 30         # interval is greater than the timeout  
    timeout             = 5          #
    healthy_threshold   = 2          #
    unhealthy_threshold = 2          #
  }
}

resource "aws_lb" "webapp_alb" {
  name               = "nodejs-application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id] # lb sg
  subnets            = local.public_subnet_ids                  # 部署在多个 AZ 的子网中

  tags = {
    Name = "nodejs-application-load-balancer"
  }
}

resource "aws_lb_listener" "webapp_http_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn #
  port              = 443                   #  Set up an Application load balancer to accept HTTP traffic on the port 80
  protocol          = "HTTPS"               #
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"                         #
    target_group_arn = aws_lb_target_group.webapp_tg.arn # forward traffic that load balancer accepts to target group
  }
}
