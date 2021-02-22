resource "aws_kms_key" "KMS_Key" {
  description             = "KMS for ${var.NAME}"
  deletion_window_in_days = 10
  tags = {
    Name = "KMS-${var.NAME}"
  }
}
