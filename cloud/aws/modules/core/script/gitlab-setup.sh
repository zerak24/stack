export DOMAIN_NAME=git.example.info
DIR="/home/ubuntu"

# gitlab

sudo snap install docker
sudo mkdir -p $DIR/gitlab/config
sudo mkdir -p $DIR/gitlab/logs
sudo mkdir -p $DIR/gitlab/data
sudo docker run --detach --hostname $DOMAIN_NAME --env GITLAB_OMNIBUS_CONFIG="external_url 'http://$DOMAIN_NAME'" \
  --network host --name gitlab --restart always \
  --volume $DIR/gitlab/config:/etc/gitlab \
  --volume $DIR/gitlab/logs:/var/log/gitlab \
  --volume $DIR/gitlab/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:17.0.1-ce.0

# nginx

sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl reload nginx

# certbot  

# sudo apt update
# sudo apt install certbot python3-certbot-nginx -y
# sudo certbot --nginx -d $DOMAIN_NAME --register-unsafely-without-email

# sudo tee /etc/nginx/sites-available/default << EOF
# server {
#     server_name <domain-name>; # managed by Certbot

#     listen [::]:443 ssl ipv6only=on; # managed by Certbot
#     listen 443 ssl; # managed by Certbot
#     ssl_certificate /etc/letsencrypt/live/<domain-name>/fullchain.pem; # managed by Certbot
#     ssl_certificate_key /etc/letsencrypt/live/<domain-name>/privkey.pem; # managed by Certbot
#     include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
#     ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

#     location / {
#             proxy_pass http://127.0.0.1:8200;
#             proxy_set_header Host $host;
#             proxy_set_header X-Real-IP $remote_addr;
#             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#             proxy_set_header X-Forwarded-Proto https;
#     }
# }
# EOF

# sudo systemctl reload nginx
