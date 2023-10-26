# Scenario: guardduty_bypass_with_ecs

---

**Size**: `please choose one.`

Difficulty: `please choose one.`

Command: `$ ./cloudgoat.py create guardduty_bypass_with_ecs`

## Scenario Resources

---

- 1 ECS with:
    - 1 * ASG with :
        - 1 * EC2
    - 1 * Service (web container)
- 1 * S3
- Detection Mechanisms
  - GuardDuty enabled
  - CloudWatch
  - EventBridge
  - Lambda
  - SES

## Scenario Start(s)

---

Scenario starts as a web user.

## Scenario Goal(s)

---

Read flag.txt in S3 without being detected by GuardDuty.

## Summary

---

An SSRF (Server Side Request Forgery) attack targeting a web server running on an EC2 instance can enable you to retrieve credentials from the EC2 metadata service. You can then use these credentials to access an S3 bucket. However, be cautious of AWS Guard Duty, as it might detect and respond to unusual activities associated with S3 access.

## Email setup

---
 
- AWS GuardDuty will track the use of the credentials you obtained with SSRF and will send you an email if the tracking is successful.So you need to register an email and respond to AWS authentication mail sent to that email before using the scenario.
- If you prefer not to use a standard email address, you might consider services such as https://temp-mail.org/ or https://www.fakemail.net/.

# SPOILER ALERT: There are spoilers for the scenario blew this point.

---

## Exploitation Route

---

![Scenario Route(s)](assets/diagram.png)

## Scenario Walk-through

---

- Attacker accesses the web service of a container inside EC2 managed by ECS.
- The attacker exploits an SSRF vulnerability in a web service to access the EC2 metadata service and steal temporary credentials.
- The attacker defines and executes an ECS task with the authority of the web developer to bypass GuardDuty. Perform a reverse shell attack to access the container been created.
- The attacker accesses S3 at the container to bypass GuardDuty detection. Gets the Secret String and exits the scenario.

