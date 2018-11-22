dcos security org users create -p password user1
dcos security org users grant user1 dcos:adminrouter:package full
dcos security org users grant user1 dcos:secrets:default:/dev/jupyterlab/tgt full
dcos security org users grant user1 dcos:adminrouter:ops:historyservice full
dcos security org service-accounts keypair jupyterlab-private-key.pem jupyterlab-public-key.pem
dcos security org service-accounts create -p jupyterlab-public-key.pem -d "Jupyterlab Service Account" dev_jupyterlab
dcos security secrets create-sa-secret --strict jupyterlab-private-key.pem dev_jupyterlab dev/jupyterlab/serviceCredential
dcos security org users grant dev_jupyterlab dcos:mesos:master:task:user:nobody create --description "Allow dev_jupyterlab to launch tasks under the Linux user: nobody"
dcos security org users grant dev_jupyterlab dcos:mesos:master:framework:role:dev-jupyterlab create --description "Allow dev_jupyterlab to register with Mesos and consume resources from the dev-jupyterlab role"
dcos security org users grant dev_jupyterlab dcos:mesos:master:task:app_id:/dev/jupyterlab create --description "Allow dev_jupyterlab to create tasks under the /dev/jupyterlab namespace"
#dcos package install --yes jupyterlab --options=options-jupyterlab.json
dcos marathon app add marathon-jupyterlab.json
./check-app-status.sh jupyterlab
