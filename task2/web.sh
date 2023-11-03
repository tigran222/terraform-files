#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
sudo apt install docker.io -y
sudo apt install docker-compose -y
sudo apt install npm -y


myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

sudo cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h2><font color="gold">Build by Power of Terraform <font color="red"> v0.12</font></h2><br><p>
<font color="green">Server PrivateIP: <font color="aqua">$myip<br><br>

<font color="magenta">
<b>Version 1.0</b>
</body>
</html>
EOF

sudo systemctl start apache2


