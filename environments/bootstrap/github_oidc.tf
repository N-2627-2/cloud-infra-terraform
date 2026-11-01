data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:N-2627-2/cloud-infra-terraform:environment:dev"]
    }
  }
}

resource "aws_iam_role" "github_actions_dev" {
  name                 = "gha-securechain-dev"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role.json
  max_session_duration = 3600
  description          = "GitHub Actions OIDC role for SecureChain dev Terraform deployments"
}

data "aws_iam_policy_document" "github_actions_dev" {
  statement {
    sid       = "ManageDevTerraformState"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.terraform_state.arn]
  }

  statement {
    sid       = "ReadWriteDevTerraformStateAndLock"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.terraform_state.arn}/dev/terraform.tfstate*"]
  }

  statement {
    sid    = "ManageDevResourcesInUsEast1"
    effect = "Allow"
    actions = [
      "cloudwatch:*", "ec2:*", "ecr:*", "ecs:*", "elasticloadbalancing:*",
      "logs:*", "rds:*", "sns:*"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }

  statement {
    sid    = "ManageSecureChainDevIamRoles"
    effect = "Allow"
    actions = [
      "iam:GetRole", "iam:GetRolePolicy", "iam:ListAttachedRolePolicies", "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies", "iam:CreateRole", "iam:DeleteRole", "iam:UpdateAssumeRolePolicy",
      "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:AttachRolePolicy", "iam:DetachRolePolicy",
      "iam:TagRole", "iam:UntagRole", "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/securechain-ecs-*",
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/securechain-vpn-*",
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/securechain-vpn-*"
    ]
  }

  statement {
    sid     = "PassSecureChainRolesToCompute"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/securechain-ecs-*",
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/securechain-vpn-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }

  statement {
    sid       = "ReadEcsExecutionPolicy"
    effect    = "Allow"
    actions   = ["iam:GetPolicy", "iam:GetPolicyVersion"]
    resources = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  }

  statement {
    sid       = "ManageDevDatabaseSecret"
    effect    = "Allow"
    actions   = ["secretsmanager:CreateSecret", "secretsmanager:DeleteSecret", "secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue", "secretsmanager:TagResource", "secretsmanager:UntagResource"]
    resources = ["arn:${data.aws_partition.current.partition}:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:securechain-db-credentials-dev-*"]
  }
}

resource "aws_iam_role_policy" "github_actions_dev" {
  name   = "securechain-dev-terraform"
  role   = aws_iam_role.github_actions_dev.id
  policy = data.aws_iam_policy_document.github_actions_dev.json
}

output "github_actions_dev_role_arn" {
  value = aws_iam_role.github_actions_dev.arn
}
