base64 trust-ca.jks > trust-ca.jks.base64
dcos task | grep nifi-.-node | awk '{ print $5 }' | while read task; do
  dcos task exec -i $task sh -c 'cat > /tmp/trust-ca.jks.base64' < ./trust-ca.jks.base64
  dcos task exec -i $task sh -c 'base64 --decode /tmp/trust-ca.jks.base64 > /tmp/trust-ca.jks' < /dev/null
  dcos task exec -i $task sh -c 'cp ./node.keytab /tmp/' < /dev/null
  dcos task exec -i $task sh -c 'wget -O /tmp/core-site.xml http://api.hdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/core-site.xml' < /dev/null
  dcos task exec -i $task sh -c 'wget -O /tmp/hdfs-site.xml http://api.hdfs.marathon.l4lb.thisdcos.directory/v1/endpoints/hdfs-site.xml' < /dev/null
done
