#!/bin/bash

file="conf/red5.properties"

echo "Update script is running for Ant Media Server"

licensekey=$(cat $file | grep -i "server.licence_key" | awk -F "=" '{print $2}')

licensecheck=$(curl --silent -X POST -H "Content-Type:application/json" https://us-central1-ant-media-server-license.cloudfunctions.net/license_valid -d '{"key":"'"$licensekey"'"}')

echo "Checking license"

check=$(echo $licensecheck | awk -F ":" '{print $2}')

#Leave if the license is unvalid, it won't update anyway.
if [[ "$check" =~ .*invalid.* ]]; then
  echo "Your license is invalid, please try with a valid license"
  exit
fi

echo "License is valid"


tmp=$(curl --silent http://localhost:5080/LiveApp/rest/v2/version | awk -F ":" '{print $2}')

tmp2=$(echo $tmp | awk -F "-" '{print $1}')

version=$(echo $tmp2 | awk -F "\"" '{print $2}')

variable=$(curl --silent http://localhost/generate.php?$licensekey'&'$version | sed 's/<\/*[^>]*>//g')

#echo $variable

if [[ "$variable" =~ .*Updated.* ]]; then
  echo "You are already using the latest version of Ant Media Server - V"$version
  exit
fi

#echo $version

sudo wget $variable -O antmedia.zip

sudo wget --no-check-certificate https://raw.githubusercontent.com/ant-media/Scripts/master/install_ant-media-server.sh

sudo chmod 755 install_ant-media-server.sh

sudo ./install_ant-media-server.sh -i antmedia.zip



