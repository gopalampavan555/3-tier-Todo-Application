# 3-tier-app

# Prerequisite 

**Install Kubectl**
https://kubernetes.io/docs/tasks/tools/


**Install Helm**
https://helm.sh/docs/intro/install/

```
helm repo update
```

**Install/update latest AWS CLI:** (make sure install v2 only)
https://aws.amazon.com/cli/


#update the Kubernetes context
aws eks update-kubeconfig --name my-eks-cluster --region us-west-2

# verify access:
```
kubectl auth can-i "*" "*"
kubectl get nodes
```

# Verify autoscaler running:
```
kubectl get pods -n kube-system
```

# Check Autoscaler logs
```
kubectl logs -f \
  -n kube-system \
  -l app=cluster-autoscaler
```

# Check load balancer logs
```
kubectl logs -f -n kube-system \
  -l app.kubernetes.io/name=aws-load-balancer-controller
```

<!-- aws eks update-kubeconfig \
  --name my-eks \
  --region us-west-2 \
  --profile eks-admin -->

**For Linux/Windows:**

Buid Front End :

```
docker build -t frontend:latest . 
docker tag frontend:latest public.ecr.aws/w0r5j4b6/frontend:latest
docker push public.ecr.aws/w0r5j4b6/frontend:latest
```


Buid Back End :

```
docker build -t backend:latest . 
docker tag backend:latest public.ecr.aws/w0r5j4b6/backend:latest
docker push public.ecr.aws/w0r5j4b6/backend:latest
```

**Update Kubeconfig**
Syntax: aws eks update-kubeconfig --region region-code --name your-cluster-name
```
aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster
```



**Create Namespace**
```
kubectl create ns workshop

kubectl config set-context --current --namespace workshop
```

# MongoDB Database Setup

**To create MongoDB Resources**
```
cd k8s_manifests/mongo_v1
kubectl apply -f secrets.yaml
kubectl apply -f deploy.yaml
kubectl apply -f service.yaml
```

# Backend API Setup

Create NodeJs API deployment by running the following command:
```
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
```


**Frontend setup**

Create the Frontend  resource. In the terminal run the following command:
```
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
```

Finally create the final load balancer to allow internet traffic:
```
kubectl apply -f full_stack_lb.yaml
```

**Setup ALB controller for cluster**
```
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl utils associate-iam-oidc-provider --region=us-west-2 --cluster=three-tier-cluster --approve
eksctl create iamserviceaccount --cluster=three-tier-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::<give you aws account number>:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-west-2
sudo snap install helm --classic
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl apply -f full_stack_lb.yaml
```

# Any issue with the pods ? check logs:
```
kubectl describe pod <podname> -n <namespace>
kubectl logs <podname> <contaniername> -n <namespace>
kubectl exec -it mongodb-7f58c5f5d9-bv9r5 -- /bin/bash
```


# Prometheus and grafana setup 

```
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create namespace prometheus
helm install stable prometheus-community/kube-prometheus-stack -n prometheus
kubectl get pods -n prometheus
kubectl get svc -n prometheus
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
kubectl get svc -n prometheus
kubectl get pods -n prometheus
kubectl edit svc stable-grafana -n prometheus
kubectl get svc -n prometheus
kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

# Destroy Kubernetes resources and cluster
```
cd ./k8s_manifests
kubectl delete -f -f
```

**Remove AWS Resources to stop billing**
```
eksctl delete cluster --name three-tier-cluster --region us-west-2
```


