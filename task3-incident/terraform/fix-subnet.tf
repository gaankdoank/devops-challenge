variable "protected_subnet_ids" {
  description = "protected subnet"
  type        = list(string)
}

resource "aws_db_proxy" "app" {
  name                   = "helios-ai-prod-app-proxy"
  engine_family          = "POSTGRESQL"
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_subnet_ids         = var.protected_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds_proxy.id]

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.db_app.arn
  }
}