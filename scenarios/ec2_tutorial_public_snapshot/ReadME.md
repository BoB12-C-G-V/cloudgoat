# Scenario: detection_evasion

**Size:**  Small

**Difficulty:** Easy

**Command:** $ ./cloudgoat.py create public_ebs_snapshot

## Scenario Resources (High Level)

- 1 IAM Users
- 2 EC2 instances
- 1 EBS & Snapshot

## Scenario Start(s)

IAM User "block"

## Scenario Goal(s)

The goal of this scenario is to read out the secrets value using public EBS Snapshot not encrypted. The secrets are stored specific dir in EBS, and their values have the following format (cg-secret-XXXXXX-XXXXXX).

이 시나리오의 목표는 암호화되지 않은 공개 EBS 스냅샷을 사용하여 비밀값을 읽어내는 것입니다. 시크릿은 EBS의 특정 디렉터리에 저장되며, 그 값은 다음과 같은 형식(cg-secret-XXXXXX-XXXXXX)을 가집니다.

## Summary (TLDR setup below)

Starting with the IAM user Block, the attacker first explores EC2 instances and discovers that snapshots of EBS volumes associated with a particular instance are not encrypted. The attacker then finds an instance with SSM enabled and uses the snapshot on that instance to obtain the secret string stored in EBS. 

IAM 사용자 Block으로 시작하여 공격자는 먼저 EC2 인스턴스를 탐색하고 특정 인스턴스에 연결된 EBS볼륨의 스냅샷이 암호화 되지 않은 것을 발견합니다. 그런 다음 공격자는 SSM이 동작하는 인스턴스를 발견후 해당 인스턴스에 스냅샷을 사용하여 EBS에 저장되어있던 비밀 문자열을 획득 할 수 있습니다. 



## Exploitation Route

![Scenario Route(s)](./public_EBS_Snapshot_diagrams.png)

## Walkthrough Overview - Easy Path


1. administrator **`Music`** creates a public snapshot on an EBS volume in EC2 containing **`secret.txt`**.
2. user **`block`** discovers the public EBS snapshot.
3. **`block`** creates an AMI image and an EC2 instance from the discovered snapshot.
4. **`block`** connects to the new EC2 instance and steals sensitive information from **`secret.txt`**.c


1. 관리자 **`Music`**은 **`secret.txt`**를 포함하는 EC2의 EBS 볼륨에서 public 스냅샷을 생성합니다.
2. 유저 **`block`**은 public EBS 스냅샷을 발견합니다.
3. **`block`**은 발견한 스냅샷으로 AMI 이미지와 EC2 인스턴스를 생성합니다.
4. **`block`**은 새 EC2 인스턴스에 접속하여 **`secret.txt`**에서 민감한 정보를 탈취합니다.