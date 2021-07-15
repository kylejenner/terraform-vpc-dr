resource "aws_vpc" "vpc_prod_tf" {
  provider             = aws.prod
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "prod-vpc-tf"
  }
}

resource "aws_vpc" "vpc_dr_tf" {
  provider             = aws.dr
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "dr-vpc-tf"
  }
}

resource "aws_vpc_peering_connection" "euwest1-euwest2-tf" {
  provider    = aws.prod
  peer_vpc_id = aws_vpc.vpc_dr_tf.id
  vpc_id      = aws_vpc.vpc_prod_tf.id
  #auto_accept = true
  peer_region = var.region-dr

}

resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.dr
  vpc_peering_connection_id = aws_vpc_peering_connection.euwest1-euwest2-tf.id
  auto_accept               = true
}

resource "aws_internet_gateway" "igw-prod" {
  provider = aws.prod
  vpc_id   = aws_vpc.vpc_prod_tf.id
}

resource "aws_internet_gateway" "igw-dr" {
  provider = aws.dr
  vpc_id   = aws_vpc.vpc_dr_tf.id
}

resource "aws_route_table" "internet_route_prod" {
  provider = aws.prod
  vpc_id   = aws_vpc.vpc_prod_tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-prod.id
  }
}

#Create route table in prod
data "aws_availability_zones" "azs" {
  provider = aws.prod
  state    = "available"
}

#Create subnet # 1 in prod
resource "aws_subnet" "subnet_1" {
  provider          = aws.prod
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_prod_tf.id
  cidr_block        = "10.0.1.0/24"
}

#Create subnet #2  in prod
resource "aws_subnet" "subnet_2" {
  provider          = aws.prod
  vpc_id            = aws_vpc.vpc_prod_tf.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.0.2.0/24"
}

#Create route table in dr
resource "aws_route_table" "internet_route_dr" {
  provider = aws.dr
  vpc_id   = aws_vpc.vpc_dr_tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-dr.id
  }
}

#Create subnet in dr
resource "aws_subnet" "subnet_1_dr" {
  provider   = aws.dr
  vpc_id     = aws_vpc.vpc_dr_tf.id
  cidr_block = "10.1.1.0/24"
}

#Create association between route table and subnet_1 in prod
resource "aws_route_table_association" "internet_association_prod" {
  provider       = aws.prod
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.internet_route_prod.id
}

#Create association between route table and subnet_1_oregon in us-west-2
resource "aws_route_table_association" "internet_association_dr" {
  provider       = aws.dr
  subnet_id      = aws_subnet.subnet_1_dr.id
  route_table_id = aws_route_table.internet_route_dr.id
}

#Create route in prod subnet for comms with peered VPC
resource "aws_route" "to_vpc-peered" {
  provider                  = aws.prod
  route_table_id            = aws_route_table.internet_route_prod.id
  destination_cidr_block    = "10.1.1.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.euwest1-euwest2-tf.id

}
#Create route in dr subnet for comms with peered VPC
resource "aws_route" "to_vpc-peered_dr" {
  provider                  = aws.dr
  route_table_id            = aws_route_table.internet_route_dr.id
  destination_cidr_block    = "10.0.1.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.euwest1-euwest2-tf.id

}

data "aws_ssm_parameter" "prod_ami" {
  provider = aws.prod
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}