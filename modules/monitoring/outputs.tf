output "sns_topic_arn" {
  description = "ARN of the SNS topic for operational alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5xx CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx_errors.arn
}