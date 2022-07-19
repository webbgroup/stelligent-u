# Topic 10: Key Management Service (KMS)

<!-- TOC -->

- [Topic 10: Key Management Service (KMS)](#topic-10-key-management-service-kms)
  - [Lesson 10.1: Introduction to KMS](#lesson-101-introduction-to-kms)
    - [Principle 10.1](#principle-101)
    - [Practice 10.1](#practice-101)
      - [Lab 10.1.1: Create a KMS CMK](#lab-1011-create-a-kms-cmk)
      - [Lab 10.1.2 : Create a KMS Alias](#lab-1012--create-a-kms-alias)
      - [Lab 10.1.3: Encrypt a text file with your KMS CMK](#lab-1013-encrypt-a-text-file-with-your-kms-cmk)
      - [Lab 10.1.4: Decrypt a ciphertext file](#lab-1014-decrypt-a-ciphertext-file)
    - [Retrospective 10.1](#retrospective-101)
      - [Question: Decrypting the Ciphertext File](#question-decrypting-the-ciphertext-file)
      - [Question: KMS Alias](#question-kms-alias)
  - [Lesson 10.2: Implementation of KMS Keys in S3](#lesson-102-implementation-of-kms-keys-in-s3)
    - [Principle 10.2](#principle-102)
    - [Practice 10.2](#practice-102)
      - [Lab 10.2.1: Client Side Encryption of S3 Object](#lab-1021-client-side-encryption-of-s3-object)
      - [Lab 10.2.2: Delete your CMK](#lab-1022-delete-your-cmk)
        - [Question: CMK](#question-cmk)
    - [Retrospective 10.2](#retrospective-102)

<!-- /TOC -->

## Lesson 10.1: Introduction to KMS

### Principle 10.1

*AWS Key Management Service (AWS KMS) is a managed service that makes it
easy for you to create and control the encryption keys used to encrypt
your data.*

### Practice 10.1

Rather than storing the encryption keys ourselves, Amazon securely
stores them and provides the ability to disperse and use keys to others
via IAM. The following labs will introduce you to the fundamental resources in
KMS: KMS Customer Master Keys (CMKs) and KMS Aliases.

#### Lab 10.1.1: Create a KMS CMK

Create a CFN Template that
[creates a CMK key in KMS](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-kms-key.html):

- For a key policy, set your IAM user as Key Administrator and as a Key User

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ aws cloudformation --profile temp create-stack --stack-name Joels10 --template-body file://cfn-kms-10-1-1.yaml --capabilities CAPABILITY_NAMED_IAM
{
    "StackId": "arn:aws:cloudformation:us-east-1:324320755747:stack/Joels10/04d42690-06d0-11ed-a490-0af0396780d5"
}
```

#### Lab 10.1.2 : Create a KMS Alias

Update your CFN template to add a KMS Alias with a snazzy name.
Associate your CMK with this alias.

#### Lab 10.1.3: Encrypt a text file with your KMS CMK

Use the AWS KMS CLI to encrypt a plaintext file with a secret message
(maybe that combo to the safe, or your luggage password). Send your file
to a colleague with administrator access.

https://docs.aws.amazon.com/cli/latest/reference/kms/encrypt.html


```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ cat /tmp/EncryptedSampaws kms encrypt --key-id alias/JoelsModule10Key --profile temp --plaintext fileb:///tmp/sample9-1-3.yaml --output text --query CiphertextBlob | base64 --decode > /tmp/EncryptedSampleFile.txt
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ cat /tmp/EncryptedSampleFile.txt
x������u+a
          I���O���Gv��4db����_���t�Ңo�ƫ@�
60�
��  *�H��
#0�
0�
0 `�He.0
              NZV�Ay���K|�� ��  �������@��܎&z#�ۂ}l/����&����{�X�ǆ��W�k
                                                                             ܋+I��d���:=?%c�;a�:���9%fC����l�R��g႐I2���MR�m�eY��c�>-0$�I&?ݜVz��'�C����������K���Ęt��蠱x�/��)���}�(��
(�f�`�/�Fd4�����O�8�,��������&�8�?1���G�Y��]�`3B~ru�b�5U�%����T����M� "^���>[᠉���ޟ�&���݃�~�!ݹ�"��5�vw�tJO�_�8̎ l�5�_�TA�A���m/���H�5ͦHvC��,�J����N�I<�P�_�����\V\F�������.��r�l���r��Qó�|s�:;6;����gN
oj�0S��R�`�6d����̶�6�͡!c������)"���u1�HSm�]Xl���8��mJ)s�HN�x�0�1�<k1�G��(�S�\�m����������$I��؀�exGM2h<-����,�����t��KRG�M�z�5��3K��h��F��n�ɀ����ڜ���n�q�o�
���}߽߳k6C$���0���dU*�V��>���Nt��?�N|ZHMOGV2w[�
                                            ܔQ_#�D4�$��t����Y�Ш/��[)�}`���<�m6�0l)�@qj}��ܻX��/� W��"�P��]'���J'�LK    �E%|;��ߠS��6N'.\��<���&.���0Տ�v�\��N(��t��9��*D��k|ò�Q`2A�����h~�p`죚e��'�`b��,~�'�qTC!����4���X!��s'5�O7��%BWx[��:j��\���r����4Y@P�z��s�&�uK��YQ��Y�Yi���Q�
�8g*���z��#q��mF�d�z0]���x�c�_\nG�����-�;�Nx?$��'�N��~I����)7�������b�ľ򯆎B�H��l�V^���<8D+B��Ad��3�$��'�y�h��>���3����8�n{�V"�)�Zr�p������~!���.>R��%�()�ޖ�(���E{��8,j���.�ٳ�g��mmа�:�ʏ�Ǔ��"�uoD��K�hN���Ԍ4c;h���kj
                  w6�F;ߣV�!�  X��\����CNh����褬E^����Xs����*���Qt���2�F8$Tӝ���4�r-��o%�f[�I.T
                                                                                               �#��{D�ȶ��ګ��
�3�����sd x
�A*egM��۸��i�6�&�3��Ȭ��M�{0lD�X
{Vs���%!��Y�RF:�����ކ�?sl,�g9�  ��n��ӮjR��W
�P����1�R�`�����9������eK��M��W�4u-Q]���~��ߵ]6�B
L��kC"��%�S��h��
�:u�����*��R���N��lT2�5��V-�dI�Fȓ�|9������{9X.d�֓�8�^
                                                    ���&����Kԇ^e* =z�ɋ]������E��]g0v��8�O��
1Ww�0Dy��d�kI̞�'��_?c������S�>�ne�m�E~Z�>��U���a�(NU�.�,+��O����8������B9�
<a�W���-{xm�s��w���r@�^ ��es8�5)Mk}pL�UϋC��NO)Q*eϽ)���  �Qa�Ɔ�����;E��?f��=�Զ�1��v&e���b��^x����q����F�DP��E�:�"��� n�Q`�?���u���z����1f[p�;��Gzs��9J�y���lx�l���Fqg�/�ƅ�����ρt�变S�k�W�6�'iѼ���-���ʅ�2��-:SSw���x���^Yg��Ŕ�
M�if�{�Pa�~=��#-�H�V���o�{����x�Q}��t��;���.]h<�ԓ�6����2o�OY�f2r'�R��@P�,0��G9v�bA���*/������1�M�Mq��腱*�:�A`7ev�4"�e$��&dkzA[g��[
                                                                                                                                  ��q�E��i���@�o�qh�����oI�?<!��
�&�l"�xs�N[��<9�hF,��O)�����3g��_d6
                                   V�.?�l�(�I�È��>������*>�(槎�?p����ʹ�4�#�$CBG�
```

#### Lab 10.1.4: Decrypt a ciphertext file

I did the encryption incorrect.. updated with the correct syntax above

Use the KMS CLI to now decrypt a ciphertext file.

https://docs.aws.amazon.com/cli/latest/reference/kms/decrypt.html

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ aws kms decrypt --key-id alias/JoelsModule10Key --profile temp --ciphertext-blob fileb:///tmp/EncryptedSampleFile.txt --output text --query Plaintext | base64 --decode > /tmp/DecryptedSampleFile.txt
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ cat /tmp/DecryptedSampleFile.txt
---
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  MyLambda:
    Type: AWS::Lambda::Function
    Properties:
      Handler: lambda.lambda_handler
      Code: lambda/
      Role: !GetAtt MyLambdaExecutionRole.Arn
      Runtime: python3.9
```

### Retrospective 10.1

#### Question: Decrypting the Ciphertext File

_For decrypting the ciphertext file, why didn't you have to specify a key? How
did you have permission to decrypt?_

I had to specify a key though in the original step... but checking, this is correct. I don't have to provide the key in order to decrypt it.

I am assuming that the AWS script is validating that I have access to the key itself hidden within the blob BEFORE decryption

```
-joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ aws kms encrypt --key-id alias/JoelsModule10Key  --profile temp --plaintext fileb:///tmp/sample9-1-3.yaml > /tmp/EncryptedFile.txt
-joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ cat /tmp/EncryptedFile.txt
-{
-    "CiphertextBlob": "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",
-    "KeyId": "arn:aws:kms:us-east-1:324320755747:key/6ff84455-5648-47f2-aa41-5c06d0bdcf5a",
-    "EncryptionAlgorithm": "SYMMETRIC_DEFAULT"
-}

```

#### Question: KMS Alias

_Why is it beneficial to use a KMS Alias?_

So it is easier for handoffs to other people and human readability for yourself.

## Lesson 10.2: Implementation of KMS Keys in S3

### Principle 10.2

For AWS S3, you've seen in a previous lab about setting a KMS key to be
used with Server Side Encryption. Additionally, a KMS key can be used
for client side encryption of S3 assets. Client side encryption adds an
extra layer of security by encrypting information before transmission to
S3.

### Practice 10.2

Amazon has integrated KMS into many of their services (check out the
full list:
[https://docs.aws.amazon.com/kms/latest/developerguide/service-integration.html](https://docs.aws.amazon.com/kms/latest/developerguide/service-integration.html)
). In the following labs, we'll take your existing CMK and begin using
them for a practical purposes: client side encryption of S3 objects.

Ruby SDK for Encryption client:
[https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/EncryptionV2/Client.html](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/EncryptionV2/Client.html)

#### Lab 10.2.1: Client Side Encryption of S3 Object


Researched it here:
https://www.rubydoc.info/gems/aws-sdk-v1/1.66.0

Installed it:
```
sudo apt-get install ruby-aws-sdk
```

Use the ruby-sdk to create a script that will:

- Encrypt a local plaintext file and upload to S3

- Read back the encrypted ciphertext from the uploaded file

- Pull down and decrypt the file, saving as another name.

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ ruby encrypt-decrypt-file.rb
The Password is Password
```

```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ ruby encrypt-decrypt-file.rb
The Password is Password
```

Validation
```
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ aws s3 cp s3://joels-encryption-bucket/secret.txt /tmp/ --profile temp
download: s3://joels-encryption-bucket/secret.txt to ../../../../../../tmp/secret.txt
joel@joels-desktop:~/Documents/Stelligent/stelligent-u/10-kms$ cat /tmp/secret.txt
d��Ha����ղ�
           ����u
                �F�P�=0*��4�CN�M
```

#### Lab 10.2.2: Delete your CMK

Delete your KMS CFN Stack.

##### Question: CMK

_What happened to your CMK? Why?_

### Retrospective 10.2

Check out the code for [stelligent/crossing](https://github.com/stelligent/crossing)
and [stelligent/keystore](https://github.com/stelligent/keystore)
on GitHub for tools that simplify using KMS encrypted resources.
