resource "aws_eip" "elastic_ip" {
  depends_on = [
    aws_internet_gateway.main_igw //Dependencia de la puerta de enlace de Internet
  ]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-eip" }) //tomap convierte un valor en un mapa
  )
}
