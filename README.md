# tf-state-data-experiments

For k3s, we need to define `k3s_token` which is a shared secret between the "server" (control) and "agent" (all other) nodes to allow the latter to join the cluster.

We want k3s to start on boot (using ansible-init), without having to run "normal" ansible across the cluster. Therefore we've chosen to inject this as a metadata key (rather than e.g. via some NFS share) because it allows both server and agent instances to be provisioned at once, i.e. it allows us to merge the k3s feature without also having to do the (significant, follow-on) work to split out provisioning of compute nodes into a separate step after configuring the control node.

For non-CaaS clusters this is easy; we can simply template out a k3s_token into terraform vars when we generate secrets (with ansible). As the secrets live in the repo this is idempotent.

For CaaS this doesn't work; secrets are stored *in the control node's* persistent storage, so cannot be available to drive terraform templating; we have to run terraform to get inventory before we can retrieve secrets - chicken-and-egg!

# Solution
There is a `terraform_data` resource which can be used to put arbitrary values into terraform state via it's `input` property.

Normally (as for any resource), if this property changes, the resource state is updated as well. However if we set the lifecycle to ignore this property we can work around this and use it as a "write-once" remote store.

# Demo
- Review `main.tf`.
- The auto-loaded `terraform.tfvars` file defines a value for the variable `k3s_token`. For CaaS, this would be templated by ansible *randomly*, changing on every run.
- Run `tofu init`.
- Run `tofu apply`; note the value of this variable ends up in metadata.
- Manually change the value in the `terraform.tfvars` file, simulating another CaaS run.
- Run `tofu apply`; note the cluster metadata is not changed (and the terraform_data resource isn't changed either, see `terraform state show terraform_data.k3s_token`).

# Other notes
- This generalises to storage for other secrets too (although how to implement loading existing cluster secrets from a CaaS cluster has not been considered!)
- The *id* of a `terraform_data` resource could be used as the secret instead. However that doesn't provide any control really over the form of the secret.
