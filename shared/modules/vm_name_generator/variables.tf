variable "cloud_abbrev" {
  type        = string
  description = "Cloud abbreviation (e.g., aw)"
}

variable "region_abbrev" {
  type        = string
  description = "Region abbreviation (e.g., use)"
}

variable "os_code" {
  type        = string
  description = "OS code (e.g., lnx)"
}

variable "bu_abbrev" {
  type        = string
  description = "Business unit abbreviation (e.g., ret)"
}

variable "env_abbrev" {
  type        = string
  description = "Environment abbreviation (e.g., dev)"
}

variable "server_num" {
  type        = number
  description = "Server number (0-999)"
}