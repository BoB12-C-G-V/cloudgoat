https://docs.aws.amazon.com/codeguru/detector-library/python/hardcoded-credentials/


## Introduction
AWS Lambda는 이벤트 기반의 서버리스 컴퓨팅 서비스의 일종으로
AWS에서 가장 많이 사용되는 서비스중 하나입니다.
로그 분석, 데이터 처리, 이메일 전송 및 푸시알림 등등 각종 서비스에 다양하게 활용되고 있는 서비스입니다.
이번 튜토리얼에서는 Lambda를 사용하면서 조심해야할 부분중 하나인 하드 코딩에 대한 시나리오 입니다.

### 시작
튜토리얼 파일을 실행하면 S3에 파일이 업로드되는것을 트리거로 하여 업로드한 객체에 파일 경로와 파일의 크기를 태그로 지정하는 간단한 람다코드가 동작하고 있습니다.


### 권한 확인
현재 player가 사용하고 있는 IAM에게 어떠한 권한이 있는지 확인하는 단계입니다.

.
.
.


### 람다 함수 확인
현재 계정내에 존재하는 람다 함수를 조회하기 위해서 다음 명령어를 사용합니다.
```aws lambda list-functions --profile player```
그러면 Lambda함수의 이름과 함께 여러가지 정보들이 나오는데 여기서 필요한 것은 Lambda의 이름입니다.

### 람다 함수 소스코드 획득
get-function명령어를 사용하여 해당 람다함수의 소스코드를 다운로드 할 수 있는 링크가 주어집니다.
해당 링크에 접속하여 소스코드를 열고 하드코딩된 key를 획득하세요!