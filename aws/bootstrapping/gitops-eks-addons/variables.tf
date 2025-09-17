
variable "environment" {
  default     = "development"
  type        = string
  description = "Infrastructure environment name (e.g. development, staging, production)."
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
variable "vpc_id" {
  description = "Base module dependency: ID of the VPC where the cluster security group will be provisioned"
  type        = string
}
variable "eks_cluster_name" {
  description = "Base module dependency: Name of the EKS cluster"
  type        = string
}
variable "eks_cluster_endpoint" {
  description = "Base module dependency: Endpoint for your Kubernetes API server"
  type        = string
}
variable "eks_cluster_version" {
  description = "Base module dependency: Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.32`) created from the base module"
  type        = string
}
variable "eks_oidc_provider_arn" {
  description = "Base module dependency: The ARN of the cluster OIDC Provider created from the base module"
  type        = string
}
variable "eks_managed_node_groups" {
  description = "Base module dependency: Map of attribute maps for all EKS managed node groups created from the base module."
  type        = any
}


variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_aws_ebs_csi_resources        = true
    enable_metrics_server               = true
    enable_aws_efs_csi_driver           = true
    enable_aws_load_balancer_controller = true
    enable_external_secrets             = true
    enable_external_dns                 = true
    enable_karpenter                    = true
    enable_kube_prometheus_stack        = true
    enable_cert_manager                 = false
    enable_cert_manager_issuers         = false
    enable_ingress_nginx                = false
  }

}
# Applications Git
variable "gitops_applications_repo_url" {
  description = "Url of Git repository for applications"
  type        = string
  default     = "https://github.com/valiton-k8s-blueprints/argocd"
}

variable "gitops_applications_repo_path" {
  description = "Path in the Git repository for applications and values.yaml"
  type        = string
  default     = "aws"
}

variable "gitops_applications_repo_revision" {
  description = "Git repository revision/branch/ref for applications"
  type        = string
  default     = "main"
}

variable "gitops_argocd_chart_version" {
  description = "Initial ArgoCD helm chart version to be deployed via gitOps Bridge"
  type        = string
  default     = "8.0.17"
}
variable "metadata_annotations" {
  description = <<EOT
This variable can be used to place additional meta information in the ArgoCD in-cluster secret. This information is then also available in the ApplicationSets via metadata.annotation. E.g.

metadata_annotations = {
  ssm_parameter_db_conection = "/MYAPP/DB_CONNECTION_STRING" 
  ssm_parameter_api_key = "/MYAPP/API_KEY"
}
EOT
  type        = any
  default     = null
}

variable "metadata_labels" {
  description = <<EOT
This variable can be used to place additional label information in the ArgoCD in-cluster secret. This information is then also available in the ApplicationSets via metadata.labels. E.g.

metadata_labels = {
  enable_my_app = "true"
}
EOT
  type        = any
  default     = null
}

# external dns
variable "external_dns_domain_filters" {
  description = "Limit possible target zones by domain suffixes."
  type        = string
  default     = "['example.org']"
}

variable "route53_zone" {
  description = "Limit possible route53 zones."
  default     = "*"
  type        = string
}

# karpenter
#
# aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2023/arm64/standard/recommended/image_id" --region eu-central-1 --query "Parameter.Value" --output text
variable "eks_image_arm64" {
  description = "Karpenter: Recommended Amazon Linux AMI ID for AL2023 ARM instances."
  type        = string
  default     = "ami-03346acdd644443a9"
}

# aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2023/x86_64/standard/recommended/image_id" --region eu-central-1 --query "Parameter.Value" --output text
variable "eks_image_x86_64" {
  description = "Karpenter: Recommended Amazon Linux AMI ID for AL2023 x86 based instances."
  type        = string
  default     = "ami-04f94cfef8368f0e4"
}

# kube-prometheus-stack
variable "kube_prometheus_stack" {
  description = "Kube prometheus stack add-on configuration values"
  type        = any
  default     = {}
}
