dcos security secrets create -v password nifiadminpassword

# Create the nifi service account
dcos security org service-accounts keypair private-nifi.pem public-nifi.pem
dcos security org service-accounts create -p public-nifi.pem -d nifi nifi
dcos security org users grant nifi dcos:superuser full --description "grant permission to superuser"
dcos security secrets create-sa-secret --strict private-nifi.pem nifi /nifi/private-nifi

# Deploy nifi
dcos package install --yes nifi --options=options-nifi.json --package-version=0.2.0-1.5.0

./check-status.sh nifi
./change-passwords.sh
