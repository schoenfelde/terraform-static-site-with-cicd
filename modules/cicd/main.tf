resource "aws_iam_role" "codebuild_assume_role" {
  name = "${var.pipeline_name}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.pipeline_name}-codebuild-policy"
  role = aws_iam_role.codebuild_assume_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
       "s3:PutObject",
       "s3:DeleteObject",
       "s3:GetObject",
       "s3:GetObjectVersion",
       "s3:GetBucketVersioning",
       "cloudfront:CreateInvalidation"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Resource": [
        "${aws_codebuild_project.build_project.id}"
      ],
      "Action": [
        "codebuild:*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "build_project" {
  name          = "cb-${var.pipeline_name}"
  description   = "The CodeBuild project for ${var.pipeline_name}"
  service_role  = aws_iam_role.codebuild_assume_role.arn
  build_timeout = "60"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:10.14.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET"
      value = "s3://${var.website_name}.com"
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION"
      value = var.cloudfront_distribution_id
    }

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}


resource "aws_s3_bucket" "s3_codepipeline" {
    bucket = "s3-cp-${var.pipeline_name}"
    acl = "private"
}

resource "aws_iam_role" "codepipeline_role" {
    name = "${var.pipeline_name}-codepipeline-role"
      assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
    name = "codepipeline-policy"
    role = aws_iam_role.codepipeline_role.id

      policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.s3_codepipeline.arn}",
        "${aws_s3_bucket.s3_codepipeline.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
    name = "cp-${var.pipeline_name}"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
        location = aws_s3_bucket.s3_codepipeline.bucket
        type = "S3"

    }

    stage {
        name = "Source"
        
        action {
            name = "Source"
            category = "Source"
            owner = "ThirdParty"
            provider = "GitHub"
            version = "1"
            output_artifacts = ["source_output"]
            
            configuration = {
              OAuthToken = var.github_oauth_token
              Owner = var.github_owner_name
              Repo = var.github_repo_name
              Branch = var.github_branch_name
              PollForSourceChanges = "true"
            }
        }
    }

    stage {
        name = "Build"
        
        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            input_artifacts = ["source_output"]
            output_artifacts = ["build_output"]
            version = "1"
            
            configuration = {
                ProjectName = aws_codebuild_project.build_project.name
            }
        }
    }
}
