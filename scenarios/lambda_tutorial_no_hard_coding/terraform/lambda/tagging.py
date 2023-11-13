import os
import boto3
import subprocess
import json
import urllib.parse



aws_access_key_id = os.environ['AWS_ACCESS_KEY_ID']
aws_secret_access_key = os.environ['AWS_SECRET_ACCESS_KEY']
s3 = boto3.client('s3', aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key)

def lambda_handler(event, context):
    
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    fileKey = event['Records'][0]['s3']['object']['key']
    bucketName = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        print("CONTENT TYPE: " + response['ContentType'])

        file_download_path = f'/tmp/{key.split("/")[-1]}'
        with open(file_download_path, 'wb+') as file:
            file.write(response['Body'].read())
            
        file_count_KB = subprocess.check_output(
            "stat -c %s /tmp/" + key,
            shell=True,
            stderr=subprocess.STDOUT).decode().rstrip()

        file_count_KB = str(file_count_KB).rstrip()
        
        if int(file_count_KB) < 1000000:
            new_location = subprocess.check_output("pwd", shell=True, stderr=subprocess.STDOUT).decode().rstrip()
            s3.put_object_tagging(
                Bucket=bucket,
                Key=key,
                Tagging={
                    'TagSet': [
                        {
                            'Key': 'Path',
                            'Value': new_location
                        },{
                            'Key': 'Size',
                            'Value': file_count_KB
                        }
                    ]
                }
            )
        else:
            print("File too big")


    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(fileKey, bucketName))
        
        
        
        
