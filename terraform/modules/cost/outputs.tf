output "anomaly_monitor_arn" {
  value = aws_ce_anomaly_monitor.service.arn
}

output "monthly_budget_name" {
  value = aws_budgets_budget.monthly_cost.name
}
