#Required: AWS Profile
variable "profile" {

}

variable "base_profile" {}
#Required: AWS Region
variable "region" {

}
#Required: CGID Variable for unique naming
variable "cgid" {}
variable "ami" {}
variable "instance_type" {}

#Required: User's Public IP Address(es)
variable "cg_whitelist" {
  type    = list(string)
  default = []
}

#Stack Name
variable "stack-name" {
  default = "CloudGoat"
}
variable "scenario-name" {
  default = "ec2_sg_change"
}

variable "root_password" {
  default = "1234"
}


#====KMS====
variable "key_spec" {
  default = "SYMMETRIC_DEFAULT"
}

variable "rotation_enabled" {
  default = false
}

variable "enabled" {
  default = true
}


