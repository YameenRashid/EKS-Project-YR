resource "aws_eks_cluster" "yr_eks_cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.cluster_security_group_id]
  }

  tags =  {
    Name = "yr-eks-cluster"
  }
}

resource "aws_eks_node_group" "yr_node_group" {
  cluster_name    = aws_eks_cluster.yr_eks_cluster.name
  node_group_name = "yr-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

resource "aws_eks_access_entry" "access_entry" {
  cluster_name      = aws_eks_cluster.yr_eks_cluster.name
  principal_arn     = "arn:aws:iam::666109694156:user/Yameen"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "access_policy_association" {
  cluster_name  = aws_eks_cluster.yr_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::666109694156:user/Yameen"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.yr_eks_cluster.name
  principal_arn = var.github_actions_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = aws_eks_cluster.yr_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.github_actions_role_arn

  access_scope {
    type = "cluster"
  }
}