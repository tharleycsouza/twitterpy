#!/bin/bash
yum -y update
yum install -y ruby
cd /tmp
curl -O https://aws-codedeploy-eu-west-1.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto