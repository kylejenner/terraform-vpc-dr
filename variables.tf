variable "profile" {
  type    = string
  default = "demo"
}

variable "region-prod" {
  type    = string
  default = "us-east-1"
}

variable "region-dr" {
  type    = string
  default = "eu-west-2"
}

variable "instance-type" {
  type    = string
  default = "t3.micro"

}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}