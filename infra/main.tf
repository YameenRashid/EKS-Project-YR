module "vpc" {
  source   = "./modules/vpc"
  cluster_name = "YR-EKS-Cluster"
}

module "iam" {
  source   = "./modules/iam"
  cluster_name = "YR-EKS-Cluster"
}

module "eks" {
  source   = "./modules/eks"
  cluster_name = "YR-EKS-Cluster"
  cluster_role_arn = module.iam.eks_cluster_role_arn
  subnet_ids = module.vpc.private_subnet_ids
  node_role_arn = module.iam.eks_node_groups_role_arn
  cluster_security_group_id = module.security_groups.eks_control_plane_sg_id
  node_security_group_id = module.security_groups.eks_node_sg_id
  github_actions_role_arn = module.iam.github_actions_role_arn
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}