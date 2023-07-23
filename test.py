# -*- coding: utf-8 -*-

import json
import requests
from datetime import datetime


def _get_base_url():
    """
        This method will try to get the API URL from the Terraform State file "terraform.state".
        Example JSON in terraform.state:
        {
          ...
          "outputs": {
              "base_url": {
              "value": "https://12345.execute-api.eu-central-1.amazonaws.com/moonlightingproject",
              "type": "string"
            }
          },
          ...
        }
    :return:
        str: The url for the API. "https://12345.execute-api.eu-central-1.amazonaws.com/moonlightingproject"
    """
    base_url = ""

    with open('./deploy/terraform.tfstate') as json_file:
        data = json.load(json_file)
        try:
            base_url = str(data['outputs']['base_url']['value']) + "/api"
            print("using API URL:  "+base_url)
        except:
            print("Could not find outputs.base_url.value in terraform.tfstate file.  Did you successfully deploy the infrastructure?")
            exit()
    return base_url


def _mock_moonlightingproject():
    """
        This method will form a JSON message that simulates what moonlightingproject might send.

    :return:
        JSON meassage.
    """
    date_time = datetime.now().strftime("%m/%d/%Y, %H:%M:%S")
    return {"id": "<20111114174239.25659.5817@samples.moonlightingproject.org>", "message":"Queued. Thank you. Date, Time: "+str(date_time)}


def post_moonlightingproject(lambda_api_url, moonlightingproject_message):
    """
        This method will POST the moonlightingproject_message to the  api

    Args:
        lambda_api_url (str): The  API URL
        moonlightingproject_message (str): The moonlightingproject message

    """

    post_response = requests.post(lambda_api_url, json=moonlightingproject_message)
    if post_response.status_code == 200:
        print("SUCCESS. POSTed moonlightingproject message to API")
    else:
        print("FAIL on POST")

def get_all_projects(lambda_api_url):
    """
        This method will try to GET all projects by calling the lambda function get_projects 
            via the Gateway API.
    """
    post_response = requests.get(lambda_api_url)
    if post_response.status_code == 200:
        print("SUCCESS. GET post_response="+str(post_response.content))
    else:
        print("FAIL on GET")
   

def main():
    lambda_api_url = _get_base_url()
    moonlightingproject_message = _mock_moonlightingproject()
    post_moonlightingproject(lambda_api_url,moonlightingproject_message)
    get_all_projects(lambda_api_url)
  
if __name__== "__main__":
    main()