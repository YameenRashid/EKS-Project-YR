output "eks_cluster_role_arn" {
   value = aws_iam_role.eks_cluster_role.arn
 }

output "eks_node_groups_role_arn" {
   value = aws_iam_role.eks_node_groups.arn
 }

 output "external_dns_role_arn" {
  value = aws_iam_role.external_dns.arn
}