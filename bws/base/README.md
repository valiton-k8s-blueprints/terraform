# Terraform BWS Base Module

## Overview
This Terraform module sets up foundational BWS infrastructure, providing a base for deploying workloads on BWS. It follows best practices to ensure security, scalability, and maintainability.

## Features
- Creates network infrastructure
- Creates a Kubernets cluster with Talos

## Usage
To use this module, include the following in your Terraform configuration:

```hcl
module "base" {
  source = "git::git@github.com:valiton-k8s-blueprints/terraform.git/bws-talos/base?ref=main"
  
  base_name = "my_project"
  
  # Additional configuration...
}
```

## Before you start
This setup uses [Talos Linux](https://www.talos.dev/) to deploy and run Kubernetes. To manage Talos you have to install talosctl 
on the machine that runs the setup. Get the version for your platform with Homebrew or download it from https://github.com/siderolabs/talos/releases.

You also need a BWS project that is available via UCS. Log into BWS and create application credentials with roles "reader", "member" and "load-balancer_member".
Secondly create a floating ip address that will be used as the endpoint to access Talos and Kubernetes.

Setup your terraform configuration (see examples) and create Talos secrets with the command
 
```shell
talosctl gen secrets
```

Setup the terraform variables for 

```terraform
os_application_credential_id     = "<your application credential id>"
os_application_credential_secret = "<your application credential secret>"
kube_api_external_ip             = "<your floating ip>"
```

Plan and apply.

Once the terraform run ends successful, get your talosconfig and kubeconfig. Store the generated secrets.yaml in a save place
since it is your key to the cluster in case you loose your talosconfig.

You should also retrieve and store in a save place the talos configuration for controlplanes and workers if you want to scale up
the cluster

```shell
terraform output -raw controlplane_machine_configuration > controlplane.yaml
terraform output -raw worker_machine_configuration > worker.yaml
```

## Requirements

## Best Practices
- Use **remote state storage** (e.g., S3 + DynamoDB) to manage state files.
- Follow the **principle of least privilege** 

## Contributing
Feel free to submit **issues and pull requests** to improve this module.

## License
This module is licensed under the **MIT License**. 
