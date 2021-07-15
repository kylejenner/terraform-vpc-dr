output "VPC-ID-PROD1" {
  value = aws_vpc.vpc_prod_tf.id
}

output "VPC-ID-DR" {
  value = aws_vpc.vpc_dr_tf.id
}

output "PEERING-CONNECTION-ID" {
  value = aws_vpc_peering_connection.euwest1-euwest2-tf.id
}

output "ami_id" {
  value     = data.aws_ssm_parameter.prod_ami.value
  sensitive = "true"

}