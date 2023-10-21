# Get your already created hosted zone
data "aws_route53_zone" "main" {
  name         = var.main_api_server_domain //Nombre del dominio
  private_zone = false
}
