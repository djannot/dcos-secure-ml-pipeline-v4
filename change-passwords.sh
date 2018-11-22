cat principals.txt | grep nifiadmin | while read principal; do
  echo "CHANGING password for the principal $principal"
  file=`echo $principal | sed 's/\//\./' | sed 's/@/\./'`
  echo password | dcos task exec -i kdc kadmin -p admin/admin -q "cpw -pw password $principal"
done
