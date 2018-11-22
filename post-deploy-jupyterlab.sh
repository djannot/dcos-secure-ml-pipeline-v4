base64 trust-ca.jks > trust-ca.jks.base64
base64 trust.jks > trust.jks.base64
base64 server.jks > server.jks.base64
task=`dcos task | grep jupyterlab | awk '{ print $5 }'`
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/trust-ca.jks.base64' < ./trust-ca.jks.base64
dcos task exec -i $task sh -c 'base64 --decode /mnt/mesos/sandbox/trust-ca.jks.base64 > /mnt/mesos/sandbox/trust-ca.jks' < /dev/null
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/trust.jks.base64' < ./trust.jks.base64
dcos task exec -i $task sh -c 'base64 --decode /mnt/mesos/sandbox/trust.jks.base64 > /mnt/mesos/sandbox/trust.jks' < /dev/null
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/server.jks.base64' < ./server.jks.base64
dcos task exec -i $task sh -c 'base64 --decode /mnt/mesos/sandbox/server.jks.base64 > /mnt/mesos/sandbox/server.jks' < /dev/null
#dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/JAAS_ARTIFACT.conf' < ./JAAS_ARTIFACT.conf
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/merged.keytab.base64' < ./merged.keytab.base64
dcos task exec -i $task sh -c 'base64 --decode /mnt/mesos/sandbox/merged.keytab.base64 > /mnt/mesos/sandbox/merged.keytab' < /dev/null
dcos task exec -i $task sh -c '/opt/conda/bin/kinit -kt /mnt/mesos/sandbox/merged.keytab hdfs/name-0-node.hdfs.autoip.dcos.thisdcos.directory@MESOS.LAB' < /dev/null
dcos task exec -i $task sh -c 'JAVA_HOME=/opt/jdk /opt/hadoop/bin/hdfs dfs -mkdir -p /user/client' < /dev/null
dcos task exec -i $task sh -c 'JAVA_HOME=/opt/jdk /opt/hadoop/bin/hdfs dfs -chown client /user/client' < /dev/null
dcos task exec -i $task sh -c 'JAVA_HOME=/opt/jdk /opt/hadoop/bin/hdfs dfs -mkdir -p /user/nobody' < /dev/null
dcos task exec -i $task sh -c 'JAVA_HOME=/opt/jdk /opt/hadoop/bin/hdfs dfs -chown client /user/nobody' < /dev/null
dcos task exec -i $task sh -c '/opt/conda/bin/kinit -kt /mnt/mesos/sandbox/merged.keytab client@MESOS.LAB' < /dev/null
dcos task exec -i $task sh -c '/opt/mesosphere/bin/dcos cluster setup --no-check https://master.mesos --username=user1 --password=password' < /dev/null
dcos task exec -i $task sh -c '/opt/mesosphere/bin/dcos package install --yes --cli dcos-enterprise-cli' < /dev/null
dcos task exec -i $task sh -c 'LC_ALL=C.UTF-8 LANG=C.UTF-8 /opt/mesosphere/bin/dcos security secrets delete /dev/jupyterlab/tgt' < /dev/null
dcos task exec -i $task sh -c 'LC_ALL=C.UTF-8 LANG=C.UTF-8 /opt/mesosphere/bin/dcos security secrets create -f /tmp/krb5cc_$(id -u) /dev/jupyterlab/tgt' < /dev/null
dcos task exec -i $task sh -c 'cp /tmp/krb5cc_$(id -u) /mnt/mesos/sandbox/tgt' < /dev/null
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/dcos-secure-ml-pipeline.ipynb' < ./dcos-secure-ml-pipeline.ipynb
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/TwitterSentimentAnalysisCreateModel.ipynb' < ./TwitterSentimentAnalysisCreateModel.ipynb
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/TwitterSentimentAnalysisApplyModel.ipynb' < ./TwitterSentimentAnalysisApplyModel.ipynb
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/.ipython/extensions/dcos-magic.py' < ./dcos-magic.py
dcos task exec -i $task sh -c "echo c.InteractiveShellApp.extensions = [\'dcos-magic\'] >> /mnt/mesos/sandbox/.ipython/profile_default/ipython_config.py"
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model'
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Dockerfile' < ./serve-model/Dockerfile
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.py' < ./serve-model/serve-model.py
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/serve-model.yaml' < ./serve-model/serve-model.yaml
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/Jenkinsfile' < ./serve-model/Jenkinsfile
dcos task exec -i $task sh -c 'mkdir /mnt/mesos/sandbox/serve-model/templates'
dcos task exec -i $task sh -c 'cat > /mnt/mesos/sandbox/serve-model/templates/response.html' < ./serve-model/templates/response.html
