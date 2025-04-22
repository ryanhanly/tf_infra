locals {
  # VM naming function that implements the standard
  # [cloud]-srv-[os]-[00-99]
  # [cloud] Azure = "azr", AWS = "aws"
  # [os] Windows = "win", linux = "lnx"
  # [00-99] = is the server count for that category
  generate_vm_name = function(cloud, os, index) {
    return "${cloud}-srv-${os}-${format("%02d", index)}"
  }
}