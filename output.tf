output "smtp_host" {
  description = "The SMTP endpoint"
  value       = "email-smtp.${var.aws_region}.amazonaws.com"
}

output "smtp_user_name" {
  description = "The SMTP user name"
  value       = aws_iam_access_key.smtp.id
}

output "smtp_password" {
  description = "The SMTP password"
  value       = aws_iam_access_key.smtp.ses_smtp_password_v4
}
