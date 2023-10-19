# Scenario Resources

- ECS
    - EC2 instance
    - Fargate
- S3
- 탐지 메커니즘
    - GuardDuty
    - Lambda Function
    - EventBridge
    - CloudWatch
    - SES

# Scenario **Schematicization**

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/20e97f8e-ada7-4ab6-8e8f-08d05d825976/190831e4-8402-4c8c-bfb5-0a5b6b1429f2/Untitled.png)

# Scenario Start

- SSRF가 발생하는 Web을 제공

# Scenario Goal

- GuardDuty에 탐지 되지 않고 S3 Bucket 안에 있는 Secret string을 읽는 것입니다.

# Email setup

이 시나리오는 GuardDuty 탐지 알림을 트리거하지 않고 Flag를 완료하는 것 입니다. 따라서 이 시나리오를 하려면 이메일 알림을 보낼 수 있는 이메일 주소를 제공해야 합니다. GuardDuty에 의해 감지가 되면 이 이메일로 알림이 전송됩니다. 표준 이메일 주소를 사용하고 싶지 않다면 https://temp-mail.org/ 또는 https://www.fakemail.net/ 같은 서비스를 고려할 수 있습니다.

Terrafomr 개발자 분은 Player의 이메일을 입력 받아 람다 환경 변수에 저장해주어 람다 함수가 잘 동작하도록 부탁드립니다. (코드 확인)

# Summary

- 웹을 실행하는 EC2 인스턴스에 SSRF 공격을 통하여 EC2 메타데이터 서비스에서 자격 증명을 얻고,  이를 이용해 S3 Bucket에 액세스하게 됩니다. S3 접근 시, GuardDuty에 걸리지 않게 주의하세요!

---

# Scenario walk-through

1. ECS 안에 있는 EC2 인스턴스에서 웹 서버로 동작하고 있습니다.
2. 이 웹 서버는 SSRF 취약점이 발생하고 메타 데이터 서비스에 접근할 수 있습니다.
3. 메타 데이터 서비스에 접근해서 임시 자격 증명을 탈취할 수 있습니다. 이 자격 증명의 권한은 task를 정의하고 실행할 수 있는 권한과 S3 접근 권한을 가질 수 있습니다.
4. 이 임시 자격 증명을 얻어 S3에 접근을 하면 GuardDuty에 탐지가 됩니다. -> 탐지가 되면 Player에게 Guardduty에 의해 탐지 되었고, 시나리오에 실패했다는 메일을 발송합니다.
5. 정상적인 방법으로는 GuardDuty에 막히는 것을 깨달은 공격자는 리버스 쉘이 포함된 ecs task를 정의하고 task를 실행합니다.
6. 리버스 쉘을 이용하여 S3에 접근함으로써 GuardDuty를 우회합니다.
7. S3에 있는 정보(Flag)를 탈취합니다.