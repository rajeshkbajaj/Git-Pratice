#!/bin/bash 
 
set -e  # set -e stops the execution of a script if a command or pipeline has an error
 
id=$1   # Provide the instance ID with the name of the script
 
# Checking if Instance ID provided is correct 
 
function check_ec2_instance_id () {
     
    if echo "$1" | grep -E '^i-[a-zA-Z0-9]{8,}' > /dev/null; then
           echo "Correct Instance ID provided , thank you"
           return 0
    else
          echo "Opps !! Incorrect Instance ID provided !!"
          return 1
    fi
}
 
# Function to Start the instance 
 
function ec2_start_instance ()   {
     aws ec2 start-instances --instance-ids $1 
}
 
# Function to Stop the instance 
 
function ec2_stop_instance ()   {
     aws ec2 stop-instances --instance-ids $1 
}
 
# Function to Check the Status of the instance
 
function ec2_check_status ()   {
     aws ec2 describe-instances --instance-ids $1 --query "Reservations[].Instances[].State.Name" --output text
}
 
# Main Function 
 
function main ()  {
     check_ec2_instance_id $1                # First it checks the Instance ID
     echo " Instance ID provided is $1"  # Prints the message
     echo "Checking the status of $1"    # Prints the message
     ec2_check_status $1
                 # Checks the Status of Instance
    
     status=$(ec2_check_status $id)     # It stores the status of Instance
     if [ "$status" = "running" ]; then    
         echo "I am stopping the instance now"
         ec2_stop_instance $1
         echo "Instance has been stopped successfully"
     else
         echo "I am starting the instance now"
         ec2_start_instance $1
         echo "Instance has been Started successfully"
     fi
 
}
 
main $1  
