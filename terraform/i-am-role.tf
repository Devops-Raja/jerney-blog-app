module "load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 5.44"

  # Use 'role_name' if 'name' failed, or vice versa depending on exact submodule version
  # Most current versions of this submodule use 'role_name'
  role_name = "eks-lb-controller-${var.cluster_name}"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
  }
}