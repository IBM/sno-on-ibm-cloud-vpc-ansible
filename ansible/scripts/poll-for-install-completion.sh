#!/bin/sh

offline_access_token=$(cat "$1")
cluster_name="$2"

retries=0
max_retries=269

percent_complete=0

while [ $retries -lt $max_retries -a $percent_complete -lt 100 ]
do
   retries=$(($retries+1))
   token=$(curl \
     --silent \
     --data-urlencode "grant_type=refresh_token" \
     --data-urlencode "client_id=cloud-services" \
     --data-urlencode "refresh_token=${offline_access_token}" \
     https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token | jq -r .access_token)

    percent_complete=$(curl -s -X GET "https://api.openshift.com/api/assisted-install/v2/clusters?with_hosts=true"\
      -H "Authorization: Bearer $token"  -H "accept: application/json" \
      -H "get_unregistered_clusters: false" | jq -r ".[] | select (.name == \"$cluster_name\") |.progress.total_percentage")

    if [[ $percent_complete =~ ^(0|[1-9][0-9]{0,1}|100)$ ]]
    then
        if [ $percent_complete -eq 100 ]
        then
        break
        else
        sleep 20
        fi
    else
      echo "Error: Assisted Installer API call failed" 
      exit 1
    fi
done

if [ $percent_complete -lt 100 ]
then
  echo "Error: Install timed out after 90 minutes" 
  exit 1
else
  echo "Install successful !"
  exit 0
fi
