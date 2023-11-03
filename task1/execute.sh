#!/bin/bash
#Update the package repository
sudo apt-get update -y

# Install Java (required for Jenkins)
sudo apt-get install -y default-jre
sudo apt install fontconfig openjdk-17-jre

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

# Start Jenkins service
sudo systemctl start jenkins

sleep 60  # Wait for Jenkins to start (adjust as needed)
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# aws ssm put-parameter --name "/jenkins/adminPassword" --value "$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)" --type "SecureString" --overwrite