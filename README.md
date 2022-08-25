# terraform-cicd-project

Deploy Two-Tier Architecture Using Terraform Cloud

1. Create a highly available two-tier AWS architecture containing the following:
-3 Public Subnets
-3 Private Subnets
-Auto Scaling Group for Bastion Host (private subnets)
-Auto Scaling Group for Web Server (in private subnets)
-Internet-facing Application Load Balancer targeting Web Server Auto Scaling Group

2. Deploy this using Terraform Cloud as a CI/CD tool to check your build.

3. Use module blocks for ease of use and re-usability.

NOTE: all code should be in module blocks, not resource blocks

Deploy this using Terraform Cloud as a CI/CD tool to check your build