require 'aws-sdk-s3'

kms_client = Aws::KMS::Client.new(region: 'us-east-1')

keyId = 'alias/{your key alias here}'
upload_object_key = 'cipertext-10.2.1.hex'
plaintext_filename = 'plaintext-10.2.1.txt'
text = File.read(plaintext_filename) 

# Encrypt a local plaintext file
resp = kms_client.encrypt({
  key_id: keyId,
  plaintext: text,
})

hex = resp.ciphertext_blob.unpack('H*') 
puts 'hex encoded ciphertext blob:'
puts hex

f = File.open(upload_object_key, 'w')
f.puts hex
f.close