variable "profile" {
  description = "The AWS profile to use."
  default     = "default"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources to."
  default     = "ap-northeast-2"
  type        = string
}

variable "lecture_id" {
  description = "CGID variable for unique naming."
  type        = string
}

variable "whitelist" {
  description = "User's public IP address(es)."
  type        = list(string)
}

variable "stack-name" {
  description = "Name of the stack."
  default     = "BoB12th-CGV"
  type        = string
}

variable "scenario-name" {
  description = "Name of the scenario."
  default     = "Public S3 Tutorial"
  type        = string
}