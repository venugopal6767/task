# task
# Proxy to Docker container
server {
    listen 80;
    server_name ec2-alb-docker.venugopalmoka.site;

    location / {
        proxy_pass http://127.0.0.1:8080; # Docker service
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
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