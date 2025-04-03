variable "profile" {
  type        = string
  description = "Aws profile name"
}

variable "key_name" {
  type    = string
  default = "csye6225"
}

variable "db_password" {
  description = "The password for RDS"
  type        = string
  sensitive   = true
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