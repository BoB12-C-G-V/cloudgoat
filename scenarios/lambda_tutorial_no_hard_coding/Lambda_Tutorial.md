# [Scenario] Lambda Tutorial

사람: 서현 박
Status: Not started

## 리소스

- Lambda * 1
- S3 * 1
- IAM * 1

## 목표

- 람다 소스코드 노출 가능성의 이해
- 람다 코드 작성시 주의사항 숙지

## 개요

튜토리얼 파일을 실행하면 S3에 파일이 업로드 되는 것을 트리거로 하여 업로드한 객체에 파일 경로와 파일의 크기를 태그로 지정하는 간단한 람다 코드가 동작하고 있습니다. list-functions와 get-function을 사용하여 람다 사용시 주의 사항을 학습하는 것이 목표입니다.

![Untitled.png](terraform%2Flambda%2FUntitled.png)
### 

---

### 1. 권한 확인

현재 player가 사용하고 있는 IAM에게 어떠한 권한이 있는지 확인하는 단계입니다

할당된 권한을 알기 위해서는 IAM에게 할당된 정책에 대한 정보가 필요합니다

```json
aws iam list-attached-user-policies --user-name [Profile Name] --profile player
```

[결과]

```json
{
    "AttachedPolicies": [
        {
            "PolicyName": "minimum_policy",
            "PolicyArn": [policy_arn]
        }
    ]
}
```

할당된 정책에 대한 정보를 얻었으니 해당 정책에 부여된 권한을 조회하겠습니다.

```json
aws iam get-policy-version --policy-arn <Policy ARN> --version-id <Version ID>
```

[결과]

```json
{
    "PolicyVersion": {
        "Document": {
            "Statement": [
                {
                    "Action": [
                        "lambda:List*",
                        "lambda:GetFunction",
                        "iam:List*",
                        "iam:Get*"
                    ],
                    "Effect": "Allow",
                    "Resource": "*"
                }
            ],
            "Version": "2012-10-17"
        },
        "VersionId": "v1",
        "IsDefaultVersion": true,
        "CreateDate": "2023-11-14T17:17:21Z"
    }
}
```

IAM에게는 다음과 같은 작업이 가능한 권한이 할당되어 있습니다.

1. `lambda:List*` : 람다함수 List와 관련된 모든 권한
2. `lambda:GetFunction` : get-function명령을 실행할 수 있는 권한
3. `iam:List*` , `iam:Get*`  : 해당 권한을 통해 `list-attached-user-policies`, `get-policy-version` 명령을 실행할 수 있었으며 결과적으로 해당 권한이 이 시나리오의 시발점 이라고 생각할 수 있습니다.

### 2. 람다 함수 확인

현재 계정내에 존재하는 람다 함수를 조회하기 위해서 다음 명령어를 사용합니다.

```json
aws lambda list-functions --profile player
```

[결과]

```json
{
    "Functions": [
        {
            "FunctionName": "tagging",
            "FunctionArn": "[function arn]",
            "Runtime": "python3.11",
            "Role": "[lambda_role_arn]",
            "Handler": "tagging.lambda_handler",
            "CodeSize": 941,
            "Description": "",
            "Timeout": 3,
            "MemorySize": 128,
            "LastModified": "2023-11-14T17:17:40.069+0000",
            "CodeSha256": "[CodeHash]",
            "Version": "$LATEST",
            "Environment": {
                "Variables": {
                    "SECRET_KEY": "[Secret_key]",
                    "KEY_ID": "[Access_Key]"
                }
            },
            "TracingConfig": {
                "Mode": "PassThrough"
            },
            "RevisionId": "364a52cd-54d6-41f3-8869-13a42c7609a9",
            "PackageType": "Zip",
            "Architectures": [
                "x86_64"
            ]
        }
    ]
}
```

결과를 보면 다양한 정보를 얻을 수 있습니다

1. 람다 함수의 이름
2. 람다 함수의 ARN
3. 람다함수가 사용하는 환경변수
4. 등등..

특히 3번 환경변수를 보면

```json
"Environment": {
                "Variables": {
                    "SECRET_KEY": "[Secret_key]",
                    "KEY_ID": "[Access_Key]"
                }
            },
```

실제로 람다 함수에서 서비스에 접근하기 위해 자격증명을 환경 변수에 저장하여 사용하는 경우가 종종 있습니다.

이는 보안사고로 이루어 질 수 있으며 자격증명을 직접적으로 사용하는 것이 아닌 람다 함수에게 적절한 권한을 부여하는 역할을 할당하여 사용해야 하는것이 권장되는 방법입니다.

### 3. 람다 함수 소스코드 획득

`list-functions` 명령어는 람다함수에 대한 다양한 정보를 제공하지만 소스코드를 직접 확인할 수는 없습니다.

`get-function`명령어를 사용하면 해당 람다함수의 소스코드를 다운로드 할 수 있는 링크가 주어집니다.

```json
aws lambda get-function --function-name [Function_Name] --profile player
```

```json
{
    "Configuration": {
        "FunctionName": "tagging",
        "FunctionArn": "[function arn]",
        "Runtime": "python3.11",
        "Role": "[lambda_role_arn]",
        "Handler": "tagging.lambda_handler",
        "CodeSize": 941,
        "Description": "",
        "Timeout": 3,
        "MemorySize": 128,
        "LastModified": "2023-11-14T17:17:40.069+0000",
        "CodeSha256": "[CodeHash]",
        "Version": "$LATEST",
        "Environment": {
            "Variables": {
                "SECRET_KEY": "[Secret_key]",
                "KEY_ID": "[Access_key]"
            }
        },
        "TracingConfig": {
            "Mode": "PassThrough"
        },
        "RevisionId": "364a52cd-54d6-41f3-8869-13a42c7609a9",
        "State": "Active",
        "LastUpdateStatus": "Successful",
        "PackageType": "Zip",
        "Architectures": [
            "x86_64"
        ]
    },
    "Code": {
        "RepositoryType": "S3",
        "Location": [Source Code Download Link]
    }
}
```

이렇듯 get-function명령어 까지 실행할 수 있는 권한이 존재할 경우에는 소스코드가 유출되어 공격벡터가 노출되는 상황이 발생할 수 있습니다.