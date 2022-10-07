
###creating an AMI

####AMIId=$(aws ec2 create-image --instance-id i-04b49121a1493e38b --name "My AMI" --description "An AMI for my server" | grep ImageId | awk '{print $2}' | sed 's/"//g')
####echo $AMIId
    
#ssh -i "MyKeyPair.pem" ubuntu@$PublicIP -y

#sudo apt-get update
#exit
#sleep 20
#tausId=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=MyInstance" --query "Reservations[].Instances[].State.Name" | sed 's/"//g' | sed 's/[][]//g')
#echo $StausId
#if [ "$StausId" = "running" ]; then    
#         echo "I am stopping the instance now"
 #        aws ec2 stop-instances --instance-ids $InsId
  #       echo "Instance has been stopped successfully"
   #  else
    #     echo "I am starting the instance now"
     #    aws ec2 start-instances --instance-ids $InsId
      #   echo "Instance has been Started successfully"
     #fi   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
