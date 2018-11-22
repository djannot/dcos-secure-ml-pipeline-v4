# Create the kubernetes-cluster1 service account
dcos security org service-accounts keypair private-kubernetes-cluster1.pem public-kubernetes-cluster1.pem
dcos security org service-accounts delete kubernetes-cluster1
dcos security org service-accounts create -p public-kubernetes-cluster1.pem -d kubernetes-cluster1 kubernetes-cluster1
dcos security secrets delete /kubernetes-cluster1/private-kubernetes-cluster1
dcos security secrets create-sa-secret --strict private-kubernetes-cluster1.pem kubernetes-cluster1 /kubernetes-cluster1/private-kubernetes-cluster1
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:framework:role:kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:task:user:root create
dcos security org users grant kubernetes-cluster1 dcos:mesos:agent:task:user:root create
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:reservation:role:kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:reservation:principal:kubernetes-cluster1 delete
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:volume:role:kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:volume:principal:kubernetes-cluster1 delete
dcos security org users grant kubernetes-cluster1 dcos:service:marathon:marathon:services:/ create
dcos security org users grant kubernetes-cluster1 dcos:service:marathon:marathon:services:/ delete
dcos security org users grant kubernetes-cluster1 dcos:secrets:default:/kubernetes-cluster1/* full
dcos security org users grant kubernetes-cluster1 dcos:secrets:list:default:/kubernetes-cluster1 read
dcos security org users grant kubernetes-cluster1 dcos:adminrouter:ops:ca:rw full
dcos security org users grant kubernetes-cluster1 dcos:adminrouter:ops:ca:ro full
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:framework:role:slave_public/kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:framework:role:slave_public/kubernetes-cluster1-role read
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:reservation:role:slave_public/kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:volume:role:slave_public/kubernetes-cluster1-role create
dcos security org users grant kubernetes-cluster1 dcos:mesos:master:framework:role:slave_public read
dcos security org users grant kubernetes-cluster1 dcos:mesos:agent:framework:role:slave_public read

# Deploy kubernetes-cluster1
dcos kubernetes cluster create --yes --options=options-kubernetes-cluster1.json
./check-kubernetes-cluster-status.sh kubernetes-cluster1
