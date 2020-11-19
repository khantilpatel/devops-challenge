variable "app_name" {
  default = "php_app"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = ""
}

variable "public_key" {
  default = "~/.ssh/app-key.pub"
}

variable "private_key" {
  default = "~/.ssh/app-key.pem"
}

