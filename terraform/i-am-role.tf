module "load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44"

  role_name = "eks-lb-controller-${var.cluster_name}"

  # ADD THIS: These are the permissions needed to talk to AWS Load Balancer API
  role_policy_arns = {
    policy = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy" 
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}