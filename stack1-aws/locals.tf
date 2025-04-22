locals {
  # VM naming function that implements the standard
  # [cloud]-srv-[os]-[00-99]
  # [cloud] Azure = "azr", AWS = "aws"
  # [os] Windows = "win", linux = "lnx"
  # [00-99] = is the server count for that category
  generate_vm_name = function(cloud, os, index) {
    return "${cloud}-srv-${os}-${format("%02d", index)}"
  }

  # Preserve existing OS detection logic to determine OS shortname
  server_os_types = {
    for k, ami in data.aws_ami.server_ami : k => (
      can(regex("ubuntu", lower(ami.description))) ? "lnx" :
      can(regex("amazon linux", lower(ami.description))) ? "lnx" :
      can(regex("centos", lower(ami.description))) ? "lnx" :
      can(regex("debian", lower(ami.description))) ? "lnx" :
      can(regex("fedora", lower(ami.description))) ? "lnx" :
      can(regex("red hat", lower(ami.description))) ? "lnx" :
      can(regex("windows", lower(ami.description))) ? "win" :
      "lnx" # default for Linux
    )
  }
}