data "aws_ecr_image" "frontend" {
  repository_name = "${var.app_name}-${var.environment}-frontend"
  most_recent     = true
}

data "aws_ecr_image" "backend" {
  repository_name = "${var.app_name}-${var.environment}-backend"
  most_recent     = true
}
