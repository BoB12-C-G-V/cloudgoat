variable "profile" {
  description = "The AWS profile to use."
  type        = string
}

#Required: AWS Region
variable "region" {
  description = "The AWS region to deploy resources to."
  default     = "us-east-1"
  type        = string
}
#Required: CGID Variable for unique naming
variable "cgid" {
  description = "CGID variable for unique naming."
  type        = string
}
variable "ami" {
  default = "ami-041feb57c611358bd"
}
variable "instance_type" {
  default = "t2.micro"
}

variable "cg_whitelist" {
  description = "User's public IP address(es)."
  type        = list(string)
}

variable "stack-name" {
  description = "Name of the stack."
  default     = "CloudGoat"
  type        = string
}
variable "scenario-name" {
  default = "Public_EBS_Snapshot"
}





