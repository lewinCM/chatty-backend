resource "aws_launch_configuration" "asg_launch_configuration" {
  name                        = "${local.prefix}-launch-config"
  image_id                    = data.aws_ami.ec2_ami.id
  instance_type               = var.ec2_instance_type
  key_name                    = "keyPairSocial"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups             = [aws_security_group.autoscaling_group_sg.id]
  user_data                   = filebase64("${path.module}/userdata/user-data.sh") //Datos de usuario

  lifecycle {
    create_before_destroy = true //Crear antes de destruir
  }
}
