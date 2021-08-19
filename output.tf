
# output "public_subnets" {
#   value = data.aws_subnet.public
# }

#No permissions to create a iam user
# output "github_actions_access_key" {
#   value       = aws_iam_access_key.github_actions.id
#   description = "Variable AWS_ACCESS_KEY to add  in github actions secrets"
# }

# output "github_actions_secret_key" {
#   value       = aws_iam_access_key.github_actions.secret
#   description = "Variable AWS_SECRET_ACCESS_KEY to add in github actions secrets "
#   sensitive   = true
# }
output "ecr_url" {
  value       = aws_ecr_repository.devops-hello-python.repository_url
  description = "ECR Repository URL to configure in github actions"
}

output "ecr_name" {
  value       = aws_ecr_repository.devops-hello-python.name
  description = "ECR Repository URL to configure in github actions"
}


output "app_url" {
  value       = aws_lb.service.dns_name
  description = "The public ALB DNS"
}