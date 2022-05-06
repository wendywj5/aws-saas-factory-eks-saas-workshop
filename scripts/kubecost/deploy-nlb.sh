#!/bin/bash

#Create Target Group
export VPCID=$(aws elbv2 describe-load-balancers | jq '.LoadBalancers[] | 
       select(.DNSName == "a4cdc0a1a53dc43419e2ab3905c07831-59bd241df40feef9.elb.us-east-2.amazonaws.com") | 
       .VpcId' | sed 's/\"//g')
       
export TGARN=$(aws elbv2 create-target-group \
    --name kubecost-targets \
    --protocol TCP \
    --port 30580 \
    --target-type instance \
    --vpc-id $VPCID \
    --health-check-port 32113 \
    --health-check-path "/healthz" \
    --health-check-protocol HTTP \
    --matcher HttpCode="200-399" \
    --unhealthy-threshold-count 2 \
    --healthy-threshold-count 2 | jq '.TargetGroups[] | .TargetGroupArn' | sed 's/\"//g')

#Register Targets
export EKSELBARN=$(aws elbv2 describe-load-balancers | jq --arg elburl "$ELBURL" '.LoadBalancers[] | 
       select(.DNSName == $elburl) | 
       .LoadBalancerArn' | sed 's/\"//g')
       
export TG=$(aws elbv2  describe-listeners --load-balancer-arn $EKSELBARN |  jq '.Listeners[] |
       select(.Port == 80) |
       .DefaultActions[].TargetGroupArn' | sed 's/\"//g')

export ID=$(aws elbv2 describe-target-health --target-group-arn $TG | jq '.TargetHealthDescriptions[] | 
       .Target.Id' | sed 's/\"//g')

for i in $ID
do  
 aws elbv2 register-targets \
    --target-group-arn $TGARN \
    --targets Id=$i,Port=30580
done

#Create NLB
export SUBNETS=$(aws elbv2 describe-load-balancers --load-balancer-arn $EKSELBARN | jq '.LoadBalancers[].AvailabilityZones[] |
        .SubnetId' | sed 's/\"//g')

export ELBARN_KBC=$(aws elbv2 create-load-balancer --name kubecost-network-load-balancer --type network --subnets $SUBNETS | 
        jq '.LoadBalancers[] | .LoadBalancerArn' | sed 's/\"//g')

#Create Listener
aws elbv2 create-listener \
    --load-balancer-arn $ELBARN_KBC \
    --protocol TCP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TGARN
    
export ELBKBC_URL=$(aws elbv2 create-load-balancer --name kubecost-network-load-balancer --type network --subnets $SUBNETS | 
        jq '.LoadBalancers[]  | .DNSName' | sed 's/\"//g')