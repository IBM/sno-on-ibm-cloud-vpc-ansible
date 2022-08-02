#!/bin/sh

offline_access_token=$1
cluster_name=$2
echo $offline_access_token
echo $cluster_name

retries=0
max_retries=269

percent_complete=0

percent_complete_from_api=0

max_error_retries=270  # Allow up to 270 errors before throwing in the towel

error_retries=0


while [ $retries -lt $max_retries -a $percent_complete -lt 100 ]
do
   retries=$(($retries+1))
   token=$(curl \
     --silent \
     --data-urlencode "grant_type=refresh_token" \
     --data-urlencode "client_id=cloud-services" \
     --data-urlencode "refresh_token=${offline_access_token}" \
     https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token | jq -r .access_token)

    percent_complete_from_api=$(curl -s -X GET "https://api.openshift.com/api/assisted-install/v2/clusters?with_hosts=true"\
      -H "Authorization: Bearer $token"  -H "accept: application/json" \
      -H "get_unregistered_clusters: false" | jq -r ".[] | select (.name == \"$cluster_name\") |.progress.total_percentage" 2>&1)

    if [[ $percent_complete_from_api =~ ^(0|[1-9][0-9]{0,1}|100)$ ]]
    then
        percent_complete=$percent_complete_from_api
        if [ $percent_complete -eq 100 ]
        then
          break
        else
          sleep 20
        fi
    else
      error_retries=$(($error_retries+1))
      if [ $error_retries -lt $max_error_retries ]
      then
         sleep 20
         continue
      else
         echo "Error: Assisted Installer API call failed - max error retries exceeded" 
         exit 1
       fi 
    fi
done

if [ $percent_complete -lt 100 ]
then
  echo "Error: Install timed out after 90 minutes" 
  exit 1
else
  echo "Install successful!"
  exit 0
fi
