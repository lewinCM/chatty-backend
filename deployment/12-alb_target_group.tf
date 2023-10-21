resource "aws_alb_target_group" "server_backend_tg" {
  name                 = "${local.prefix}-tg" //Nombre del grupo de destino
  vpc_id               = aws_vpc.main.id      //ID de la VPC
  port                 = 5000                 # API server port
  protocol             = "HTTP"               //Protocolo
  deregistration_delay = 60                   //Tiempo de espera para la desregulación

  health_check {
    path                = "/health"      //Ruta de comprobación de estado
    port                = "traffic-port" //Puerto de comprobación de estado
    protocol            = "HTTP"         //Protocolo de comprobación de estado
    healthy_threshold   = 2              //Umbral de estado saludable
    unhealthy_threshold = 10             //Umbral de estado no saludable
    interval            = 120            //Intervalo de comprobación de estado
    timeout             = 100            //Tiempo de espera de comprobación de estado
    matcher             = "200"          //Código de estado de comprobación de estado
  }

  stickiness {
    type        = "app_cookie" //Tipo de persistencia
    cookie_name = "session"    //Nombre de la cookie
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-tg" }) //tomap convierte un valor en un mapa
  )
}
