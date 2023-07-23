#!/bin/bash

set -e
set -v

read -p "Enter AWS Access Key ID: " access_key

read -p "Enter AWS Secret Key:  " secret_key

export TF_LOG=INFO
export TF_LOG_PATH=./terraform.log 


terraform -chdir=./deploy/ destroy -auto-approve -var 'access_key='$access_key'' -var 'secret_key='$secret_key'' 
