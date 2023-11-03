#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y default-jre
sudo apt install fontconfig openjdk-17-jre -y
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo apt install ansible -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update -y
sudo apt install terraform -y
sudo apt install awscli -y
