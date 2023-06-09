resource "aws_iam_role" "main" {
  name                = "${var.env_code}-iam_role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]

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


resource "aws_iam_instance_profile" "main" {
  name = "${var.env_code}-iam_profile"
  role = aws_iam_role.main.name
}
