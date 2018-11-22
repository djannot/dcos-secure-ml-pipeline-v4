rm  ~/.kube/config

export PUBLICNODEIP=$(./findpublic_ips.sh | head -1 | sed "s/.$//" )
dcos kubernetes cluster kubeconfig --context-name=kubernetes-cluster1 --cluster-name=kubernetes-cluster1 \
    --apiserver-url https://$PUBLICNODEIP:6443 \
    --insecure-skip-tls-verify

kubectl create -f kubernetes-traefik.yaml

kubectl create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
EOF

kubectl create -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-secret
  annotations:
    kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
EOF

kubectl create rolebinding jenkins \
  --clusterrole=cluster-admin \
  --serviceaccount=default:jenkins \
  --namespace=default

kubectl describe secrets/jenkins-secret
