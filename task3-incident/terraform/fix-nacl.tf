variable "pod_cidr" {
  type    = string
  default = "100.64.0.0/16"
}

resource "aws_network_acl_rule" "pods_to_postgres_in" {
  network_acl_id = aws_network_acl.protected.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.pod_cidr
  from_port      = 5432
  to_port        = 5432
}

resource "aws_network_acl_rule" "pods_to_valkey_in" {
  network_acl_id = aws_network_acl.protected.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.pod_cidr
  from_port      = 6379
  to_port        = 6379
}

resource "aws_network_acl_rule" "return_to_pods_out" {
  network_acl_id = aws_network_acl.protected.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.pod_cidr
  from_port      = 1024
  to_port        = 65535
}