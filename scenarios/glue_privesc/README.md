# Scenario : Glue_privesc

**Size:** ~ing

**Difficulty:** ~ing

**Command:** `$ ./cloudgoat.py create glue_privesc`
### Scenario Resources

- 1 VPC with:
    - S3  x 1
    - RDS x1
    - EC2 x1
    - Glue service
- Lambda x1
- SSM parameter Store
- IAM Users x 2

### Scenario Start(s)

Web address

### Scenario Goal(s)

Find a secret string stored in the ssm parameter store

### Summary

There is an environment that is implemented as shown in the schematic drawing below. Glue service manager will accidentally upload their access keys through the web page. The manager hurriedly deleted the key from s3, but does not recognize that the key was stored in the DB.

Find the manager's key and access the ssm parameter store with a vulnerable permission to find the parameter value named “flag”.

### Schematic drawing

![Untitled](glue%20privesc%20%E1%84%89%E1%85%B5%E1%84%82%E1%85%A1%E1%84%85%E1%85%B5%E1%84%8B%E1%85%A9%20Readme,%20Write-up%20(23%2011%2005%20)%20acff88b964b14b528a3e492b716b26bc/Untitled.png)

### Exploitation Route(s)

![Untitled](glue%20privesc%20%E1%84%89%E1%85%B5%E1%84%82%E1%85%A1%E1%84%85%E1%85%B5%E1%84%8B%E1%85%A9%20Readme,%20Write-up%20(23%2011%2005%20)%20acff88b964b14b528a3e492b716b26bc/Untitled%201.png)

### Route Walkthrough

※ The attacker identifies the web page functionality first. When you upload a file, it is stored in a specific s3, and you can see that the data in that file is applied to the monitoring page.

1. The attacker steals the Glue administrator's access key and secret key through a SQL Injection attack on the web page.
2. The attacker checks the policies and permissions of the exposed account to identify any vulnerable privileges. Through these privileges, the attacker discovers the ability to create and execute a job that can perform a reverse shell attack, enabling them to obtain the desired role simultaneously.
3. List the roles to use "iam:passrole," write the reverse shell code, and insert this code file (.py) into S3 through the web page.
4. In order to gain SSM access, Perform the creation of a Glue service job via AWS CLI, which also executes the reverse shell code.
5. Execute the created job.
6. Extract the value of “flag”(parameter name) from the ssm parameter store.

※ 공격자는 웹 페이지 기능을 먼저 파악합니다. 파일을 업로드하면 특정 s3에 저장되고, 해당 파일에 있는 데이터는 모니터링 페이지에 적용된다는 것을 알 수 있습니다.

1. 공격자는 웹 페이지에서 SQL Injection 공격을 통해서 glue 관리자의 액세스키, 시크릿키를 탈취한다.
2. 탈취한 계정에 대한 정책과 퍼미션을 확인하여 취약한 권한을 가지고 있다는 것을 확인합니다. 공격자는 이 권한을 통해 리버스 쉘 공격을 수행해주는 job을 생성하고, 실행과 동시에 원하는 역할을 얻을 수 있음을 알게 됩니다.
3. passrole 기능을 사용하기 위해 사용할 수 있는 역할을 나열하고, 리버스 쉘 코드를 작성한 .py 파일을 웹 페이지를 통해서 s3에 집어넣는다.
4. 리버스 쉘 코드를 실행함과 동시에 ssm 접근 권한을 가질 수 있도록 해주는 glue서비스의 job생성 기능을 aws cli를 통해 수행한다.
5. 생성된 job을 실행시켜준다.
6. ssm parameter store에서 flag의 값을 추출해낸다.

[glue privesc write-up](https://www.notion.so/glue-privesc-write-up-e92eba8f7ed048249019416a66afe93e?pvs=21)
