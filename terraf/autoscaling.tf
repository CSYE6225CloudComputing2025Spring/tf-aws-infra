locals {
  public_subnet_ids = [
    aws_subnet.first_public.id,
    aws_subnet.second_public.id,
    aws_subnet.third_public.id
  ]
}

resource "aws_autoscaling_group" "webapp_asg" {
  name                    = "csye6225-asg"
  desired_capacity        = 3  # 
  min_size                = 3  # 
  max_size                = 5  # 
  default_instance_warmup = 60 #

  health_check_type         = "EC2"                   #不太一样
  health_check_grace_period = 300                     #
  vpc_zone_identifier       = local.public_subnet_ids #  使用你自己的子网

  launch_template {
    id      = aws_launch_template.webapp.id
    version = "$Latest" # 他也用的latest但不一样的写法
  }

  target_group_arns = [aws_lb_target_group.webapp_tg.arn] # 与 ALB 配合  EC2 instances launched in the auto-scaling group should now be load-balanced.

  tag {
    key                 = "Name"
    value               = "csye6225-instance"
    propagate_at_launch = true # add tags to the EC2 instances in your Auto Scaling Group
  }
}


resource "aws_autoscaling_policy" "scale_up" {
  name                   = "asg-scale-up-policy"
  scaling_adjustment     = 1                  #
  adjustment_type        = "ChangeInCapacity" #
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}


resource "aws_autoscaling_policy" "scale_down" {
  name                   = "asg-scale-down-policy"
  scaling_adjustment     = -1                 #
  adjustment_type        = "ChangeInCapacity" #
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm_scale_up" {
  alarm_name          = "cpu-high-asg-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5

  alarm_actions = [
    aws_autoscaling_policy.scale_up.arn
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm_scale_down" {
  alarm_name          = "cpu-low-asg-alarm"
  comparison_operator = "LessThanThreshold" # below
  evaluation_periods  = 2
  metric_name         = "CPUUtilization" # cpu
  namespace           = "AWS/EC2"        #
  period              = 60               #
  statistic           = "Average"        # average cpu usage
  threshold           = 3                # when average CPU usage is below 3%

  alarm_actions = [
    aws_autoscaling_policy.scale_down.arn #
  ]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name #
  }
}

