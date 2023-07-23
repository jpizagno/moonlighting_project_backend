variable "access_key" {}
variable "secret_key" {}

variable "region" {
    default = "eu-central-1"
}

variable "amis" {
  type = map(string)
  default = {
    "eu-central-1" =  "ami-3a70df55"   
  }
}