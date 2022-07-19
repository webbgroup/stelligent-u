require 'aws-sdk-s3'
 
# Uploads an object to a bucket in Amazon Simple Storage Service (Amazon S3).
#
# Prerequisites:
#
# - An S3 bucket.
# - An object to upload to the bucket.
#
# @param s3_client [Aws::S3::Client] An initialized S3 client.
# @param bucket_name [String] The name of the bucket.
# @param object_key [String] The name of the object.
# @return [Boolean] true if the object was uploaded; otherwise, false.
# @example
#   exit 1 unless object_uploaded?(
#     Aws::S3::Client.new(region: 'us-east-1'),
#     'doc-example-bucket',
#     'my-file.txt'
#   )
def object_uploaded?(s3_client, bucket_name, object_key)
  response = s3_client.put_object(
    bucket: 'joels-encryption-bucket',
    key: '6ff84455-5648-47f2-aa41-5c06d0bdcf5a'
  )
  if response.etag
    return true
  else
    return false
  end
rescue StandardError => e
  puts "Error uploading object: #{e.message}"
  return false
end

# Full example call:
def run_me
  bucket_name = 'joels-encryption-bucket'
  object_key = 'secret.txt'
  region = 'us-east-1'
  s3_client = Aws::S3::Client.new(region: region)

  if object_uploaded?(s3_client, bucket_name, object_key)
    puts "Object '#{object_key}' uploaded to bucket '#{bucket_name}'."
  else
    puts "Object '#{object_key}' not uploaded to bucket '#{bucket_name}'."
  end
end

run_me if $PROGRAM_NAME == __FILE__