import json
import boto3
import os
import time


def lambda_handler(event, context):
    # 환경 변수에서 정보 가져오기
    user_email = os.environ['USER_EMAIL']
    iam_role_1 = os.environ['IAM_ROLE_1']
    iam_role_2 = os.environ['IAM_ROLE_2']
    detector_id = os.environ['GUARDDUTY_DETECTOR_ID']
    account_id = os.environ['ACCOUNT_ID']

    # 이벤트에서 EC2 인스턴스 ID와 현재 할당된 역할 이름을 추출
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']
    current_role_name = event['detail']['resource']['accessKeyDetails']['userName']

    # boto3 클라이언트 생성
    iam = boto3.client('iam')
    ec2_client = boto3.client('ec2')
    ses = boto3.client('ses')
    guardduty = boto3.client('guardduty')

    # 새로 할당할 역할을 결정
    if current_role_name == iam_role_1:
        new_role = iam_role_2
    elif current_role_name == iam_role_2:
        new_role = iam_role_1
    else:
        print("현재 역할이 env와 일치하지 않습니다.")
        return

    try:
        # 현재 인스턴스에 할당된 IAM 역할을 해제
        response = ec2_client.replace_iam_instance_profile_association(
            IamInstanceProfile={
                'Arn': f'arn:aws:iam::{account_id}:instance-profile/{new_role}',
                'Name': new_role
            },
            AssociationId=instance_id
        )
        print("역할이 성공적으로 변경되었습니다.")
        print(response)
    except Exception as e:
        print("역할 변경 중 오류가 발생했습니다.")
        print(e)

    # 이메일 전송
    subject = "GuardDuty Alert: Unauthorized Access"
    body_text = "GuardDuty has detected unauthorized access. \n\n" + json.dumps(event, indent=4)
    ses.send_email(
        Source=user_email,
        Destination={'ToAddresses': [user_email]},
        Message={
            'Subject': {'Data': subject},
            'Body': {'Text': {'Data': body_text}}
        }
    )

    # Finding의 상태 업데이트
    try:
        # 동적으로 findings 조회
        findings = guardduty.list_findings(DetectorId=detector_id, MaxResults=10)
        findings_ids = findings.get('FindingIds', [])

        # 조건을 만족하는 findings의 상태 업데이트
        if findings_ids:
            guardduty.update_findings_feedback(
                DetectorId=detector_id,
                FindingIds=findings_ids,
                Feedback='NEW'
            )

        print("Findings status update success.")
    except Exception as e:
        print("Findings 상태 업데이트 실패:", str(e))

    return {
        'statusCode': 200,
        'body': 'Processed successfully!'
    }
