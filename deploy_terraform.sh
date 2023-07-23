#!/bin/bash

set -e
set -v

read -p "Enter AWS Access Key ID: " access_key

read -p "Enter AWS Secret Key:  " secret_key

export TF_LOG=INFO
export TF_LOG_PATH=./terraform.log 

############
# package put_project/index.js
############
echo " packaging Lambda function put_project .... "
cd lambda/put_project/
zip put_project.zip index.js
mv put_project.zip ../../deploy/
cd ../../

############
# package get_projects/index.js
############
echo " packaging Lambda function get_projects .... "
cd lambda/get_projects/
zip get_projects.zip index.js
mv get_projects.zip ../../deploy/
cd ../../

echo " Deploying via Terraform....."
terraform -chdir=./deploy/ init -upgrade
terraform -chdir=./deploy/ apply -auto-approve -var 'access_key='$access_key'' -var 'secret_key='$secret_key'' 