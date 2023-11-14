### Resource

- IAM * 1

### Goal

- 최소 권한 원칙의 설명
- 위험 권한의 이해

### Summary

- player는 List* , GetPolicyVersion , CreatePolicyVersion의 권한을 가지고 있음
- CreatePolicyVersion 권한을 통해 자신에게 정책을 할당하여 admin권한으로 상승하는 상황을 연출



### 실행 명령어
`./cloudgoat.py create iam_tutorial_CreatePolicyVersion`

이번 시나리오의 학습목표는 IAM 최소권한 원칙의 이해와 위험한 권한의 이해입니다.
구축된 환경에서는 단 하나의 IAM만 주어집니다.

우선 IAM에게 할당된 권한부터 확인해야 할 것 입니다.
```aws iam list-attached-user-policies --user-name [Profile Name] --profile player```
해당 명령어를 통해 특정 IAM에게 할당된 정책을 확인할 수 있습니다.

확인결과 현재 진행중인 IAM에 ```CreatePolicyVersion```이라는 권한이 존재함을 인지할 수 있었습니다.

IAM에게 할당된 정책은 수정이 가능하며 마치 Git처럼 버전관리가 가능합니다. ```CreatePolicyVersion``` 권한을 가지고 있다면 현재 자신이 가지고있는 정책을 수정할 수 있습니다.

다음 명령어를 통해 진행해 보겠습니다.

```aws iam create-policy-version --policy-arn <target_policy_arn> \ --policy-document file:///path/to/administrator/policy.json --set-as-default```

다음과 같은 명령어를 통해 새로운 정책 버전을 생성하고 기본 정책 버전으로 설정할 수 있습니다.

그런데 위 명령어에서는 policy arn을 입력해야하는데 ```list-attached-user-policies```명령어로는 알 수가 없습니다.
따라서 다음과 같은 명령어가 선행되어야 합니다.
```aws iam list-policy-versions --policy-arn <arn>
aws iam get-policy-version --policy-arn <arn> --version-id <VERSION_X>``




