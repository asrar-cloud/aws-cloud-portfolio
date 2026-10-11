# AWS cloud learning portfolio

I am Asrar, an aspiring AWS cloud engineer. These are reproducible beginner labs for EC2, networking, Terraform, and monitoring. **The configurations are project code, not evidence of an AWS deployment.** I will add deployment observations only after running the labs myself.

| Project | What it demonstrates | Status |
| --- | --- | --- |
| [01 · EC2 Linux web server](01-ec2-linux-web-server/README.md) | Amazon Linux, Nginx bootstrap, security group, encrypted disk, IMDSv2 | Code prepared; AWS deployment unverified |
| [02 · Terraform VPC + EC2](02-terraform-vpc-ec2/README.md) | VPC, public subnet, internet gateway, route table, EC2 | Code prepared; AWS deployment unverified |
| [03 · CloudWatch troubleshooting](03-cloudwatch-troubleshooting/README.md) | Dashboard, CPU alarm, guided HTTP fault diagnosis | Code prepared; AWS deployment unverified |

## Local container foundation

| Project | What it demonstrates | Status |
| --- | --- | --- |
| [04 · Docker container fundamentals](04-docker-container-fundamentals/README.md) | Dockerfile → image → container, localhost port publishing, non-root execution, health checks, logs, and cleanup | Built and verified locally; no AWS deployment |

This Docker lab runs on a local computer. It is a foundation for later container services; it is not presented as an AWS deployment.

## Safety and cost

These labs can incur EC2, EBS, public IPv4, CloudWatch, and data transfer charges, even with a free-tier-eligible account. Check [AWS Pricing](https://aws.amazon.com/pricing/) for your region and account before applying. Set an AWS Budget and keep a cleanup window. No resources have been deployed as part of this repository. Terraform state can contain sensitive data: keep it local and out of Git. Use IAM Identity Center or short-lived credentials with only the permissions needed for the resources in each lab; avoid root credentials and static keys.

## Local checks

Run `terraform fmt -check -recursive` and `terraform init -backend=false` followed by `terraform validate` in each project directory. Validation checks syntax and provider schemas; it does not prove an AWS deployment works. See each project README for live verification and cleanup.
