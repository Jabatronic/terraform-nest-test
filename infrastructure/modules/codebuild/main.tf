resource "aws_codebuild_project" "app" {
  name         = "${var.environment}-build"
  description  = "Build and push NestJS application to ECR"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true # Required for Docker

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repository_name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo_url
    git_clone_depth = 1
    buildspec       = "../../../buildspec.yml"
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.private_subnet_ids
    security_group_ids = [aws_security_group.codebuild.id]
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.environment}-build"
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Security Group for CodeBuild
resource "aws_security_group" "codebuild" {
  name        = "${var.environment}-codebuild-sg"
  description = "Security group for CodeBuild"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.environment}-build"
  retention_in_days = 30

  tags = {
    Environment = var.environment
  }
}
