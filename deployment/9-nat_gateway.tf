resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id         //ID de la dirección IP elástica
  subnet_id     = aws_subnet.public_subnet_a.id //ID de la subred

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-nat-gw" })
  )
}
