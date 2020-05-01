locals {
  dmarc_record = join("", [
    "v=DMARC1;",
    "p=${var.dmarc_policy};",
    length(var.dmarc_rua) > 0 ? format("rua=mailto:%s;", var.dmarc_rua) : ""
  ])
}


data "aws_route53_zone" "default" {
  name         = var.zone
  private_zone = false
}

data "aws_iam_policy_document" "ses_smtp" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}


resource "aws_ses_domain_identity" "default" {
  domain = var.domain
}

resource "aws_route53_record" "verification_token" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.default.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.default.verification_token]
}

resource "aws_ses_domain_identity_verification" "default" {
  domain     = aws_ses_domain_identity.default.id
  depends_on = [aws_route53_record.verification_token]
}

resource "aws_ses_domain_dkim" "default" {
  domain = aws_ses_domain_identity.default.domain
}

resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "${aws_ses_domain_dkim.default.dkim_tokens[count.index]}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.default.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_ses_domain_mail_from" "default" {
  domain           = aws_ses_domain_identity.default.domain
  mail_from_domain = "${var.mail_from_subdomain}.${var.domain}"
}

resource "aws_route53_record" "mx" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = aws_ses_domain_mail_from.default.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

resource "aws_route53_record" "dmarc" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [local.dmarc_record]
}

resource "aws_iam_user" "smtp" {
  name = "${var.prefix}-SMTP"
}

resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}

resource "aws_iam_user_policy" "this" {
  name = "${var.prefix}-SMTP"
  user   = aws_iam_user.smtp.name
  policy = data.aws_iam_policy_document.ses_smtp.json
}
