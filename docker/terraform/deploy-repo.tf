resource "aws_ecr_repository" "nginx-web-app" {
  name                 = "nginx-web-app"
  tags = {
    key = "Name"
    value = "web-app"
    propagate_at_launch = true
  }
}

resource "aws_ecr_repository" "php-app" {
  name                 = "php-app"
  tags = {
    key = "Name"
    value = "web-app"
    propagate_at_launch = true
  }
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "php-app_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "php-app_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecr_policy" {
  name = "ecr_policy"
  role = aws_iam_role.role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:BatchGetImage"
            ],
            "Resource": [
                "*"
            ]
      }
    ]
  }
  EOF
}