import json
import boto3
import os
from datetime import datetime, timedelta


def lambda_handler(event, context):
    # TODO implement
    print(event)
    ses = boto3.client('ses', region_name='us-east-1')
    guardduty = boto3.client('guardduty', region_name='us-east-1')
    detectorid = event['detail']['service']['detectorId']
    print("detectorId : ", detectorid)

    resourceType = event['detail']['resource']['resourceType']  # S3Bucket
    api = event['detail']['service']['action']['awsApiCallAction']['api']  # GetObject

    detect_time = event['detail']['service']['eventLastSeen']
    detect_time = detect_time.replace('T', ' ').replace('Z', '')
    detect_time = datetime.strptime(detect_time, '%Y-%m-%d %H:%M:%S.%f')
    detect_time = detect_time + timedelta(hours=9)
    print('detect_time : ', detect_time)

    src_email = os.environ.get("src_email")
    dst_email = os.environ.get("dst_email")
    bucket_name_var = os.environ.get("bucket_name_var")
    # print(src_email, src_email2, dst_email)

    if (resourceType == 'S3Bucket' and api == 'GetObject') or (resourceType == 'S3Bucket' and api == 'ListObjects'):
        bucket_name = event['detail']['resource']['s3BucketDetails'][0]['name']  # 버킷 이름
        if bucket_name == bucket_name_var:
            result = guardduty_reboot(guardduty, detectorid)  # 새로운 detecorid
            print(result)

            subject = "ECS Scenario Failed"
            body = "Guardduty bypass failed.\nDetection time : about {}\nPlease approach s3 by bypassing the GuardDuty.\n\n* hint : You can define the task and run task with your role(→ reverseshell)\nIt detects only s3 access.\n\nThank you.".format(
                detect_time)

            send_email(ses, src_email, dst_email, subject, body)
            # 24번행 수신자 발실자 둘 다 등록해야 함.
            return {
                'statusCode': 200,
                'body': json.dumps(result)
            }


def guardduty_reboot(guardduty, detectorid):
    response = guardduty.delete_detector(DetectorId=detectorid)  # 비활성화
    print("delete : ", response)  # 잘됨.

    try:
        # 활성화
        response = guardduty.create_detector(
            Enable=True,
            FindingPublishingFrequency='FIFTEEN_MINUTES'
        )
        print("create : ", response)
        detectorid = response['DetectorId']
        result = "재부팅 성공"
        return result
    except:
        result = "재부팅 실패"
        return result


def send_email(ses_client, src_email, dst_email, subject, body):
    ses_client.send_email(
        Source=src_email,
        Destination={
            'ToAddresses': [
                dst_email,
            ],
        },
        Message={
            'Subject': {
                'Data': subject,
            },
            'Body': {
                'Text': {
                    'Data': body,
                },
            },
        }
    )