export PUBLICNODEIP=$(./findpublic_ips.sh | head -1 | sed "s/.$//" )

token=`curl -X POST -k \
-d 'username=nifiadmin@MESOS.LAB&password=password' \
https://$PUBLICNODEIP:8443/nifi-api/access/token`

users=`curl -X GET -k \
-H "Authorization: Bearer $token" \
https://$PUBLICNODEIP:8443/nifi-api/tenants/users | jq .users[].component.id | sed -e "s/^/{ \"id\": /" | sed -e "s/$/ }/" | sed -e "$ ! s/$/,/"`

admins=$(curl -X POST -k \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
https://$PUBLICNODEIP:8443/nifi-api/tenants/user-groups --data-binary @- <<BODY | jq .id | sed -e "s/\"//g"
{
  "revision" : {
    "version" : 0
  },
  "permissions" : {
    "canRead" : true,
    "canWrite" : true
  },
  "component" : {
    "identity" : "admins",
    "users" : [
      $users
    ]
  }
}
BODY)

processgroup=$(curl -X GET -k \
-H "Authorization: Bearer $token" \
https://$PUBLICNODEIP:8443/nifi-api/flow/process-groups/root | jq .processGroupFlow.id | sed -e "s/\"//g")

for action in read write; do
curl -X POST -k \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
https://$PUBLICNODEIP:8443/nifi-api/policies --data-binary @- <<BODY
{
  "revision" : {
    "version" : 0
  },
  "component": {
    "resource": "/process-groups/$processgroup",
    "action": "$action",
    "userGroups": [
      { "id": "$admins" }
    ]
  }
}
BODY
done

for action in read write; do
curl -X POST -k \
-H "Authorization: Bearer $token" \
-H "Content-Type: application/json" \
https://$PUBLICNODEIP:8443/nifi-api/policies --data-binary @- <<BODY
{
  "revision" : {
    "version" : 0
  },
  "component": {
    "resource": "/data/process-groups/$processgroup",
    "action": "$action",
    "userGroups": [
      { "id": "$admins" }
    ]
  }
}
BODY
done
