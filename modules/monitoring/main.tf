resource "aws_sns_topic" "alerts" {
  name = "securechain-alerts-${var.environment}"

  tags = {
    Name = "securechain-alerts-${var.environment}"
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "securechain-alb-5xx-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Triggered when ALB target 5XX error count exceeds 5 in 5 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = {
    Name = "securechain-alarm-alb-5xx-${var.environment}"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_high_latency" {
  alarm_name          = "securechain-alb-high-latency-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  extended_statistic  = "p95"
  threshold           = 2.0
  alarm_description   = "Triggered when ALB P95 target response time exceeds 2 seconds for 2 consecutive minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = {
    Name = "securechain-alarm-alb-latency-${var.environment}"
  }
}

resource "aws_cloudwatch_metric_alarm" "portal_unhealthy_hosts" {
  alarm_name          = "securechain-portal-unhealthy-hosts-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Triggered when Portal target group has 1 or more unhealthy hosts"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.portal_target_group_arn_suffix
  }

  tags = {
    Name = "securechain-alarm-portal-unhealthy-${var.environment}"
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_unhealthy_hosts" {
  alarm_name          = "securechain-backend-unhealthy-hosts-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Triggered when Backend target group has 1 or more unhealthy hosts"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.backend_target_group_arn_suffix
  }

  tags = {
    Name = "securechain-alarm-backend-unhealthy-${var.environment}"
  }
}