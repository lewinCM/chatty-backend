resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id //ID de la VPC

  tags = merge(
    local.common_tags,                              //merge combina dos mapas en un solo mapa
    tomap({ "Name" = "${local.prefix}-public-RT" }) // tomap convierte un valor en un mapa
  )
}

resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.public_route_table.id //ID de la tabla de rutas
  destination_cidr_block = var.global_destination_cidr_block     //Rango de direcciones IPv4 para la subred
  gateway_id             = aws_internet_gateway.main_igw.id      //ID de la puerta de enlace de Internet
  depends_on = [
    aws_route_table.public_route_table //Dependencia de la tabla de rutas
  ]
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_a.id         //ID de la subred
  route_table_id = aws_route_table.public_route_table.id //ID de la tabla de rutas
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}
