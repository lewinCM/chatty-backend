resource "aws_alb" "application_load_balancer" {
  name                       = "${local.prefix}-alb"                                          //Nombre del balanceador de carga
  load_balancer_type         = "application"                                                  //Tipo de balanceador de carga
  internal                   = false                                                          //Balanceador de carga interno
  subnets                    = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id] //Subredes
  security_groups            = [aws_security_group.alb_sg.id]                                 //Grupos de seguridad
  enable_deletion_protection = false                                                          //Protección de eliminación
  ip_address_type            = "ipv4"                                                         //Tipo de dirección IP
  idle_timeout               = 300                                                            //Tiempo de espera de inactividad

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ALB" }) //tomap convierte un valor en un mapa
  )
}

resource "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn //ARN del balanceador de carga
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.https_ssl_policy
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  depends_on = [
    aws_acm_certificate_validation.cert_validation
  ]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.server_backend_tg.arn
  }
}

resource "aws_alb_listener" "alb_http_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener_rule" "alb_https_listener_rule" {
  listener_arn = aws_alb_listener.alb_http_listener.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.server_backend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

}
