#!/bin/bash
echo "Whats your 2FA token?"
read tokencode

default_acess_key_id=`cat ~/.aws/credentials | grep aws_access_key_id | head -n 1 | cut -d '=' -f 2 | tr -d '[:space:]'`
default_secret_acess_key=`cat ~/.aws/credentials | grep aws_secret_access_key | head -n 1 | cut -d '=' -f 2 | tr -d '[:space:]'`
default_mfa_serial=`cat ~/.aws/config | grep mfa_serial | head -n 1 | cut -d '=' -f 2 | tr -d '[:space:]'`

echo "Running: aws sts get-session-token --serial-number $default_mfa_serial --token-code $tokencode"
aws sts get-session-token --serial-number $default_mfa_serial --token-code $tokencode > /tmp/tokencode_data_dump.txt
cat /tmp/tokencode_data_dump.txt
head -n4 ~/.aws/credentials > ~/.aws/credentials_new
temp_aws_access_key_id=`cat /tmp/tokencode_data_dump.txt | grep AccessKeyId | cut -d : -f 2 | tr -cd [:alnum:]`
temp_aws_secret_access_key=`cat /tmp/tokencode_data_dump.txt | grep SecretAccessKey | cut -d : -f 2 | sed 's/[^a-zA-Z0-9/+]//g'`
temp_aws_session_token=`cat /tmp/tokencode_data_dump.txt | grep SessionToken | cut -d : -f 2 | sed 's/[^a-zA-Z0-9/+]//g'`

echo "
[temp]
output = json
region = us-east-1
aws_access_key_id = $temp_aws_access_key_id
aws_secret_access_key = $temp_aws_secret_access_key
aws_session_token = $temp_aws_session_token
" >> ~/.aws/credentials_new

mv ~/.aws/credentials ~/.aws/credentials_old
cp ~/.aws/credentials_new ~/.aws/credentials
