resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id //ID de la VPC

  tags = merge(
    local.common_tags,                            //merge combina dos mapas en un solo mapa
    tomap({ "Name" = "${local.prefix}-vpc-igw" }) //tomap convierte un valor en un mapa
  )
}
