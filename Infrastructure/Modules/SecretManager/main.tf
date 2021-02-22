#***  Terraform Code to create AWS Secret manager 

resource "aws_secretsmanager_secret" "SECRETMANAGER" {
  name                    = var.NAME
  recovery_window_in_days = var.RETENTION
  policy                  = var.POLICY
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.NAME
  }
  kms_key_id = var.KMS_KEY
}
