#Private Repository in ECR
resource "aws_ecr_repository" "devops-hello-python" {
  name = var.app_name
  tags = {
    Application = var.app_name
  }
}
