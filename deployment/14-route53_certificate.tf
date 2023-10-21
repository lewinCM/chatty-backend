resource "aws_acm_certificate" "dev_cert" {
  domain_name       = var.dev_api_server_domain //Nombre del dominio
  validation_method = "DNS"                     //Método de validación

  tags = {
    "Name"      = local.prefix        //Nombre del certificado
    Environment = terraform.workspace //Entorno de Terraform
  }

  lifecycle {
    create_before_destroy = true //Crea el nuevo recurso antes de destruir el anterior
  }
}

resource "aws_route53_record" "cert_validation_record" {
  allow_overwrite = false                                                                                     //Permite sobrescribir el registro
  ttl             = 60                                                                                        //Tiempo de vida del registro
  zone_id         = data.aws_route53_zone.main.zone_id                                                        //ID de la zona
  name            = tolist(aws_acm_certificate.dev_cert.domain_validation_options)[0].resource_record_name    //Nombre del registro
  records         = [tolist(aws_acm_certificate.dev_cert.domain_validation_options)[0].resource_record_value] //Valor del registro
  type            = tolist(aws_acm_certificate.dev_cert.domain_validation_options)[0].resource_record_type    //Tipo de registro
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.dev_cert.arn                 //ARN del certificado
  validation_record_fqdns = [aws_route53_record.cert_validation_record.fqdn] //Nombre completo del registro
}
