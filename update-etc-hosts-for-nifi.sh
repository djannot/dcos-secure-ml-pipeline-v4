export PUBLICNODEIP=$(./findpublic_ips.sh | head -1 | sed "s/.$//" )
echo Public node ip: $PUBLICNODEIP
sed '/nifi/d' /etc/hosts > ./hosts
echo "$PUBLICNODEIP nifi-0-node.nifi.autoip.dcos.thisdcos.directory" >>./hosts
echo We are going to add "$PUBLICNODEIP nifi-0-node.nifi.autoip.dcos.thisdcos.directory" to your /etc/hosts. Therefore we need your local password.
sudo mv hosts /etc/hosts
