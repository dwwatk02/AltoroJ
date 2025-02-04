# Downloading and preparing SAClientUtil
if ! [ -x "$(command -v appscan.sh)" ]; then
  echo 'appscan.sh is not installed.' >&2
  curl -k -s "https://$serviceUrl/api/v4/Tools/SAClientUtil?os=linux" > $HOME/SAClientUtil.zip
  unzip $HOME/SAClientUtil.zip -d $HOME > /dev/null
  rm -f $HOME/SAClientUtil.zip
  mv $HOME/SAClientUtil.* $HOME/SAClientUtil
  export PATH="$HOME/SAClientUtil/bin:${PATH}"
fi