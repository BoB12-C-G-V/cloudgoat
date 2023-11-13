사전 작업
자신에게 할당된 정책의 권한 확인
aws iam get-policy-version --policy-arn <Policy-Arn> --version-id v1 --profile <Profile_Name_Having_Descrive_Permission>


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

    