variable "k3s_token" {
    default = null
}

resource "terraform_data" "k3s_token" {
    input = var.k3s_token
    lifecycle {
        ignore_changes = [
            input,
        ]
    }   
}

resource "openstack_compute_instance_v2" "basic" {
  name = "sb-test-metadata"
  image_name = "openhpc-ofed-RL9-240813-1317-1b370a36"
  flavor_name = "en1.xsmall"
  key_pair = "slurm-app-ci"
  security_groups = ["default"]

  metadata = {
    k3s_token = terraform_data.k3s_token.input
  }

  network {
    name = "slurmapp-ci"
  }
}
