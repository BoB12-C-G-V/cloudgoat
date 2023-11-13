

### Resource

- S3 * 2(bucketA - private , bucketB - Public)
- IAM * 2

### Gole

- Public S3와 접근제어에 대해서 설명



제공된 파일을 실행하시면 우선 playerA와 playerB이렇게 2개의 IAM 키페어가 제공됩니다.
해당 IAM 프로필을 사용하여 진행하겠습니다.


먼저 ```aws s3 ls --profile playerA(or playerB)``` 명령어를 통해서 현재 구축된 환경에 존재하는 S3버킷을 확인합니다.

확인 결과 총 2개의 S3 Bucket이 존재합니다. 해당 버킷에 파일을 업로드 해보도록 하겠습니다.

```aws s3 cp test.txt s3://[Bucket Name]/yourtest --profile playerA```
```aws s3 cp test.txt s3://[Bucket Name]/yourtest --profile playerB```

bobthtest1버킷에는 playerA만 업로드가 가능한 것을 확인할 수 있습니다.

나머지 버킷에도 파일을 업로드 해보도록 하겠습니다.
```aws s3 cp test.txt s3://[Bucket Name2]/yourtest --profile playerA```
```aws s3 cp test.txt s3://[Bucket Name2]/yourtest --profile playerB```

확인결과 두번째 버킷 bobthtest2는 두 프로필 모두가 파일 업로드&다운로드가 불가능한 버킷입니다.

이렇듯 S3버킷에는 정책을 통해서 특정 버킷에 접근할 수 있는 사용자를 제한할 수 있습니다.
허락받은 사람만 S3객체에 접근이 가능해지는 것 입니다.

과거에는 정책으로 제한 하는 것이 아닌 ACL(Access Control List)를 통하여 접근제어를 하였지만 현재는 권장되지 않는 방식입니다. 
aws에서 제공하는 s3보안 모범사례에서도 ACL은 비활성화를 권장하고 있습니다.
https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/security-best-practices.html




그렇다면 두번째 버킷은 왜 제공한 것 일까요.

두번째 버킷에게 할당된 정책을 보도록 하겠습니다.
```aws s3api get-bucket-policy --bucket YOUR_BUCKET_NAME```

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::bobthtest2/*",
            "arn:aws:s3:::bobthtest2"
        }
    ]
}
```
두번째 버킷에 할당된 정책을 보면

모든 사용자에게(Principal : "*") 두번째 버킷의 아래에 존재하는 모든 파일("Resource": "arn:aws:s3:::bobthtest2/*") 접근을(s3:GetObject) 허용한다 (Effect : Allow)로 해석이 가능합니다.

즉, Public Bucket이라는 뜻 입니다.

이제 해당 s3에 접근을 해보겠습니다.
https://bobthtest1.s3.ap-northeast-2.amazonaws.com/test.txt 
위 url로 접속을 하시면 test.txt의 내용이 보일 것 입니다.


이렇게 Public Bucket으로 설정하게 되면 전세계의 모든 사람이 해당 버킷에 있는 객체를 볼 수 있습니다.

당장 grayhatwarfare 사이트만 들어가도 public bucket들을 조회해주는 서비스를 제공하고 있습니다.