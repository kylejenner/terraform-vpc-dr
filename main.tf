resource "aws_instance" "vm_tf" {
  provider      = aws.prod
  ami           = data.aws_ssm_parameter.prod_ami.value
  subnet_id     = aws_subnet.subnet_1.id
  instance_type = "t3.micro"
  tags = {
    Name = "vm-tf"
  }
}