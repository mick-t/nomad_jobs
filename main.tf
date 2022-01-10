terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
    }
  }
  required_version = ">= 0.13"
}

provider "nomad" {
  address = "http://server-a-1:4646"
}

variable "tfc_agent_token" {
  default = ""
}

resource "nomad_job" "hashicups" {
  jobspec = file("${path.module}/hashicups-multiregion.nomad")
}

resource "nomad_job" "prometheus" {
  jobspec = file("${path.module}/as-prometheus.nomad")
}

resource "nomad_job" "autoscaler" {
  jobspec = file("${path.module}/as-das-autoscaler.nomad")
}
