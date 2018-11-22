# http://s3.amazonaws.com/downloads.mesosphere.io/dcos-enterprise-aws-advanced/testing/1.11.1/strict/cloudformation/ee.single-master.cloudformation.json
# https://github.com/mesosphere/spark-build/blob/master/docs/walkthroughs/secure-ml-pipeline.md
# with many fixes
dcos package install --yes --cli dcos-enterprise-cli

# Download the DC/OS ca certificate, add it in a truststore and create a secret for it
curl -k -v $(dcos config show core.dcos_url)/ca/dcos-ca.crt -o dcos-ca.crt
openssl x509 -in dcos-ca.crt -inform pem -out dcos-ca.der -outform der
rm -f trust-ca.jks
keytool -importcert -alias startssl -keystore trust-ca.jks -storepass changeit -file dcos-ca.der -noprompt
dcos security secrets create /truststore-ca --file trust-ca.jks

dcos security org users grant dcos_marathon dcos:mesos:master:task:user:root create

# Deploy a kdc on Marathon. In a real world environment, we would probably use an existing AD
dcos marathon app add kdc.json
sleep 30
./check-app-status.sh kdc

# Create all the Kerberos principals needed for HDFS, Kafka, ...
./create-principals.sh

# Create a keytab for them
./create-keytabs.sh
./merge-keytabs-1.12.sh

# Create the secret for the keytab file
dcos security secrets create keytab --file merged.keytab

# Create the hdfs service account
dcos security org service-accounts keypair private-hdfs.pem public-hdfs.pem
dcos security org service-accounts create -p public-hdfs.pem -d hdfs hdfs
dcos security org users grant hdfs dcos:secrets:default:/hdfs/* full
dcos security org users grant hdfs dcos:secrets:list:default:/hdfs full
dcos security org users grant hdfs dcos:adminrouter:ops:ca:rw full
dcos security org users grant hdfs dcos:adminrouter:ops:ca:ro full
dcos security org users grant hdfs dcos:mesos:master:framework:role:hdfs-role create
dcos security org users grant hdfs dcos:mesos:master:volume:role:hdfs-role create
dcos security org users grant hdfs dcos:mesos:master:reservation:role:hdfs-role create
dcos security org users grant hdfs dcos:mesos:master:task:user:nobody create
dcos security secrets create-sa-secret --strict private-hdfs.pem hdfs /hdfs/private-hdfs

# Deploy hdfs
dcos package install --yes hdfs --options=options-hdfs.json --package-version=2.3.0-2.6.0-cdh5.11.0

# Create the zookeeper service account
dcos security org service-accounts keypair private-zookeeper.pem public-zookeeper.pem
dcos security org service-accounts create -p public-zookeeper.pem -d zookeeper zookeeper
dcos security org users grant zookeeper dcos:secrets:default:/kafka-zookeeper/* full
dcos security org users grant zookeeper dcos:secrets:list:default:/kafka-zookeeper full
dcos security org users grant zookeeper dcos:adminrouter:ops:ca:rw full
dcos security org users grant zookeeper dcos:adminrouter:ops:ca:ro full
dcos security org users grant zookeeper dcos:mesos:master:framework:role:kafka-zookeeper-role create
dcos security org users grant zookeeper dcos:mesos:master:reservation:role:kafka-zookeeper-role create
dcos security org users grant zookeeper dcos:mesos:master:volume:role:kafka-zookeeper-role create
dcos security org users grant zookeeper dcos:mesos:master:task:user:nobody create
dcos security org users grant zookeeper dcos:mesos:master:reservation:principal:zookeeper delete
dcos security org users grant zookeeper dcos:mesos:master:volume:principal:zookeeper delete
dcos security secrets create-sa-secret --strict private-zookeeper.pem zookeeper /kafka-zookeeper/private-zookeeper

# Deploy zookeeper
dcos package install --yes kafka-zookeeper --options=options-zookeeper.json --package-version=2.3.0-3.4.12
./check-status.sh kafka-zookeeper

# Create the kafka service account
dcos security org service-accounts keypair private-kafka.pem public-kafka.pem
dcos security org service-accounts create -p public-kafka.pem -d kafka kafka
dcos security org users grant kafka dcos:secrets:default:/kafka/* full
dcos security org users grant kafka dcos:secrets:list:default:/kafka full
dcos security org users grant kafka dcos:adminrouter:ops:ca:rw full
dcos security org users grant kafka dcos:adminrouter:ops:ca:ro full
dcos security org users grant kafka dcos:mesos:master:framework:role:kafka-role create
dcos security org users grant kafka dcos:mesos:master:volume:role:kafka-role create
dcos security org users grant kafka dcos:mesos:master:reservation:role:kafka-role create
dcos security org users grant kafka dcos:mesos:master:task:user:nobody create
dcos security secrets create-sa-secret --strict private-kafka.pem kafka /kafka/private-kafka

# Deploy kafka
dcos package install --yes kafka --options=options-kafka.json --package-version=2.3.0-1.1.0
./check-status.sh kafka

# Create the spark service account
dcos security org service-accounts keypair private-spark.pem public-spark.pem
dcos security org service-accounts create -p public-spark.pem -d spark spark
dcos security secrets create-sa-secret --strict private-spark.pem spark /spark/private-spark
dcos security org users grant spark dcos:mesos:master:framework:role:* create
dcos security org users grant spark dcos:mesos:master:task:app_id:/spark create
dcos security org users grant spark dcos:mesos:master:task:user:nobody create

# Check that HDFS has been deployed
./check-status.sh hdfs

# Deploy spark
dcos package install --yes spark --options=options-spark.json --package-version=2.3.1-2.2.1-2
./check-app-status.sh spark

# Create the secrets for the spark TLS Artifacts
dcos security secrets create /truststore --file trust.jks
dcos security secrets create /keystore --file server.jks

# Create the secret for the spark executor authentication
dcos spark secret /spark-auth-secret

# Create the kafka topic
dcos kafka topic create top1
