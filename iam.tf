resource "aws_iam_user" "github_actions" {
  name = "ecr-github_actions"
  path = "/services/"
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "aws_iam_user_policy" "githubs_action_policy" {
  name = "ecs-ecr_PublishingPolicy"
  user = aws_iam_user.github_actions.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:DeregisterTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:UpdateService"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
