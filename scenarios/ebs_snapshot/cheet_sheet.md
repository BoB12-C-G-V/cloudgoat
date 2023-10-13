# EC2-instance-id확인
aws ec2 describe-instances --profile block

instance-id : i-0aa5d949ec0f5808e

# ebs-volume-id 확인
aws ec2 describe-volumes --filters "Name=attachment.instance-id,Values=<Your_EC2_instance_ID>" --profile block

ebs-volume-id : vol-0c131c55ee4248b58

# ebs-snapshot-id확인
aws ec2 describe-snapshots --filters "Name=volume-id,Values=<Your_EBS_SnapShot_ID>" --profile block

ebs-snapshot-id : snap-08f7743c89c1ac358

# 보안그룹 아이디 확인


Security-groups_id : sg-0d0a82106753cc0d5

# 스냅샷으로 EBS볼륨 생성
aws ec2 create-volume --snapshot-id snap-07384b23dd0b47336 --availability-zone us-east-1a --volume-type gp2 --size 1

# 스냅샷으로 이미지 생성
aws ec2 register-image --name "testing" --region us-east-1 --description "AMI_from_snapshot_EBS" --block-device-mappings DeviceName="/dev/xvdf",Ebs={SnapshotId="snap-08f7743c89c1ac358"} --root-device-name "/dev/xvdf" --profile block
	




새로운 EC2인스턴스 생성
aws ec2 run-instances --image-id ami-04cb4ca688797756f --instance-type t2.micro --key-name bob_key_pair --security-group-ids sg-0004bacd45be58948 --subnet-id subnet-03f97c19f0675942a

새로운 EC2인스턴스에서 마운트할 디바이스 이름 확인
aws ec2 describe-instances --instance-ids <Your_EC2_Instance_ID> --query "Reservations[0].Instances[0].BlockDeviceMappings[0].DeviceName" --output text

마운트
aws ec2 attach-volume --volume-id <New_EBS_Volume_ID> --instance-id <Your_EC2_Instance_ID> --device <Device_Name>
