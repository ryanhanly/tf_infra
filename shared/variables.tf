variable "allowed_business_units" {
  type = list(string)
  default = ["retail", "marketing", "finance", "hr", "it"]
}

variable "allowed_environments" {
  type = list(string)
  default = ["development", "test", "production"]
}

variable "cloud_abbrev" {
  type        = string
  description = "Abbreviated cloud name for VM naming (e.g., 'aw' for AWS)"
}

variable "region_abbrev" {
  type        = string
  description = "Abbreviated region name for VM naming (e.g., 'lnd' for eu-west-2)"

}

variable "aws_region" {
  type        = string
  description = "AWS Region for deploying resources"
}