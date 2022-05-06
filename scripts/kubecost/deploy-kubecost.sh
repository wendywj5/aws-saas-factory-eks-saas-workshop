#!/bin/bash
: "${KUBECOST_TOKEN:=$1}"

#USAGE_PROMPT="Use: $0 <STACKNAME> <DOMAINNAME>\n
#Example: $0 test-stack mydomain.com"


if [[ -z ${KUBECOST_TOKEN} ]]; then
  echo "Kubecost Token was not provided."
  echo -e $USAGE_PROMPT
  exit 2
fi

#EKS_REF_ROOT_DIR=$(pwd)
export AWS_DEFAULT_REGION=$AWS_REGION

echo "Installing helm"
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo "Install Helm Kubecost"
cd scripts/kubecost
source ./deploy-nlb.sh
kubectl create namespace kubecost
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="$KUBECOSTTOKEN"
sed -i 's,ELB_URL,'$ELBKBC_URL',g' kubecost-ingress-config.yaml
kubectl apply -f kubecost-ingress-config.yaml -n kubecost
echo "Provide Kubecost Password"
htpasswd -c auth kubecost-admin
kubectl create secret generic kubecost-auth --from-file auth -n kubecost

#Sleep - to wait alb ready
sleep 180

echo "Kubecost deployment complete!!"