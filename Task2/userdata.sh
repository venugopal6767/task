#!/bin/bash

# Update the package repository
apt update -y

# Install necessary packages: NGINX and Docker
apt install -y nginx docker.io

# Start and enable NGINX and Docker services
systemctl start nginx
systemctl enable nginx
systemctl start docker
systemctl enable docker
chmod 777 /var/run/docker.sock

# Remove the default NGINX configuration
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

# Create a new NGINX configuration file
cat <<EOT > /etc/nginx/sites-available/default
# Proxy to Docker container
server {
    listen 80;
    server_name ec2-alb-docker.venugopalmoka.site;

    location / {
        proxy_pass http://127.0.0.1:8080; # Docker service
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}

# Serve static content for instance
server {
    listen 80;
    server_name ec2-alb-instance.venugopalmoka.site;

    location / {
        root /var/www/html;
        index index.html;
    }
}
EOT

# Create a symbolic link to enable the custom NGINX configuration
ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Run a Docker container that serves a custom HTML response
docker run -d --name namaste-container -p 8080:80 nginx:alpine sh -c "echo '<h1>Namaste from Container!</h1>' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"

# Create a static HTML page for the instance
echo "<h1>Hello from Instance!</h1>" > /var/www/html/index.html

# Reload and restart NGINX
systemctl reload nginx
systemctl restart nginx