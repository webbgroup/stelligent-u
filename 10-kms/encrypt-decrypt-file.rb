require 'aws-sdk-s3'

bucket_name = 'joels-encryption-bucket'
object_key = 'secret.txt'
region = 'us-east-1'
kms_key_id = '6ff84455-5648-47f2-aa41-5c06d0bdcf5a'

# Yes the following lines are ugly as sin, but I couldn't find a way to use the temp profile besides this - JW
access_key_id = IO.readlines("|cat ~/.aws/credentials | grep -A 6 temp | grep aws_access_key_id | cut -d = -f 2 | tr -d [:space:]")*","
secret_access_key = IO.readlines("|cat ~/.aws/credentials | grep -A 6 temp | grep aws_secret_access_key | cut -d = -f 2 | sed 's/[^a-zA-Z0-9/+]//g'|tr -d [:space:]")*","
session_token = IO.readlines("|cat ~/.aws/credentials | grep -A 6 temp | grep session_token | cut -d = -f 2 | sed 's/[^a-zA-Z0-9/+]//g'| tr -d [:space:]")*","
object_content = File.read(object_key)

s3_encryption_client = Aws::S3::EncryptionV2::Client.new(
    region: region,
    kms_key_id: kms_key_id,
    key_wrap_schema: :kms_context,
    content_encryption_schema: :aes_gcm_no_padding,
    security_profile: :'v2',
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token
   )

  s3_encryption_client.put_object(
    bucket: bucket_name,
    key: object_key,
    body: object_content
  )

  response = s3_encryption_client.get_object(
    bucket: bucket_name,
    key: object_key
  )

  puts response.body.read
