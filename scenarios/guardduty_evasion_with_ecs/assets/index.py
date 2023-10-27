import json
import boto3
import os
from datetime import datetime, timedelta


def lambda_handler(event, context):
    print(event)
    ses = boto3.client('ses', region_name='us-east-1')

    detect_time = event['detail']['service']['eventLastSeen']
    detect_time = detect_time.replace('T', ' ').replace('Z', '')
    detect_time = datetime.strptime(detect_time, '%Y-%m-%d %H:%M:%S.%f')
    detect_time = detect_time + timedelta(hours=9)
    print('detect_time : ', detect_time)

    src_email = os.environ.get("src_email")
    dst_email = os.environ.get("dst_email")

    resourceType = event['detail']['resource']['resourceType']

    guardduty = boto3.client('guardduty', region_name='us-east-1')
    detectorid = event['detail']['service']['detectorId']
    result = guardduty_reboot(guardduty, detectorid)
    print(result)

    if resourceType == 'S3Bucket':
        handle_s3_event(event, ses, src_email, dst_email, detect_time)
    elif resourceType == 'EC2Instance':
        handle_ec2_event(event, ses, src_email, dst_email, detect_time)

    return {
        'statusCode': 200,
        'body': json.dumps('Event handled')
    }


def handle_s3_event(event, ses, src_email, dst_email, detect_time):
    bucket_name = event['detail']['resource']['s3BucketDetails'][0]['name']

    subject = "S3 Incident Detected"
    body = ("An incident related to S3 bucket {} was detected at {}. The bucket name matches the configured bucket "
            "name variable. GuardDuty has been rebooted. Please investigate immediately.").format(
        bucket_name, detect_time)

    send_email(ses, src_email, dst_email, subject, body)


def handle_ec2_event(event, ses, src_email, dst_email, detect_time):
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']

    refresh_instance_credentials(instance_id)

    subject = "EC2 Incident Detected"
    body = "An incident related to EC2 instance {} was detected at {}. Please investigate immediately.".format(
        instance_id, detect_time)
    send_email(ses, src_email, dst_email, subject, body)


def refresh_instance_credentials(instance_id):
    ec2 = boto3.resource('ec2', region_name='us-east-1')
    instance = ec2.Instance(instance_id)

    iam_role_name = instance.iam_instance_profile['Arn'].split('/')[-1]

    iam = boto3.client('iam')
    role = iam.get_role(RoleName=iam_role_name)

    current_policy = role['Role']['AssumeRolePolicyDocument']

    iam.update_assume_role_policy(RoleName=iam_role_name, PolicyDocument=json.dumps(current_policy))


def send_email(ses_client, src_email, dst_email, subject, body):
    ses_client.send_email(
        Source=src_email,
        Destination={'ToAddresses': [dst_email]},
        Message={'Subject': {'Data': subject}, 'Body': {'Text': {'Data': body}}}
    )


def guardduty_reboot(guardduty, detectorid):
    response = guardduty.delete_detector(DetectorId=detectorid)
    print("delete : ", response)

    try:
        response = guardduty.create_detector(Enable=True, FindingPublishingFrequency='FIFTEEN_MINUTES')
        print("create : ", response)
        detectorid = response['DetectorId']
        result = "Reboot successful. New detectorId: {}".format(detectorid)
        return result
    except Exception as e:
        print("Error: ", str(e))
        result = "Reboot failed"
        return result