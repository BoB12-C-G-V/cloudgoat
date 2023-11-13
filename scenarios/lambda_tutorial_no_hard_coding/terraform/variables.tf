variable "profile" {
  description = "The AWS profile to use."
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources to."
  default     = "us-east-1"
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
  default     = "CloudGoat"
  type        = string
}

variable "scenario-name" {
  description = "Name of the scenario."
  default     = "lambda-tutorial"
  type        = string
}