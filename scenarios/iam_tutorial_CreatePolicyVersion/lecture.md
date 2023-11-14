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

![img_1.png](img_1.png)
할당된 정책의 이름과 Arn(Amazon Resource Name)이 보입니다. 다만 권한까지는 얻지 못했습니다. 

다음과 같은 명령어를 사용하여 정책에 할당된 권한까지 확인을 해주어야 합니다.
```aws iam get-policy-version --policy-arn <Policy ARN> --version-id <Version ID>```

![img_2.png](img_2.png)

확인결과 해당 정책에는 총 3가지의 정책이 부여되었습니다.
1. `iam:List*`
2. `iam:GetPolicyVersion`
3. `CreatePolicyVersion`

이중에서도 주목해야 할 것은 3번째의 `CreatePolicyVersion`입니다.

IAM에게 할당된 정책은 수정이 가능하며 마치 Git처럼 버전관리가 가능합니다. `CreatePolicyVersion` 권한을 가지고 있다면 현재 자신이 가지고있는 정책을 수정할 수 있습니다.

다음 명령어를 통해 진행해 보겠습니다.

`aws iam create-policy-version \
  --policy-arn <Policy ARN> \
  --policy-document file://./scenairo/iam_tutorial_CreatePolicyVersion/policy.json \
  --set-as-default
`

다음과 같은 명령어를 통해 새로운 정책 버전을 생성하고 기본 정책 버전으로 설정할 수 있으며
, 마지막에 `--set-as-default`옵션을 지정해주어 생성한 권한을 바로 적용해 주었습니다.
![img_3.png](img_3.png)

이후 정말로 설정되었는지 보겠습니다.

위 사진에서 정책의 버전이 v3라고 되어있으니 v3버전의 정책을 확인해보도록 하겠습니다.

```aws iam get-policy-version --policy-arn <Policy ARN> --version-id v3```

![img_4.png](img_4.png)

Admin권한으로 잘 수정된것을 확인할 수 있습니다.

