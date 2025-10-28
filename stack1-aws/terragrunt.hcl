remote_state {
  backend = "remote"
  config = {
    organization = "seneca_org"
    workspaces {
      name = "stack1-aws-core"
    }
  }
}