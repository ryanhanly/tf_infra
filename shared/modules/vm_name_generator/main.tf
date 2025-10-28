locals {
  vm_name = "${var.cloud_abbrev}-${var.region_abbrev}${var.os_code}-${var.bu_abbrev}-${var.env_abbrev}-${format("%03d", var.server_num)}"
}