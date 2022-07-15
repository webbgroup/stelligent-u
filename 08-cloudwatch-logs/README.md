# Topic 8: CloudWatch

<!-- TOC -->

- [Topic 8: CloudWatch](#topic-8-cloudwatch)
  - [Conventions](#conventions)
  - [Lesson 8.1: CloudWatch Logs storage and retrieval](#lesson-81-cloudwatch-logs-storage-and-retrieval)
    - [Principle 8.1](#principle-81)
    - [Practice 8.1](#practice-81)
      - [Lab 8.1.1: Log groups and streams](#lab-811-log-groups-and-streams)
      - [Lab 8.1.2: The CloudWatch agent](#lab-812-the-cloudwatch-agent)
      - [Lab 8.1.3: 3rd party tool awslogs](#lab-813-3rd-party-tool-awslogs)
      - [Lab 8.1.4: CloudWatch logs lifecycle](#lab-814-cloudwatch-logs-lifecycle)
      - [Lab 8.1.5: Clean up](#lab-815-clean-up)
    - [Retrospective 8.1](#retrospective-81)
  - [Lesson 8.2: CloudWatch Logs with CloudTrail events](#lesson-82-cloudwatch-logs-with-cloudtrail-events)
    - [Principle 8.2](#principle-82)
    - [Practice 8.2](#practice-82)
      - [Lab 8.2.1: CloudWatch and CloudTrail resources](#lab-821-cloudwatch-and-cloudtrail-resources)
      - [Lab 8.2.2: Logging AWS infrastructure changes](#lab-822-logging-aws-infrastructure-changes)
      - [Lab 8.2.3: Clean up](#lab-823-clean-up)
    - [Retrospective 8.2](#retrospective-82)
      - [Question](#question)
      - [Task](#task)

<!-- /TOC -->

## Conventions

- DO review CloudFormation documentation to see if a property is
  required when creating a resource.

## Lesson 8.1: CloudWatch Logs storage and retrieval

### Principle 8.1

CloudWatch Logs are the best way to securely and reliably store text
logs from application services and AWS resources (EC2, Lambda,
CodePipeline, etc) over time.

### Practice 8.1

This section shows you how to configure CloudWatch to monitor and store
logs for AWS resources, as well as how to retrieve and review those logs
using the AWS CLI and a utility called "awslogs".

#### Lab 8.1.1: Log groups and streams

A log group is an arbitrary collection of similar logs, using whatever
definition of "similar" you want. A log stream is a uniquely
identifiable flow of data into that group. Use the AWS CLI to create a
log group and log stream:

- Name the log group based on your username: *first.last*.c9logs
```
aws logs create-log-group --log-group-name joel.webb.c9logs --profile temp
```

- Name the log stream named c9.training in your log group.
```
aws logs create-log-stream --log-group-name joel.webb.c9logs --log-stream-name c9.training --profile temp
```

When you're done, list the log groups and the log streams to confirm
they exist.

```
aws logs describe-log-groups --profile temp
{
    "logGroups": [
        {
            "logGroupName": "joel.webb.c9logs",
            "creationTime": 1657887654779,
            "metricFilterCount": 0,
            "arn": "arn:aws:logs:us-east-1:324320755747:log-group:joel.webb.c9logs:*",
            "storedBytes": 0
        }
    ]
}

```

```
aws logs describe-log-streams --log-group-name joel.webb.c9logs --profile temp
{
    "logStreams": [
        {
            "logStreamName": "c9.training",
            "creationTime": 1657887757739,
            "arn": "arn:aws:logs:us-east-1:324320755747:log-group:joel.webb.c9logs:log-stream:c9.training",
            "storedBytes": 0
        }
    ]
}

```

#### Lab 8.1.2: The CloudWatch agent

The CloudWatch agent is the standard tool for sending log data to
CloudWatch Logs. We've provided a stack template for you in your *clone*
of the
[stelligent-u](https://github.com/stelligent/stelligent-u)
repo:

- [Documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-on-first-instance.html)
  for installing the Cloud Watch agent, for reference.
  The example template installs the agent.

Had to create an instance manually, and an ssh-key-pair, attach it to the VPC, add a publicIP and then I was able to connect to it.

This should have been an Ubuntu instance... but the configuration should be fine.

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/08-cloudwatch-logs$ ssh -i ~/Desktop/joels-key-pair.pem ec2-user@34.229.95.16

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
5 package(s) needed for security, out of 14 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-10-0-42-171 ~]$ /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
-bash: /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard: No such file or directory
[ec2-user@ip-10-0-42-171 ~]$ sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
sudo: /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard: command not found
[ec2-user@ip-10-0-42-171 ~]$ cat /etc/issue
\S
Kernel \r on an \m

[ec2-user@ip-10-0-42-171 ~]$ sudo yum install amazon-cloudwatch-agent
Loaded plugins: extras_suggestions, langpacks, priorities, update-motd
Resolving Dependencies
--> Running transaction check
---> Package amazon-cloudwatch-agent.x86_64 0:1.247352.0-1.amzn2 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

========================================================================================================================================================================================
 Package                                              Arch                                Version                                         Repository                               Size
========================================================================================================================================================================================
Installing:
 amazon-cloudwatch-agent                              x86_64                              1.247352.0-1.amzn2                              amzn2-core                               45 M

Transaction Summary
========================================================================================================================================================================================
Install  1 Package

Total download size: 45 M
Installed size: 203 M
Is this ok [y/d/N]: y
Downloading packages:
amazon-cloudwatch-agent-1.247352.0-1.amzn2.x86_64.rpm                                                                                                            |  45 MB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
create group cwagent, result: 0
create user cwagent, result: 0
create user aoc, result: 6
  Installing : amazon-cloudwatch-agent-1.247352.0-1.amzn2.x86_64                                                                                                                    1/1
  Verifying  : amazon-cloudwatch-agent-1.247352.0-1.amzn2.x86_64                                                                                                                    1/1

Installed:
  amazon-cloudwatch-agent.x86_64 0:1.247352.0-1.amzn2

Complete!

```

Creation below:

```
Please check the above content of the config.
The config file is also located at /opt/aws/amazon-cloudwatch-agent/bin/config.json.
Edit it manually if needed.
Do you want to store the config in the SSM parameter store?
1. yes
2. no
default choice: [1]:

What parameter store name do you want to use to store your config? (Use 'AmazonCloudWatch-' prefix if you use our managed AWS policy)
default choice: [AmazonCloudWatch-linux]
^C
[ec2-user@ip-10-0-42-171 ~]$ sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
================================================================
= Welcome to the Amazon CloudWatch Agent Configuration Manager =
=                                                              =
= CloudWatch Agent allows you to collect metrics and logs from =
= your host and send them to CloudWatch. Additional CloudWatch =
= charges may apply.                                           =
================================================================
On which OS are you planning to use the agent?
1. linux
2. windows
3. darwin
default choice: [1]:
1
Trying to fetch the default region based on ec2 metadata...
Are you using EC2 or On-Premises hosts?
1. EC2
2. On-Premises
default choice: [1]:
1
Which user are you planning to run the agent?
1. root
2. cwagent
3. others
default choice: [1]:
2
Do you want to turn on StatsD daemon?
1. yes
2. no
default choice: [1]:
1
Which port do you want StatsD daemon to listen to?
default choice: [8125]

What is the collect interval for StatsD daemon?
1. 10s
2. 30s
3. 60s
default choice: [1]:

What is the aggregation interval for metrics collected by StatsD daemon?
1. Do not aggregate
2. 10s
3. 30s
4. 60s
default choice: [4]:

Do you want to monitor metrics from CollectD? WARNING: CollectD must be installed or the Agent will fail to start
1. yes
2. no
default choice: [1]:

Do you want to monitor any host metrics? e.g. CPU, memory, etc.
1. yes
2. no
default choice: [1]:

Do you want to monitor cpu metrics per core?
1. yes
2. no
default choice: [1]:

Do you want to add ec2 dimensions (ImageId, InstanceId, InstanceType, AutoScalingGroupName) into all of your metrics if the info is available?
1. yes
2. no
default choice: [1]:

Do you want to aggregate ec2 dimensions (InstanceId)?
1. yes
2. no
default choice: [1]:

Would you like to collect your metrics at high resolution (sub-minute resolution)? This enables sub-minute resolution for all metrics, but you can customize for specific metrics in the output json file.
1. 1s
2. 10s
3. 30s
4. 60s
default choice: [4]:

Which default metrics config do you want?
1. Basic
2. Standard
3. Advanced
4. None
default choice: [1]:
3
Current config as follows:
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "aggregation_dimensions": [
      [
        "InstanceId"
      ]
    ],
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}"
    },
    "metrics_collected": {
      "collectd": {
        "metrics_aggregation_interval": 60
      },
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ],
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "used_percent",
          "inodes_free"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time",
          "write_bytes",
          "read_bytes",
          "writes",
          "reads"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "statsd": {
        "metrics_aggregation_interval": 60,
        "metrics_collection_interval": 10,
        "service_address": ":8125"
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
Are you satisfied with the above config? Note: it can be manually customized after the wizard completes to add additional items.
1. yes
2. no
default choice: [1]:
1
Do you have any existing CloudWatch Log Agent (http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AgentReference.html) configuration file to import for migration?
1. yes
2. no
default choice: [2]:
1
What is the file path for the existing cloudwatch log agent configuration file?
default choice: [/var/awslogs/etc/awslogs.conf]
```


- We need to generate a Cloud Watch configuration file to be included
  in your Cloud Formation Template. The simplest way to approach this
  is to start an EC2 instance with the Cloud Watch agent installed and
  use the wizard it provides. For the example Cloud Formation template
  the wizard is in
  `/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard`
  You will need to add references to the log streams defined in 8.1.1
  [Documentation on generating the template file](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-cloudwatch-agent-configuration-file.html)
  for reference.

- The wizard will prompt you to use `collectd`, but we do not recommend this
  as it can cause the agent to fail to start
Removed the collectd to start.

- Modify the template mappings to reference your
  own VPC ID's and Subnet ID generated in other lessons,
  or provide appropriate code in the resources section.

- Once you have added the Cloud Watch configuration to your Cloud Formation template,
  delete the running stack, and relaunch.

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/08-cloudwatch-logs$ aws cloudformation --profile temp create-stack --stack-name Joels08-1 --template-body file://vpc.yaml
{
    "StackId": "arn:aws:cloudformation:us-east-1:324320755747:stack/Joels08-1/4c2e0270-044d-11ed-8c0b-0a5b40936121"
}
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/08-cloudwatch-logs$ !2261
aws cloudformation --profile temp update-stack --stack-name Joels08-1 --template-body file://8.1.2.yml

An error occurred (InsufficientCapabilitiesException) when calling the UpdateStack operation: Requires capabilities : [CAPABILITY_IAM]
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/08-cloudwatch-logs$ aws cloudformation --profile temp update-stack --stack-name Joels08-1 --template-body file://8.1.2.yml --capabilities CAPABILITY_NAMED_IAM
{
    "StackId": "arn:aws:cloudformation:us-east-1:324320755747:stack/Joels08-1/4c2e0270-044d-11ed-8c0b-0a5b40936121"
}

```

- Use the AWS CLI to display the log events for your group and stream from 8.1.1.

> *Note:* logs may take several minutes to appear.

#### Lab 8.1.3: 3rd party tool awslogs

[awslogs](https://github.com/jorgebastida/awslogs) is a
publicly-available Python tool that you can use to read CloudWatch logs.
It's especially convenient for tailing the log streams, showing you data
as it arrives.

- Install the awslogs client on your running EC2 instance.

- Use it to watch logs as they are put into your log group.

- Use awslogs to get logs from your group from the last 5 minutes,
  last 20 minutes and last hour.

#### Lab 8.1.4: CloudWatch logs lifecycle

Any time you're logging information, it's important to consider the
lifecycle of the logs.

- Use the AWS CLI to [set the retention policy](https://docs.aws.amazon.com/cli/latest/reference/logs/put-retention-policy.htm)
  of your log group to 60 days.

- Use the CLI to review the policy in your log group.

- Set the retention policy to the maximum allowed time, and review the
  change again to double-check.

#### Lab 8.1.5: Clean up

You can tear down your EC2 stack at this point.

Use the AWS CLI to remove the log group and log stream you created
earlier.

You'll need [jorgebastida/awslogs](https://github.com/jorgebastida/awslogs)
in Lesson 8.2.1, so now's a good time to install it on your laptop. You may
find that it's handy for client engagements and future lab work as well.

### Retrospective 8.1

*Log retention is an important issue that can affect many parts of a
company's business. It's helpful to know what CloudWatch Log's service
limitations are.*

- What are the minimum and maximum retention times?

- Instead of keeping data in CW Logs forever, can you do anything else
  with them? What might a useful lifecycle for logs look like?

## Lesson 8.2: CloudWatch Logs with CloudTrail events

### Principle 8.2

*CloudWatch Logs let you monitor AWS API changes via CloudTrail logged
events.*

### Practice 8.2

This section demonstrates CloudWatch's ability to send alerts based on
changes to AWS resources made via the API changes, identified through
CloudTrail events. This is useful for many reasons. For example, you may
want to understand what changes are being made to AWS resources and
decide if they are appropriate. Notifications or automated corrective
action can be configured when inappropriate changes are being made.

#### Lab 8.2.1: CloudWatch and CloudTrail resources

Let's switch from the awscli to CloudFormation. Create a template that
provides the following in a single stack:

- A new CloudWatch Logs log group

- An S3 bucket for CloudTrail to publish logs.

- A CloudTrail trail that uses the CloudWatch log group.

#### Lab 8.2.2: Logging AWS infrastructure changes

Now that you have your logging infrastructure, create a separate stack
for the resources that will use it:

- Create an S3 bucket or any other AWS resource of your choice.

- Add tags that mark it with your AWS username, and identify it as a
  stelligent-u resource with this topic and lab number.

- Use awslogs client utility to review the logs from the new group.
  You should see the activity from creating and changing the
  resource.

- Delete the CloudFormation stack and resources.

- Use the awslogs utility again to view those changes.

#### Lab 8.2.3: Clean up

- Delete any stacks that you made for this topic.

- Make sure you keep all of the CloudFormation templates from this
  lesson in your GitHub repo.

### Retrospective 8.2

#### Question

_What type of events might be important to track in an AWS account? If
you were automating mitigating actions for the events, what might they
be and what AWS resource(s) would you use?_

#### Task

Dig out the CloudFormation template you used to create the CloudTrail
trail in lab 8.2.1. Add a CloudWatch event, SNS topic and SNS
subscription that will email you when any changes to EC2 instances are
made. Test this mechanism by creating and modifying new EC2 instances.
Make sure to clean up the CloudFormation stacks and any other resources
when you are done.
