data "aws_iam_policy_document" "assume_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

# S3 Buckets Access
data "aws_iam_policy_document" "buckets_access" {
  version = "2012-10-17"
  statement {
    sid       = ""
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [
      "${aws_s3_bucket.secrets.arn}/*",
      aws_s3_bucket.secrets.arn,
      "${aws_s3_bucket.uploads.arn}/*",
      aws_s3_bucket.uploads.arn
    ]
  }
}

data "aws_iam_policy_document" "ecr_access" {
  version = "2012-10-17"
  statement {
    sid       = ""
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ses_access" {
  version = "2012-10-17"
  statement {
    sid       = ""
    effect    = "Allow"
    actions   = ["ses:*"]
    resources = ["*"]
  }
}

# Policies (created from documents)

resource "aws_iam_policy" "buckets_access" {
  name   = "${var.environment}_bucketsAccess"
  policy = data.aws_iam_policy_document.buckets_access.json
}

resource "aws_iam_policy" "ecr_access" {
  name   = "${var.environment}_ecrAccess"
  policy = data.aws_iam_policy_document.ecr_access.json
}

resource "aws_iam_policy" "ses_access" {
  name   = "${var.environment}_sesAccess"
  policy = data.aws_iam_policy_document.ses_access.json
}



# Roles & Attachments

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.environment}_ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_buckets_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.buckets_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_ses_access" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ses_access.arn
}




resource "aws_iam_role" "ec2_role" {
  name               = "${var.environment}_ec2Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.environment}_ec2Profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_buckets_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.buckets_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ecr_access.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ses_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ses_access.arn
}
