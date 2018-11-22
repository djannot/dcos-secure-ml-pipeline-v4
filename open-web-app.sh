export PUBLICNODEIP=$(./findpublic_ips.sh | head -1 | sed "s/.$//" )
open http://$PUBLICNODEIP:8000
