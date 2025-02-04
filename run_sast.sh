#!/usr/bin/env bash
# Downloading and preparing SAClientUtil

serviceUrl = "cloud.appscan.com"
if ! [ -x "$(command -v appscan.sh)" ]; then
  echo 'appscan.sh is not installed.' >&2
  curl -k  "https://$serviceUrl/api/v4/Tools/SAClientUtil?os=linux" > SAClientUtil.zip
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