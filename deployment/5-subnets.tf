# Public subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id               //ID de la VPC
  cidr_block              = var.vpc_public_subnets[0]     //Rango de direcciones IPv4 para la subred
  availability_zone       = var.vpc_availability_zones[0] //Zona de disponibilidad en la que se creará la subred
  map_public_ip_on_launch = true                          //Especifica si los recursos de la subred pueden tener direcciones IP públicas asignadas automáticamente

  tags = merge(
    local.common_tags,                              //merge combina dos mapas en un solo mapa
    tomap({ "Name" = "${local.prefix}-public-1a" }) //tomap convierte un valor en un mapa
  )
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_public_subnets[1] //
  availability_zone       = var.vpc_availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-1b" })
  )
}

# Private subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_private_subnets[0]
  availability_zone = var.vpc_availability_zones[0]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-1a" })
  )
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_private_subnets[1]
  availability_zone = var.vpc_availability_zones[1]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-1b" })
  )
}
