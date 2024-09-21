
# Previous
- If the `input` property of a `terraform_data` resource is changed, then it is changed in
  state on apply (as expected) so that can't be used to store secrets. 
- However the ID obviously doesn't change, so maybe we could use that??

# Current
- Use the *id* of a `terraform_data` resource as the k3s key.