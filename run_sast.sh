# Downloading and preparing SAClientUtil

#$serviceUrl = "cloud.appscan.com"
if ! [ -x "$(command -v appscan.sh)" ]; then
  echo 'appscan.sh is not installed.' >&2
  curl -k  "https://cloud.appscan.com/api/v4/Tools/SAClientUtil?os=linux" > SAClientUtil.zip
  unzip SAClientUtil.zip -d . > /dev/null
  rm -f SAClientUtil.zip
  mv ./SAClientUtil.* ./SAClientUtil
  export PATH="./SAClientUtil/bin:${PATH}"
fi

appscan.sh version
appscan.sh prepare
