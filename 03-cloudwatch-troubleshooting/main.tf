terraform {

  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source = "hashicorp/aws", version = "~> 5.0"
    }

  }


}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_id" {
  type        = string
  description = "ID of an existing EC2 lab instance"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {

  alarm_name          = "asrar-lab-high-cpu-${var.instance_id}"
  alarm_description   = "Learning alarm: average EC2 CPU above 70% for 10 minutes"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    InstanceId = var.instance_id
  }

  treat_missing_data = "missing"
  actions_enabled    = false
  tags = {
    Project = "aws-cloud-portfolio"
  }


}

resource "aws_cloudwatch_dashboard" "lab" {

  dashboard_name = "asrar-ec2-troubleshooting"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6, properties = {
          title = "EC2 CPU utilization", region = var.aws_region, period = 300, metrics = [["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]]
        }

      }
      ,
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6, properties = {
          title = "EC2 status checks", region = var.aws_region, period = 300, metrics = [["AWS/EC2", "StatusCheckFailed", "InstanceId", var.instance_id]]
        }

      }

    ]
    }
  )

}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.lab.dashboard_name
}

