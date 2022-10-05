aws ec2 terminate-instances --instance-ids i-0e661b2f484ddfcd6
sleep 59
aws ec2 delete-security-group --group-id sg-0b9ee33b482204c7b
aws ec2 delete-subnet --subnet-id subnet-09a949cff7fc73732
aws ec2 delete-route-table --route-table-id rtb-0e04fd16ca4b30c96
aws ec2 detach-internet-gateway --internet-gateway-id igw-0da32139aea3e35eb --vpc-id vpc-0ce1b64a9d510582e
aws ec2 delete-internet-gateway --internet-gateway-id igw-0da32139aea3e35eb
aws ec2 delete-vpc --vpc-id vpc-0ce1b64a9d510582e
aws ec2 delete-key-pair --key-name MyKeyPair
rm -rf MyKeyPair.pem


