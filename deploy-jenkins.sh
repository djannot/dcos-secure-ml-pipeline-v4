# Create the jenkins service account
dcos security org service-accounts keypair private-jenkins.pem public-jenkins.pem
dcos security org service-accounts delete jenkins
dcos security org service-accounts create -p public-jenkins.pem -d jenkins jenkins
dcos security secrets delete /jenkins/private-jenkins
dcos security secrets create-sa-secret --strict private-jenkins.pem jenkins /jenkins/private-jenkins
dcos security org users grant jenkins dcos:mesos:master:framework:role:* create
dcos security org users grant jenkins dcos:mesos:master:task:user:nobody create

# Deploy jenkins
dcos package install --yes jenkins --options=options-jenkins.json --package-version=3.5.2-2.107.2
./check-app-status.sh jenkins
