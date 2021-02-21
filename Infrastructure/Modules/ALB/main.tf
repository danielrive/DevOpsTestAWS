# Terraform code to create Target Groups and ALBs


resource "aws_alb" "ALB" {
  count              = var.CREATE_ALB == true ? 1 : 0
  name               = "ALB-${var.NAME}"
  subnets            = [var.SUBNETS[0], var.SUBNETS[1]]
  security_groups    = [var.SECURITY_GROUP]
  load_balancer_type = "application"
  internal           = false
  enable_http2       = true
  idle_timeout       = 30
}

# ALB Listenet for HTTPS
resource "aws_alb_listener" "HTTPS_LISTENER" {
  count             = var.CREATE_ALB == true ? (var.ENABLE_HTTPS == true ? 1 : 0) : 0
  load_balancer_arn = aws_alb.ALB[0].id
  port              = "443"
  protocol          = "HTTPS"
  default_action {
    target_group_arn = var.TARGET_GROUP
    type             = "forward"
  }
  depends_on = [aws_alb.ALB]

}


# ALB Listener for HTTP

resource "aws_alb_listener" "HTTP_LISTENER" {
  count             = var.CREATE_ALB == true ? 1 : 0
  load_balancer_arn = aws_alb.ALB[0].id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = var.TARGET_GROUP
    type             = "forward"
  }
  depends_on = [aws_alb.ALB]

}

# Target Groups for ALB


resource "aws_alb_target_group" "TARGET_GROUP" {
  count                = var.CREATE_TARGET_GROUP == true ? 1 : 0
  name                 = "TG-${var.NAME}"
  port                 = var.PORT
  protocol             = var.PROTOCOL
  vpc_id               = var.VPC
  target_type          = var.TG_TYPE
  deregistration_delay = 5
  health_check {
    enabled             = true
    interval            = 5
    path                = var.HEALTH_CHECK_PATH
    port                = var.HEALTH_CHECK_PORT
    protocol            = var.PROTOCOL
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
  lifecycle {
    create_before_destroy = true
  }
}
