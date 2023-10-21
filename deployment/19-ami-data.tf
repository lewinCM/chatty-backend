data "aws_ami" "ec2_ami" {
  most_recent = true //Última versión
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
    #  values = ["amzn2-ami-*-gp2"] //Nombre de la imagen
  }
  filter {
    name   = "root-device-type" //Tipo de dispositivo raíz
    values = ["ebs"]            //EBS
  }
  filter {
    name   = "virtualization-type" //Tipo de virtualización
    values = ["hvm"]               //HVM
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
