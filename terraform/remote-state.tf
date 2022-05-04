terraform {
  backend "remote" {
    organization = "koudenpa"
    workspaces {
      name = "laravel-app-runner"
    }
  }
}
