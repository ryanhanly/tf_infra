variable "cloud" {
  type        = string
  description = "Cloud provider (aws, azure, gcp)"
}

variable "environment" {
  type        = string
  description = "Environment (development, test, production)"
}

variable "business_unit" {
  type        = string
  description = "Business unit (retail, marketing, etc.)"
}

variable "os" {
  type        = string
  description = "OS type (linux, windows)"
}

variable "server_num" {
  type        = number
  description = "Server number"
}

variable "additional_tags" {
  type        = map(string)
  description = "Extra tags"
  default     = {}
}