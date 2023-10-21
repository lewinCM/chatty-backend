# Chatty App Backend
22-asg_policy.tf
resource "aws_autoscaling_policy" "asg_scale_out_policy" {
  name                   = "ASG-SCALE-OUT-POLICY"
  autoscaling_group_name = aws_autoscaling_group.ec2_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1
  cooldown               = 150
  depends_on = [
    aws_autoscaling_group.ec2_autoscaling_group
  ]
}

resource "aws_cloudwatch_metric_alarm" "ec2_scale_out_alarm" {
  alarm_name          = "EC2-SCALE-OUT-ALARM"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = 50
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_autoscaling_group.name
  }
  alarm_actions = [aws_autoscaling_policy.asg_scale_out_policy.arn]
  depends_on = [
    aws_autoscaling_group.ec2_autoscaling_group
  ]
}

resource "aws_autoscaling_policy" "asg_scale_in_policy" {
  name                   = "ASG-SCALE-IN-POLICY"
  autoscaling_group_name = aws_autoscaling_group.ec2_autoscaling_group.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1
  cooldown               = 150
  depends_on = [
    aws_autoscaling_group.ec2_autoscaling_group
  ]
}

resource "aws_cloudwatch_metric_alarm" "ec2_scale_in_alarm" {
  alarm_name          = "EC2-SCALE-IN-ALARM"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = 10
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_autoscaling_group.name
  }
  alarm_actions = [aws_autoscaling_policy.asg_scale_in_policy.arn]
  depends_on = [
    aws_autoscaling_group.ec2_autoscaling_group
  ]
}


24-s3.tf
resource "aws_s3_bucket" "code_deploy_backend_bucket" {
  bucket        = "${local.prefix}-app"
  force_destroy = true

  tags = local.common_tags
}

resource "aws_s3_bucket_acl" "code_deploy_bucket_acl" {
  bucket = aws_s3_bucket.code_deploy_backend_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.code_deploy_backend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_versioning" "code_deploy_bucket_versioning" {
  bucket = aws_s3_bucket.code_deploy_backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}



25-iam_code_deploy.tf
resource "aws_iam_role" "code_deploy_iam_role" {
  name = var.code_deploy_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.code_deploy_iam_role.name
}


26-code_deploy.tf
resource "aws_codedeploy_app" "code_deploy_app" {
  name             = "${local.prefix}-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "code_deploy_app_group" {
  app_name               = aws_codedeploy_app.code_deploy_app.name
  deployment_group_name  = "${local.prefix}-group"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.code_deploy_iam_role.arn
  autoscaling_groups     = [aws_autoscaling_group.ec2_autoscaling_group.name]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info {
      name = aws_alb_target_group.server_backend_tg.name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  provisioner "local-exec" {
    command    = file("./userdata/delete-asg.sh")
    when       = destroy
    on_failure = continue

    environment = {
      ENV_TYPE = "Backend-${terraform.workspace}"
    }
  }
}
delete-asg
#!/bin/bash

ASG=$(aws autoscaling describe-auto-scaling-groups --no-paginate --output text --query "AutoScalingGroups[? Tags[? (Key=='Type') && Value=='$ENV_TYPE']]".AutoScalingGroupName)
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $ASG --force-delete



npm install -D tsc-alias 
npm uninstall ttypescript
