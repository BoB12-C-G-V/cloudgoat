import json
import boto3


def lambda_handler(event, context):
    # print(event)
    event_name = event['detail']['eventName']

    ecs_client = boto3.client('ecs')

    if event_name == "RegisterTaskDefinition":
        command = event['detail']['responseElements']['taskDefinition']['containerDefinitions'][0]['command']
        block = cmd_filtering(command)

        if block:
            task_definition_name = \
            event['detail']['responseElements']['taskDefinition']['taskDefinitionArn'].split('/')[-1]
            print(task_definition_name)
            result = delete_task_defn(ecs_client, task_definition_name)
        else:
            result = "bypass success!! How do you run a task in reverse s**l?"
    else:
        result = "It's not RegisterTaskDefinition process"

    print(result)
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }


def cmd_filtering(command):
    cmd_list = []
    cmd_len = len(command)

    for i in range(cmd_len):
        command[i] = command[i].replace('"', '')
        command[i] = command[i].replace('\'', '')

        tmp_list = command[i].split(' ')
        cmd_list.extend(tmp_list)

    cmd_list = set(cmd_list)
    print(cmd_list)

    # 악의적인 명령어 필터링
    vuln_cmd = ['cat', 'more', 'less', 'head', 'tail', 'nl', 'pattern', 'awk', 'sed', 'rm', 'mkdir', 'ls']
    vuln_cmd = set(vuln_cmd)

    dup = cmd_list.intersection(vuln_cmd)

    if dup:  # 중복된 명령어가 있는 경우
        return True
    else:  # 중복된 명령어가 없는 경우
        return False


def delete_task_defn(ecs_client, task_definition_name):
    try:
        res = ecs_client.deregister_task_definition(taskDefinition=task_definition_name)
        print("ECS Task 삭제 응답:", res)
        return "ECS Task 삭제 요청 완료"

    except Exception as e:
        print("ECS Task 삭제 중 오류 발생:", str(e))
        return "ECS Task 삭제 중 오류 발생"
