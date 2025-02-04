#!/usr/bin/env bash

# cloud.appscan
serviceUrl="cloud.appscan.com"
#asocApiKeyId="4a6dec6b-2ae7-8adb-eff7-a1903dea651c"
#asocApiKeySecret="GzVrXNG/bXvOm35wWOL/oCOkxHdzyZhDyuu6hk8uMIpP"
#appId="4d5b6b9b-ec4c-4f98-b16b-b8390c7fa2d9"
# as.botexam
serviceUrl="as.botexam.net"
asocApiKeyId="local_61431386-e780-ad0a-2e80-567f0376cf55"
asocApiKeyId="aAFZ8thJEdEVKOLyOKZAkm0l83paVMbPFMNilv8OBa6j"
appId="b77bfb68-e618-4df2-a833-f0a781970b8f"
scanName="test ADO"

# Downloading and preparing SAClientUtil
if ! [ -x "$(command -v appscan.sh)" ]; then
  echo 'appscan.sh is not installed.  Downloading now..' >&2
  curl -k -s "https://$serviceUrl/api/v4/Tools/SAClientUtil?os=linux" > SAClientUtil.zip
  unzip SAClientUtil.zip -d . > /dev/null
  rm -f SAClientUtil.zip
  mv ./SAClientUtil.* ./SAClientUtil
  export PATH="./SAClientUtil/bin:${PATH}"
fi

appscan.sh version
appscan.sh prepare


# Authenticate in ASOC
asocToken=$(curl -k -s -X POST --header 'Content-Type:application/json' --header 'Accept:application/json' -d '{"KeyId":"'"$asocApiKeyId"'","KeySecret":"'"$asocApiKeySecret"'"}' "https://$serviceUrl/api/v4/Account/ApiKeyLogin" | grep -oP '(?<="Token":\ ")[^"]*')
if [ -z "$asocToken" ]; then
  echo "The token variable is empty. Check the authentication process.";
    exit 1
fi

irxFile=$(ls -t *.irx | head -n1)
# Upload IRX file
if [ -f "$irxFile" ]; then
    irxFileId=$(curl -k -s -X 'POST' "https://$serviceUrl/api/v4/FileUpload" -H 'accept:application/json' -H "Authorization:Bearer $asocToken" -H 'Content-Type:multipart/form-data' -F "uploadedFile=@$irxFile" | grep -oP '(?<="FileId":\ ")[^"]*');
    echo "$irxFile exist. It will be uploaded to ASoC. IRX file id is $irxFileId.";
else
    echo "IRX file not identified.";
fi

# Start scan
scanId=$(curl -s -k -X 'POST' "https://$serviceUrl/api/v4/Scans/Sast" -H 'accept:application/json' -H "Authorization:Bearer $asocToken" -H 'Content-Type:application/json' -d '{"AppId":"'"$appId"'","ApplicationFileId":"'"$irxFileId"'","ClientType":"user-site","EnableMailNotification":false,"Execute":true,"Locale":"en","Personal":false,"ScanName":"'"SAST $scanName $irxFile"'","EnablementMessage":"","FullyAutomatic":true}'| jq -r '. | {Id} | join(" ")');
echo "Scan started, scanId $scanId"

echo "The scan name is $scanName and scanId is $scanId"
echo $scanId > scanId.txt

# Check status scan and keep it in loop until Ready status.
scanStatus=$(curl -k -s -X 'GET' "https://$serviceUrl/api/v4/Scans/Sast/$scanId" -H 'accept:application/json' -H "Authorization:Bearer $asocToken" | jq -r '.LatestExecution | {Status} | join(" ")');
echo $scanStatus
while true ; do 
    scanStatus=$(curl -k -s -X 'GET' "https://$serviceUrl/api/v4/Scans/Sast/$scanId" -H 'accept:application/json' -H "Authorization:Bearer $asocToken" | jq -r '.LatestExecution | {Status} | join(" ")');
    if [ "$scanStatus" == "Running" ] || [ "$scanStatus" == "InQueue" ]; then
        echo $scanStatus
    elif [ "$scanStatus" == "Failed" ]; then
        echo $scanStatus
        echo "Scan Failed. Check ASOC logs"
        exit 1
    else
        echo $scanStatus
        echo "View scan at https://$serviceUrl/main/myapps/$appId/scans/$scanId/scanOverview"
        break
    fi
    sleep 60
done