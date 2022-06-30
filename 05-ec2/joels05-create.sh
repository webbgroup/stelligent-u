#/bin/bash

aws cloudformation --profile temp create-stack --stack-name Joels05 --template-body file://cfn-ec2-elastic.yaml


while true
do
checkStatus=`aws cloudformation describe-stacks --stack-name Joels05 --profile temp | grep StackStatus | cut -d : -f 2 | sed 's/[^a-zA-Z0-9/_+]//g'`
#echo $checkStatus
#echo "We Ran:\n aws cloudformation describe-stacks --stack-name Joels05 --profile temp | grep StackStatus | cut -d : -f 2 | sed 's/[^a-zA-Z0-9/_+]//g'"
if [ "$checkStatus" = "CREATE_COMPLETE" ]
then
	echo $checkStatus
	echo "Yay!!!"
	exit 0
fi

echo "Not Completed Yet. Sleeping 1 second"
sleep 1
done

