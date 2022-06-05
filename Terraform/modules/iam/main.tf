resource "aws_iam_role" "iam_jboss_ec2" {
  name = "iam_role_jboss_ec2"

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

resource "aws_iam_instance_profile" "iam_profile_ec2_jboss" {
  name = "iam_profile_ec2_jboss"
  role = "${aws_iam_role.iam_jboss_ec2.name}"
}

resource "aws_iam_role_policy" "iam_policy_jboss_ec2" {
  name = "iam_policy_jboss_ec2"
  role = "${aws_iam_role.iam_jboss_ec2.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}