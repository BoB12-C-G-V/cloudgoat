#Required: Always output the AWS Account ID
output "cloudgoat_output_aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Scenario starts at ssrf web url.
output "ssrf_web_url" {
  # During scenario destroy, there is no string left in the list, resulting in an error.
  # So make value = "", when list's length 0.
  value = length(data.aws_instances.asg_instance.public_ips) > 0 ? "Scenario start at : http://${data.aws_instances.asg_instance.public_ips[0]}" : ""
}

data "aws_caller_identity" "current" {}

# Search based on tag to get the IP of EC2 that is automatically generated by ASG.
data "aws_instances" "asg_instance" {
  depends_on = [time_sleep.wait_for_instance]

  instance_tags = {
    Name = "cg-ec2-instance-${var.cgid}"
  }
}

# Wait a little for ec2 be created in ASG.
resource "time_sleep" "wait_for_instance" {
  depends_on = [aws_autoscaling_group.asg]
  create_duration = "30s"
}