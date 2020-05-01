variable "prefix" {
  description = "The common prefix for names."
  type        = string
  default     = "Jira"
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "domain" {
  description = "The DNS domain to send emails from"
  type        = string
}

variable "zone" {
  description = "The name of the DNS zone in AWS Route53."
  type        = string
}

variable "mail_from_subdomain" {
  description = "The subdomain used for the MX record"
  type        = string
  default     = "mail"
}

variable "dmarc_policy" {
  description = "DMARC policy"
  type        = string
  default     = "none"
}

variable "dmarc_rua" {
  description = "DMARC Reporting URI of aggregate reports, expects an email address."
  type        = string
  default     = ""
}
