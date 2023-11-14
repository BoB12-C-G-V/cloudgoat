# Public EBS Snapshot

### Resource

- EBS * 1
- EBS SnapShot * 1
- EC2 * 2
- IAM * 1

### Goal

- 암호화 되지 않은 EBS 스냅샷에 대한 위험성 이해

### Summary

- player는 EBS 스냅샷을 찾고 암호화 되어있지 않음을 확인
- 자신이 연결 할 수 있는 EC2에 해당 스냅샷을 볼륨으로 연결
- 그 안에있는 비밀값을 확인한다.


### Introduction
해당 튜토리얼의 목표는 암호화 되지 않은 EBS 스냅샷의 위험성의 이해입니다.
물론 암호화 되지 않은 스냅샷이 발견되더라도 해당 스냅샷을 이용하여 데이터를 확인하는 것은 많은 권한을 필요로 하는 일 입니다.
다만 해당 튜토리얼에서는 Player에게 SSH키를 제공하여 다른 EC2에 접근할 수 있다는 상황을 가정합니다.

***


### 1. EC2인스턴스 ID확인
구축된 환경에서는 EC2 2개, EBS 1개, EBS Snapshot 1개 그리고 SSH키가 한개 주어집니다.
제공된 EC2의 인스턴스 ID를 식별하기 위해 다음과 같은 명령어를 실행합니다.
`aws ec2 describe-instances --profile block --filters "Name=instance-state-name,Values=running"`

EC2를 생성하게되면 Root Block Device라는 8GB용량의 EBS가 기본적으로 생성됩니다.
하지만 해당 상황에서는 스냅샷을 생성하기 위해 EBS를 추가로 생성해주었기 때문에 EBS가 총 2개 있는 인스턴스의 ID를 찾으면 됩니다.

[예시]
```
{
    "DeviceName": "/dev/xvda",
    "Ebs": {
        "AttachTime": "2023-11-14T12:02:54.000Z",
        "DeleteOnTermination": true,
        "Status": "attached",
        "VolumeId": "[Volume_ID 1]"
    }
},
{
    "DeviceName": "/dev/sdb",
    "Ebs": {
        "AttachTime": "2023-11-14T12:03:38.000Z",
        "DeleteOnTermination": false,
        "Status": "attached",
        "VolumeId": "[Volume_ID 2]"
    }
}
```

### 2. 스냅샷 확인

이후 위에서 찾은 볼륨의 EBS스냅샷이 존재하는지를 확인하기 위해 다음과 같은 명령어를 실행합니다.
`aws ec2 describe-snapshots --filters "Name=volume-id,Values=<Volume-ID>" --profile block`

스냅샷이 존재하는 볼륨ID를 정확히 입력하였다면 다음과 같은 결과가 반환됩니다.
```
{
    "Snapshots": [
        {
            "Description": "",
            "Encrypted": false,
            "OwnerId": "856460250113",
            "Progress": "100%",
            "SnapshotId": "<Snapshot_ID>",
            "StartTime": "2023-11-03T08:28:59.294000+00:00",
            "State": "completed",
            "VolumeId": "<Volume_ID>",
            "VolumeSize": 1,
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "Hello IAM?"
                }
            ],
            "StorageTier": "standard"
        }
    ]
}

```

반환된 결과에서 [Encrypted]값을 보면 False로 표시되어있습니다. 즉, 암호화가 되어있지 않았다는 말입니다.

### 3. 스냅샷으로 볼륨 생성
이제 스냅샷을 확인하였으니 해당 스냅샷으로 볼륨을 생성할 차례입니다.
다음 명령어를 통해서 EBS볼륨을 새롭게 생성해 주겠습니다.
`aws ec2 create-volume --snapshot-id <Snaptshot ID> --availability-zone us-east-1a --volume-type gp2 --size 1 --profile block`

결과
```
{
    "AvailabilityZone": "us-east-1a",
    "CreateTime": "2023-11-03T08:55:43+00:00",
    "Encrypted": false,
    "Size": 1,
    "SnapshotId": "<Snapshot_ID>",
    "State": "creating",
    "VolumeId": "<Volume_ID>",
    "Iops": 100,
    "Tags": [],
    "VolumeType": "gp2",
    "MultiAttachEnabled": false
}
```

### 5. 인스턴스 연결

볼륨을 생성하였으니 이제 인스턴스에 연결할 차례입니다.

EBS볼륨이 2개 존재하였던 EC2인스턴스 외에 다른 EC2인스턴스에 해당 볼륨을 연결합니다.

```aws ec2 attach-volume --volume-id <Volume_ID> --instance-id <연결가능한 인스턴스 ID> --device /dev/xvdf --profile block```

> dev/xvdf는 EC2에서 EBS볼륨을 연결할 수 있는 디렉토리 입니다.

> 연결(Attach)과 마운트(mount)는 다릅니다.

이후 주어진 SSH키를 이용하여 EC2 인스턴스에 접속합니다.

접속후 연결된 볼륨을 마운트포인트에 마운트 합니다.
```sudo mount /dev/xvdf /mnt/mydata```
> 마운트 포인트는 /mnt/mydata로 생성해 두었습니다


이제 해당 디렉토리로 들어가 데이터를 확인합니다.
```cd /mnt/mydata```