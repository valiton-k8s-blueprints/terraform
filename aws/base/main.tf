data "aws_availability_zones" "available" {}

resource "random_integer" "ip_part" {
  min = 0
  max = 255
}

locals {
  name   = var.base_name
  region = var.region

  cluster_version = var.kubernetes_version

  vpc_cidr = var.vpc_cidr != "" ? var.vpc_cidr : "10.${random_integer.ip_part.result}.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, var.azs_count)

  base_node_group = {
    base_eks_node = {
      instance_types = var.base_node_group_instance_types
      ami_type       = var.base_node_group_ami_type
      capacity_type  = var.base_node_group_capacity_type
      min_size       = var.base_node_group_min_size
      max_size       = var.base_node_group_max_size
      desired_size   = var.base_node_group_desired_size
      labels         = var.base_node_group_labels

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }


  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/valiton/k8s-terraform-blueprints"
  }
}
################################################################################
# EKS Cluster
################################################################################
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  cluster_enabled_log_types   = var.cluster_enabled_log_types
  create_cloudwatch_log_group = var.create_cloudwatch_log_group


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = merge(var.eks_managed_node_groups, local.base_node_group)

  # EKS Addons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }
  node_security_group_tags = { Name = format("%s-node-security-group", local.name) }
  tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.name
  })
}
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.55.0"

  role_name_prefix = "${module.eks.cluster_name}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}


################################################################################
# Supporting Resources
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway


  public_subnet_tags_per_az = {
    eu-central-1a = {
      Name                                  = "${local.name}-public-a",
      "kubernetes.io/role/elb"              = "1"
      "kubernetes.io/cluster/${local.name}" = "shared"
    },
    eu-central-1b = {
      Name                                  = "${local.name}-public-b",
      "kubernetes.io/role/elb"              = "1"
      "kubernetes.io/cluster/${local.name}" = "shared"
    },
    eu-central-1c = {
      Name                                  = "${local.name}-public-c",
      "kubernetes.io/role/elb"              = "1"
      "kubernetes.io/cluster/${local.name}" = "shared"
    }
  }

  private_subnet_tags_per_az = {
    eu-central-1a = {
      Name                              = "${local.name}-private-a",
      "kubernetes.io/role/internal-elb" = "1",
      # Tags subnets for Karpenter auto-discovery
      "karpenter.sh/discovery"              = local.name
      "kubernetes.io/cluster/${local.name}" = "shared"

    },
    eu-central-1b = {
      Name                              = "${local.name}-private-b",
      "kubernetes.io/role/internal-elb" = "1",
      # Tags subnets for Karpenter auto-discovery
      "karpenter.sh/discovery"              = local.name
      "kubernetes.io/cluster/${local.name}" = "shared"

    },
    eu-central-1c = {
      Name                              = "${local.name}-private-c",
      "kubernetes.io/role/internal-elb" = "1"
      # Tags subnets for Karpenter auto-discovery
      "karpenter.sh/discovery"              = local.name
      "kubernetes.io/cluster/${local.name}" = "shared"
    }
  }

  tags = local.tags
}
