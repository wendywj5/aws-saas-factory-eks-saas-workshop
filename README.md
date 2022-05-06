# SaaS Factory SaaS EKS Workshop

The code provided here is intended to accompany the SaaS Factory EKS Workshop. The workshop is a series of hands-on labs through which participants build up, step-by-step, a functioning multi-tenant EKS environment. This workshop explores key architectural strategies that are used to address the various key tenets of SaaS solutions including isolation, identity, data partitioning, routing, deployment, and operational considerations and specifically how these are realized in EKS. Once complete with this workshop, participants will have a better understanding of the EKS-flavor of multi-tenancy, and be better able to understand the EKS SaaS reference solution, also produced by the SaaS Factory team.

[Workshop Narrative Here](https://catalog.us-east-1.prod.workshops.aws/v2/workshops/e04c0885-830a-479b-844b-4c7af79697f8/en-US)

# Add Kubecost for tenant cost monitoring

Deploy Kubecost which provides a real-time cost visibility and insights for kubernetes projects.

To deploy kubecost, you need to provide [kubecost token](https://www.kubecost.com/install#show-instructions) when executing ./script/deploy-kubecost.sh
```bash
chmod +x ./script/deploy-kubecost.sh
chmod +x ./script/deploy-nlb.sh
./script/deploy-kubecost.sh <KUBECOSTTOKEN>
```
When the script finishes running, it outputs ELBKBC_URL to the screen. Access Kubecost by using this URL.