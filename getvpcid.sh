##### CREATE VPC, Store in a variable and then Applying tag to VPC #####

a=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query Vpc.VpcId)
vpcid=$(echo "$a" | tr -d '"')
echo $vpcid
aws ec2 create-tags --resources $vpcid --tags Key=Name,Value=myvpc1

####### CREATE SUBNET one Public and Private ########################

b=$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block 10.0.1.0/24 --query Subnet.SubnetId)
subnet1=$(echo "$b" | tr -d '""')
echo $subnet1
aws ec2 create-tags --resources $subnet1 --tags Key=Name,Value=subnetpublic

####### CREATE Internet Gateway to access public IP ########################

d=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId)
igw=$(echo "$d" | tr -d '"')
echo $igw
aws ec2 create-tags --resources $igw --tags Key=Name,Value=myigw

## Update/Attach the internet-gateway-id and vpc-id #####################

aws ec2 attach-internet-gateway --vpc-id $vpcid --internet-gateway-id $igw 

## Create a custom route table for routing the traffic to public ##########

e=$(aws ec2 create-route-table --vpc-id $vpcid --query RouteTable.RouteTableId)
rt=$(echo "$e" | tr -d '""')
echo $rt
aws ec2 create-tags --resources $rt --tags Key=Name,Value=myrt

## Update the Route Table and Internet-gateway-id #####################

aws ec2 create-route --route-table-id $rt --destination-cidr-block 0.0.0.0/0 --gateway-id $igw

## Associate subnet with custom route table to make public
aws ec2 associate-route-table  --subnet-id $subnet1 --route-table-id $rt
aws ec2 modify-subnet-attribute --subnet-id $subnet1 --map-public-ip-on-launch

aws ec2 describe-route-tables--route-table $rt

##### LAUNCH INSTANCE INTO SUBNET FOR TESTING #####

## Create security group with rule to allow SSH

sg=$(aws ec2 create-security-group --group-name test_group --description "Security group for demo" --vpc-id $vpcid | grep "GroupId" | awk '{ print $2 }' | sed 's/"//g' | sed 's/,//g')
echo $sg

## Copy security group ID from output
## Update group-id in the command below:

aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 22 --cidr 0.0.0.0/0

## Create a key pair and output to MyKeyPair.pem
## Modify output path accordingly

# Creating key pair
sudo aws ec2 create-key-pair --key-name keypair1 --output text --query "KeyMaterial" > ./keypair1.pem

# Changing the permission to read only
sudo chmod 400 keypair1.pem

## Launch instance in public subnet using security group and key pair created previously:
## Obtain the AMI ID from the console, update the security-group-ids and subnet-ids

insid=$(aws ec2 run-instances --image-id ami-026b57f3c383c2eec --count 1 --instance-type t2.micro --key-name keypair1 --security-group-ids $sg --subnet-id $subnet1 | grep "InstanceId" | awk '{ print $2 }' | sed 's/"//g' | sed 's/,//g')

echo $insid 

## Copy instance ID from output and use in the command below
## Check instance is in running state:

aws ec2 describe-instances --instance-id $insid




