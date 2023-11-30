# Scenario: rce_privesc

**Size:** Medium

**Difficulty:** Easy

**Command:** `$ ./cloudgoat.py create rce_privesc`

## Scenario Resources

* 1 EC2
* 1 S3
* 2 IAM Users

## Scenario Start(s)

1. IAM User "cg-startuser"
2. IAM User "cg-scgmod"

## Scenario Goal(s)
SSM parameter store에 접근하여 플래그를 얻기.

## Summary
공격자는 첫 진입점이 ec2, s3로 나누어집니다. ec2에는 개발자가 서비스 준비 중인 웹 서버가 돌아가고 있습니다. 개발자는 개발 및 테스트 과정에서 실수로 s3에 방화벽 관리자의 Key를 저장하였습니다. 먼저, 공격자는 ec2에서 동작 중인 웹 페이지에 접근합니다. 해당 웹 페이지는 설정된 보안그룹 때문에 접속이 불가능하다는 것을 알게됩니다. 그래서 공격자는 s3에 접근하여 Key를 탈취한 후, 이 권한을 이용하여 ec2의 보안그룹 규칙을 수정합니다. 다시 웹 페이지에 접속하여 존재하는 취약점을 찾은 후, AWS SSM 서비스 접근권한을 가진 역할을 얻어 secret-string를 얻는 시나리오입니다.

## Exploitation Route(s)

![Scenario Route(s)](./rce_privesc.png)

## Route Walkthrough - IAM User “cg-startuser”

1. 일반 사용자로 시작. ec2로 돌아가는 웹 어플리케이션과 s3가 존재함. 
2. 사용자는 찾은 주소로 접속을 하지만 접속이 되지 않음.
3. security group(방화벽)에 의해 네트워크 접근이 막힌 것을 알 수있음.
4.  s3에서 찾은ec2 방화벽 관리자의 AccessKey와 SecretKey를 얻은 후, aws cli를 통해 외부에서 접근할 수 있는 규칙을 추가해준다.
5. 공격자는 웹 페이지에 다시 접속한다. → 방화벽규칙이 적용되고 공격자는 접속가능
6. RCE 취약점이 터지는 것을 알았고, 메타데이터에 접근하여 SSM 접근권한이 있는 자격증명을 얻어 “FLAG” 파라미터의 값인 secret-string을 얻는다.

A cheat sheet for this route is available [here](./cheat_sheet_rce_privesc.md).
