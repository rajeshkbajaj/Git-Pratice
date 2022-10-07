##### CREATE VPC #####

VpcId=$(aws ec2 create-vpc --cidr-block 10.10.0.0/16 | grep VpcId | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $VpcId

## Create a Subnet from below command:

Subnet1=$(aws ec2 create-subnet --vpc-id $VpcId --cidr-block 10.0.1.0/24 | grep SubnetId | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $Subnet1

Subnet2=$(aws ec2 create-subnet --vpc-id $VpcId --cidr-block 10.0.0.0/24 | grep SubnetId | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $Subnet2

## Create a Internet Gateway from below command:
IntGW=$(aws ec2 create-internet-gateway | grep InternetGatewayId | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $IntGW

# Attaching the internet gateway with the VPC created before
aws ec2 attach-internet-gateway --vpc-id $VpcId --internet-gateway-id $IntGW

# Create Route table from below command and amd associate it with CIDR Block with IGW
RouTab=$(aws ec2 create-route-table --vpc-id $VpcId | grep RouteTableId | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $RouTab

a=$(aws ec2 create-route --route-table-id $RouTab --destination-cidr-block 0.0.0.0/0 --gateway-id $IntGW)

# Attaching the route table with the subnet 1
b=$(aws ec2 associate-route-table --subnet-id $Subnet1 --route-table-id $RouTab)

# Attaching the route table with the subnet 2
b=$(aws ec2 associate-route-table --subnet-id $Subnet2 --route-table-id $RouTab)

# Code to map a public IP to the instance on launch
c=$(aws ec2 modify-subnet-attribute --subnet-id $Subnet1 --map-public-ip-on-launch)

# Creating Security Group
SecGroup=$(aws ec2 create-security-group --group-name test_group --description "Security group for demo" --vpc-id $VpcId | grep GroupId | awk '{print $2}'| sed 's/"//g')
echo $SecGroup
aws ec2 authorize-security-group-ingress --group-id $SecGroup --protocol tcp --port 22 --cidr 0.0.0.0/0

aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > ./MyKeyPair.pem
chmod 400 MyKeyPair.pem

## Launch instance in public subnet using security group and key pair created previously:
InsId=$(aws ec2 run-instances --image-id ami-08c40ec9ead489470 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids $SecGroup --subnet-id $Subnet1 | grep InstanceId | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')

echo $InsId
aws ec2 create-tags --resources $InsId --tags Key=Name,Value=MyInstance
aws ec2 wait instance-running \
    --instance-ids $InsId

PublicIP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=MyInstance" | grep PublicIpAddress | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $PublicIP

aws cloudwatch put-metric-alarm --alarm-name cpu-mon --alarm-description "Test Alarm when CPU exceeds 70 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 70 --comparison-operator GreaterThanThreshold  --dimensions "Name=MyInstance,Value=$InsId" --evaluation-periods 2 --alarm-actions arn:aws:sns:us-east-1:247434585159:Default_CloudWatch_Alarms_Topic1 --unit Percent

AState=$(aws cloudwatch describe-alarms --alarm-names cpu-mon | grep StateValue | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $AState
sleep 2

aws cloudwatch set-alarm-state --alarm-name cpu-mon --state-reason "initializing" --state-value ALARM
sleep 2

BState=$(aws cloudwatch describe-alarms --alarm-names cpu-mon | grep StateValue | awk '{print $2}'| sed 's/"//g' | sed 's/,//g')
echo $BState

if [ "$BState" = "ALARM" ]; then    
         echo "I am stopping the instance now"
         aws ec2 stop-instances --instance-ids $InsId
         echo "Instance has been stopped successfully"
     else
         echo "Instance has no Alarm"
fi
    
#####creating an ELB
    
ELBID=$(aws elb create-load-balancer --load-balancer-name my-load-balancer --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --subnets $Subnet1 --security-groups $SecGroup | grep DNSName | awk '{print $2}' | sed 's/"//g' | sed 's/{}{}//g')
echo $ELBID

######creating an launch config using EC2 Instance:

LanConfig=$(aws autoscaling create-launch-configuration --launch-configuration-name my-lc-from-instance --instance-id $InsId)

######creating an launch config using EC2 Instance:

aws autoscaling create-auto-scaling-group --auto-scaling-group-name my-asg --availability-zones us-east-1c --launch-configuration-name my-lc-from-instance --load-balancer-names my-load-balancer --min-size 1 --max-size 2 --vpc-zone-identifier "$Subnet1"
     
echo "Ec2 Instance Demo Finished"

