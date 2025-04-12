variable "profile" {
  type        = string
  description = "Aws profile name"
}

variable "key_name" {
  type    = string
  default = "csye6225"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "subdomain" {
  type    = string
  default = ""
}

variable "domain" {
  type    = string
  default = ""
}

variable "db_port" {
  type    = string
  default = "3306"
}

variable "db_user" {
  type    = string
  default = "root"
}

variable "db_name" {
  type    = string
  default = "cloud_computing"
}

variable "certificate_arn" {
  description = "The ACM certificate ARN for the environment"
  type        = string
  default = ""
}