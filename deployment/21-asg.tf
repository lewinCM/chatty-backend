resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  name                      = "${local.prefix}-ASG"                                            //Nombre del grupo de escalado automático
  vpc_zone_identifier       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id] //Identificador de zona VPC
  max_size                  = 1                                                                //Tamaño máximo
  min_size                  = 1                                                                //Tamaño mínimo
  desired_capacity          = 1                                                                //Capacidad deseada
  launch_configuration      = aws_launch_configuration.asg_launch_configuration.name           //Configuración de lanzamiento
  health_check_type         = "ELB"                                                            //Tipo de comprobación de salud
  health_check_grace_period = 600                                                              //Período de gracia de comprobación de salud
  default_cooldown          = 150                                                              //Enfriamiento predeterminado
  force_delete              = true                                                             //Eliminar forzadamente
  target_group_arns         = [aws_alb_target_group.server_backend_tg.arn]                     //ARN del grupo objetivo
  enabled_metrics = [
    "GroupMinSize",            //Métricas habilitadas de tamaño mínimo
    "GroupMaxSize",            //Métricas habilitadas de tamaño máximo
    "GroupDesiredCapacity",    //Métricas habilitadas de capacidad deseada
    "GroupInServiceInstances", //Métricas habilitadas de instancias en servicio
    "GroupTotalInstances"      //Métricas habilitadas de instancias totales
  ]

  lifecycle {
    create_before_destroy = true //Crear antes de destruir
  }

  depends_on = [
    aws_elasticache_replication_group.chatapp_redis_cluster //Dependencia del grupo de replicación
  ]

  tag {
    key                 = "Name"
    value               = "EC2-ASG-${terraform.workspace}"
    propagate_at_launch = true //Propagar en el lanzamiento
  }

  tag {
    key                 = "Type"
    value               = "Backend-${terraform.workspace}"
    propagate_at_launch = true //Propagar en el lanzamiento
  }
}
