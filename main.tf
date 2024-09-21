resource "terraform_data" "seed" {
}

resource "openstack_compute_instance_v2" "basic" {
  name = "sb-test-metadata"
  image_name = "openhpc-ofed-RL9-240813-1317-1b370a36"
  flavor_name = "en1.xsmall"
  key_pair = "slurm-app-ci"
  security_groups = ["default"]

  metadata = {
    k3s_token = terraform_data.seed.id # e.g. 9e478484-1e3b-633b-ea56-68deb67638a2
  }

  network {
    name = "slurmapp-ci"
  }
}
