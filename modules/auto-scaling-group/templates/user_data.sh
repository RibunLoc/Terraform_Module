#!/bin/bash

set -eux

apt-get update -y

# Install nginx
apt-get install -y nginx

# Start nginx service
systemctl enable nginx
systemctl start nginx

cat <<EOF >/var/www/html/index.html
<html>
  <head>
    <title>Dev Web ASG Test</title>
  </head>
  <body style="font-family:sans-serif;text-align:center;margin-top:50px;">
    <h1>ASG Deployment Successful 🎉</h1>
    <p>Environment: ${ENV}</p>
    <p>Hostname: $(hostname -f)</p>
    <p>Launched at: $(date)</p>
  </body>
</html>
EOF