output "external_dns_role_arn" {
  value = module.iam.external_dns_role_arn
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}