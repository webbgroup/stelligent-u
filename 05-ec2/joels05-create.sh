#/bin/bash

#Defaults
linuxAMI='ami-0cff7528ff583bf9a'
windowsAMI='ami-09e13647920b2ba1d'

while getopts "h:l:w" arg; do
  case $arg in
    h)
      echo "joels05-create.sh -l linuxAMI -w windowsAMI"
      ;;
    l)
      linuxAMI=$OPTARG
      echo $linuxAMI
      ;;
    w)
      windowsAMI=$OPTARG
      echo $windowsAMI
      ;;
  esac
done

echo "LinuxAMI is $linuxAMI and WindowsAMI is $windowsAMI"

cat cfn-ec2instance.template.json | sed s/LINUXAMI/$linuxAMI/g | sed s/WINDOWSAMI/$windowsAMI/g > cfn-ec2instance.json

#run the command
aws cloudformation --profile temp create-stack --stack-name Joels05 --template-body file://cfn-ec2-elastic.yaml --parameters file://cfn-ec2instance.json

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

