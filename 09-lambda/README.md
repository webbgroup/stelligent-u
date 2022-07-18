# Topic 9: Lambda

<!-- TOC -->

- [Topic 9: Lambda](#topic-9-lambda)
  - [Conventions](#conventions)
  - [Lesson 9.1: Lambda is a fully-managed compute resource](#lesson-91-lambda-is-a-fully-managed-compute-resource)
    - [Principle 9.1](#principle-91)
    - [Practice 9.1](#practice-91)
      - [Lab 9.1.1: Simple Lambda function](#lab-911-simple-lambda-function)
      - [Lab 9.1.2: Lambda behind API Gateway](#lab-912-lambda-behind-api-gateway)
      - [Lab 9.1.3: Lambda & CloudFormation with awscli](#lab-913-lambda--cloudformation-with-awscli)
    - [Retrospective 9.1](#retrospective-91)
      - [Task](#task)
  - [Lesson 9.2: Lambda and other AWS resources](#lesson-92-lambda-and-other-aws-resources)
    - [Principle 9.2](#principle-92)
    - [Practice 9.2](#practice-92)
      - [Lab 9.2.1: Lambda with DynamoDB](#lab-921-lambda-with-dynamodb)
      - [Lab 9.2.2: Lambda via CloudWatch Rules](#lab-922-lambda-via-cloudwatch-rules)
      - [Lab 9.2.3: Query data with Lambda and API Gateway](#lab-923-query-data-with-lambda-and-api-gateway)
    - [Retrospective 9.2](#retrospective-92)
      - [Question](#question)
  - [Further Reading](#further-reading)

<!-- /TOC -->

## Conventions

- DO use the [AWS Lambda documentation](https://aws.amazon.com/documentation/lambda/),
  [DynamoDB documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html),
  and [ApiGateway documentation.](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-method.html)

- DO continuously commit all your templates and code to the topic
  folder in your GitHub repo.

## Lesson 9.1: Lambda is a fully-managed compute resource

### Principle 9.1

*As a fully managed compute resource, Lambda can reduce all the time and
effort to configure and maintain virtual servers.*

Lambda gives you a fully-managed compute resource running in AWS that
allows you to run your code on demand with very little configuration
needed and no maintenance required. AWS also provides robust testing
tools via Cloud9, and methods of packaging and deploying your code
easily. Lambda can be paired with API gateway to quickly create
microservices.

API Gateway is a fully managed service that makes it easy to create,
publish, maintain, monitor, and secure APIs at any scale. You can create
an API that acts as a "front door" for applications to access data or
functionality from your back-end services, such as workloads running on
EC2, code running on AWS Lambda, or any web application.

### Practice 9.1

#### Lab 9.1.1: Simple Lambda function

Create and test a simple AWS Lambda function using the Lambda console.

- Use the wizard to create a new Lambda using your choice of language.

Used the Wizard on the console

- Update the lambda to return "Hello AWS!" and use the "Test" tool to
  run a test.

Then switch to Sublime to execute.

- Review the options you have for testing and running Lambdas.

```
{
  "statusCode": 200,
  "body": "\"Hello AWS!\""
}
```

- When you're done, delete the Lambda.

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/09-lambda$ aws lambda list-functions --profile temp
{
    "Functions": [
        {
            "FunctionName": "joelsLamdaFunction",
            "FunctionArn": "arn:aws:lambda:us-east-1:324320755747:function:joelsLamdaFunction",
            "Runtime": "python3.8",
            "Role": "arn:aws:iam::324320755747:role/service-role/joelsLamdaFunction-role-jpjt77zj",
            "Handler": "lambda_function.lambda_handler",
            "CodeSize": 813,
            "Description": "",
            "Timeout": 3,
            "MemorySize": 128,
            "LastModified": "2022-07-18T13:12:40.000+0000",
            "CodeSha256": "sijk7PB/ysr4Vdg4ySouRcAuYlXw5P9TdXzTiTT/H80=",
            "Version": "$LATEST",
            "TracingConfig": {
                "Mode": "PassThrough"
            },
            "RevisionId": "9e85fa0e-c11e-4f78-93ab-b92ce66acfde",
            "PackageType": "Zip",
            "Architectures": [
                "x86_64"
            ],
            "EphemeralStorage": {
                "Size": 512
            }
        }
    ]
}

```

```
aws lambda delete-function --function-name joelsLamdaFunction --profile temp
```

#### Lab 9.1.2: Lambda behind API Gateway

Using API gateway to run a Lambda function.

- Use CloudFormation to create the same lambda as you did in lab 1.
  Use the in-line code feature to write the same "Hello AWS!"
  function.

- Add an AWS API gateway to your template. Configure the gateway so
  that it will call the lambda function. You will need to implement:

  - `AWS::ApiGateway::Method`
  - `AWS::ApiGateway::RestApi`
  - `AWS::ApiGateway::Deployment`
  - Lambda execution role (`AWS::IAM::Role`) with an AssumeRole policy
  - Appropriate Lambda invoke permissions (`AWS::Lambda::Permission`)

- Use the AWS CLI to call the API gateway which will call your Lambda
  function.

```
aws cloudformation --profile temp create-stack --stack-name Joels09 --template-body file://cfn-lambda.yaml --capabilities CAPABILITY_NAMED_IAM
{
    "StackId": "arn:aws:cloudformation:us-east-1:324320755747:stack/Joels09/391799b0-06a2-11ed-a255-124e5ba9dc41"
}
```

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/09-lambda$ aws lambda get-function --function-name Joels09-MyLambda-kuzr2jYZQNZU --profile temp
{
    "Configuration": {
        "FunctionName": "Joels09-MyLambda-kuzr2jYZQNZU",
        "FunctionArn": "arn:aws:lambda:us-east-1:324320755747:function:Joels09-MyLambda-kuzr2jYZQNZU",
        "Runtime": "python3.9",
        "Role": "arn:aws:iam::324320755747:role/MyLambdaExecutionRole",
        "Handler": "index.lambda_handler",
        "CodeSize": 272,
        "Description": "",
        "Timeout": 3,
        "MemorySize": 128,
        "LastModified": "2022-07-18T14:03:08.078+0000",
        "CodeSha256": "0sy82GKgXIHCHUlIZkzxLzPBWq1oaGysKfiwo8D8NDc=",
        "Version": "$LATEST",
        "TracingConfig": {
            "Mode": "PassThrough"
        },
        "RevisionId": "a82659ff-fe19-4613-a33c-6c8c28ee3aac",
        "State": "Active",
        "LastUpdateStatus": "Successful",
        "PackageType": "Zip",
        "Architectures": [
            "x86_64"
        ],
        "EphemeralStorage": {
            "Size": 512
        }
    },
    "Code": {
        "RepositoryType": "S3",
        "Location": "https://prod-04-2014-tasks.s3.us-east-1.amazonaws.com/snapshots/324320755747/Joels09-MyLambda-kuzr2jYZQNZU-e50abb38-5ccf-4cbb-8005-2f0eb5a16e87?versionId=2nxPKpz_Cd5TXXjRI3Ei6CW4nG0gTk5R&X-Amz-Security-Token=IQoJb3JpZ2luX2VjELb%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQDsS1B4zRdRV0nnzSGJzkmUk%2BBABfE3J9QlwgUqY76CUAIgQzu0A5GAliWDm9RKpx%2BsCrGBFbYxdA8kLB3kNtapwMMq2wQI7v%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgw3NDk2Nzg5MDI4MzkiDL7MK3CyVXscdBxVoiqvBPDiSXSwCXEavsprAN9oNisyNd7CK5180mLqu0cqXMtdxFIyOkmp6dnHzfLuuJCDuALhsQwwpHz9NEm%2FHy1dGn%2F4FM9Fa6sHI59rKr1YDwfvnFyKdOvz4HlQG4KAqegEkVICoBvVqofITNSrNf03hRlIVLjv%2BoKh%2BC3aXjKKRYHZurbGY8Jgpr9j9yOUtLkM6%2Fdmijs1uzkS4bvFHh4zAVXLAMqBnt%2F%2BH2Y%2FnYnio6bNuyaEpjBnktMujXfjYyJL0uIlTD2X8s02jxDkx83F8aHq9btyYZ2UPh3n%2BlBd8AnPEoS4%2B2uzFI6TwsweyDro0jnB2Kfd3M01x6g6h9fpFdbJ9ROuvpvoet%2Bm6Dl6zzMu9pn9mA6qhfOJo6h5c27D2c5cb7nihvCbwAkjNNoxpRb3LvgcW1A9otRyzVKQ8OE1O4XBGrxWy%2FV6wazXmoMmZjFqptJnWsy2ryr9234W7w1fPnid5cSFJWoac2XevfUgE3f0UiffRdODlILbKJ4jR1jigm%2BQFgO0rx7qOp9hdDah0YO1fFEOgSGL%2BS71VPHZVVywj4MjYOLYYJBrxfcimyfhd12uIYJbo1u5X3VzJSMdgTTQgyQIpXxi4WvOvUlOVSHghSbQmyiLpwHg8b0JyUpkK1EJCG2PCU9kRsJBQxbg%2B8M6k3sh5tF2Jr5QzUqZHhIgrQchjfin8p4oeB42A6xE45phc5I5IAarV3T5puhm9yfweQUOhvlI78HFe%2Bsw8rTVlgY6qQHQ6SZPWCo0XWmik3WhNJYsRCWHqcOd5ieaAbxOzMX4VdKVFaduCKreHsafc6m%2FIxXKmmwnxKxjbqqeQklp%2Bh%2BRHTqqnqkTQDAqRDAud%2FvFNZL5kSClWBjAUtygV%2FvD34DZPdTgArU5ksdi6PVmIL5Z%2FzhQRZLDgWYxx6fx5Wnl0V5vllg9KEYeAfXRqNglPDWizAddK7pZjNoWXFkXuXC%2FAyLeH%2F0cVcme&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220718T141242Z&X-Amz-SignedHeaders=host&X-Amz-Expires=599&X-Amz-Credential=ASIA25DCYHY33TYRIVUJ%2F20220718%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=dcb8f3f9a3e8659f373246d773d1a2ea0dde5f1edcfb50482ba0c14dab42e3ff"
    },
    "Tags": {
        "aws:cloudformation:stack-name": "Joels09",
        "aws:cloudformation:stack-id": "arn:aws:cloudformation:us-east-1:324320755747:stack/Joels09/391799b0-06a2-11ed-a255-124e5ba9dc41",
        "aws:cloudformation:logical-id": "MyLambda"
    }
}
```

```
 aws lambda invoke --function-name Joels09-MyLambda-kuzr2jYZQNZU response.json --profile temp
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```

- Lambdas can take a payload like JSON as input. Rewrite the function
  to take a JSON payload and simply return the payload, or an item
  from the payload.
```

joel@joels-desktop:~/Documents/Stelligent/stelligent-u/09-lambda$ aws lambda invoke --function-name Joels09-MyLambda-kuzr2jYZQNZU --payload '{ "key1": "value1", "key2": "value2" }' response.json --profile temp --cli-binary-format raw-in-base64-out
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```
```
cat response.json
{"statusCode": 200, "body": "\"First Key is value1\""}
```

#### Lab 9.1.3: Lambda & CloudFormation with awscli

Use the AWS CLI to create Lambda functions:

- Using the template you created in lab 2, move the in-line code to a
  separate file and update the Lambda resource to reference the
  handler.

- Use the "aws cloudformation package" and "\... deploy" commands to
  create the CloudFormation stack. Note: The "package" command will
  need an S3 bucket to temporarily store the deployment package.

- Use the API gateway to make a test call to the lambda to confirm
  it's working.

### Retrospective 9.1

#### Task

Review other methods of creating microservices using API Gateway and
Lambda such as [Chalice](https://github.com/aws/chalice) (Python),
[Claudia.js](https://claudiajs.com/tutorials/index.html) (Node)
and [Aegis](https://github.com/tmaiaroto/aegis) (Go).
Understand how you can use [AWS SAM](https://github.com/awslabs/serverless-application-model)
to test and deploy Lambdas.

## Lesson 9.2: Lambda and other AWS resources

### Principle 9.2

*Lambda can interact with other AWS services when using the appropriate
execution policies.*

Coupling Lambda with native AWS services allows you to create powerful
code very quickly. Lambda can even be used with CloudWatch events to
perform complex log analysis or react with automated mitigation
functionality.

### Practice 9.2

#### Lab 9.2.1: Lambda with DynamoDB

As a simple example, let's extend your Lambda function to write data to
a table in DynamoDB:

- Start with the template and code you created in lab 2

- Add a DynamoDB table with several attributes of your choice

- Update the Lambda code to take input based on the attributes and
  insert new items into the DynamoDB table.

Test the code using an API call as you've done before. Confirm that the
call is inserting the item in the table.

#### Lab 9.2.2: Lambda via CloudWatch Rules

CloudWatch rules can be used to call Lambda functions based on events.

- Add a CloudWatch rule to the template which targets your Lambda
  function when the S3 PutObject operation is called. If a trail
  doesn't exist for this, you may need to create one.

- Modify your Lambda handler to log some of the event data to the
  DynamoDB.

- Create an S3 bucket and test that the Lambda logs event data to the
  DB.

#### Lab 9.2.3: Query data with Lambda and API Gateway

Write another Lambda function that will query the DynamoDB table:

- The function should take a pattern (for instance, a bucket name) and
  return all events for that pattern.

- Add an API gateway that calls the Lambda to query the data.

### Retrospective 9.2

#### Question

*Can you think of practical ways an organization can use Lambda in
reaction to AWS resource changes?*

## Further Reading

- Read about [Capital One's Cloud Custodian project](https://stelligent.com/2017/05/15/cloud-custodian-cleans-up-your-cloud-clutter/)
  and see how it uses AWS Lambda.
