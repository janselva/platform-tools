#!/bin/bash
#
#   Copyright (c) 2016 Cisco and/or its affiliates.
#   This software is licensed to you under the terms of the Apache License, Version 2.0
#   (the "License").
#   You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#   The code, technical concepts, and all information contained herein, are the property of
#   Cisco Technology, Inc.and/or its affiliated entities, under various laws including copyright,
#   international treaties, patent, and/or contract.
#   Any use of the material herein must be in accordance with the terms of the License.
#   All rights not expressly granted by the License are reserved.
#   Unless required by applicable law or agreed to separately in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
#   ANY KIND, either express or implied.
#
#   Purpose: uploads arbitrary datasets to Hadoop using HTTPFS service

ROOT_UID="0"
HDFS_CLI_CONFIG=~/.hdfscli.cfg
HDFS_PATH="/user/pnda/PNDA_datasets/bulk/"

Help() {
  echo ""
  echo "Usage: $NAME {install | upload | download}" >&2
  echo ""
  echo "       $NAME upload [file | directory]" >&2
  echo ""
  echo "Examples:"
  echo ""
  echo "  ingest.sh install https://knox.service.dc1.pnda.local:8443/gateway/pnda /root/pndaproject/pnda-cli/platform-certificates/pndaproject-ca.crt"
  echo "  ingest.sh upload --force --threads 10 text.txt"
  echo "  ingest.sh upload -f -t 2 data_dir"
  echo ""
  exit 1
}

install() {
  echo ""
  echo "installing HDFS cli...."
  python -c "import hdfs" &> /dev/null
  if [ $? != 0 ] ; then
    sudo pip2 install hdfs &> /dev/null
  fi
  rm ${HDFS_CLI_CONFIG} &> /dev/null
  echo "[global]" >> ${HDFS_CLI_CONFIG}
  echo "default.alias=prod" >> ${HDFS_CLI_CONFIG}
  echo "autoload.paths=./hdfscli.py" >> ${HDFS_CLI_CONFIG}
  echo "[prod.alias]" >> ${HDFS_CLI_CONFIG}
  echo "client=SecureClient" >> ${HDFS_CLI_CONFIG}
  echo "url=$2" >> ${HDFS_CLI_CONFIG}
  echo "verify=$3" >> ${HDFS_CLI_CONFIG}
}

upload() {
  read -p 'Enter Knox username: ' user
  read -sp 'Enter Knox password: ' passwd
  username_encoded=$(echo -n "$user" | base64)
  password_encoded=$(echo -n "$passwd" | base64)
  echo "user"=$username_encoded >> ${HDFS_CLI_CONFIG}
  echo "password"=$password_encoded >> ${HDFS_CLI_CONFIG}
  echo ""
  for last; do true; done
  echo "Trying to upload $last onto cluster"
  python -c "import hdfs" &> /dev/null
  if [ $? != 0 ] ; then
    echo ""
    echo "Run 'install' command before trying to upload files..."
    exit
  fi
  shift 1
  hdfscli upload ${@%/} ${HDFS_PATH}
  if [ $? = 0 ] ; then
    echo ""
    echo "Upload of $last done."
  fi
  # Remove username & password from config file(Last two lines)
  sed -i -e :a -e '$d;N;2,2ba' -e 'P;D' ${HDFS_CLI_CONFIG}
}

# Check for help option or no option and print help and exit
if [ $# -lt 1 ] ; then
   Help
   exit 1
fi

if [ "$1" = "-help" -o "$1" = "help" -o "$1" = "-h" ]  ; then
   Help
   exit 0
fi


case "$1" in
  install)
    if [ $# -lt 2 ] ; then
      Help
      exit 1
    fi
    install $@
  ;;
  upload)
    if [ $# -lt 2 ] ; then
      Help
      exit 1
    fi
    upload $@
  ;;
  *)
    Help
  ;;

esac
