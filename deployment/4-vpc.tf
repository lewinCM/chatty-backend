resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block //Rango de direcciones IPv4 para la VPC
  enable_dns_hostnames = true               //Habilita o deshabilita los nombres DNS para la VPC

  tags = merge(
    local.common_tags,                    //merge combina dos mapas en un solo mapa
    tomap({ "Name" = "${local.prefix}" }) //tomap convierte un valor en un mapa
  )
}
