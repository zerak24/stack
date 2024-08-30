export DOMAIN_NAME=vault.example.info
# vault
sudo snap install docker
sudo mkdir -p $HOME/vault/logs
sudo mkdir -p $HOME/vault/file
sudo mkdir -p $HOME/vault/config
sudo docker volume create --opt type=none --opt device=/home/duyle/vault/config

# add file vault/config/vault.json
# {
#   "backend":{
#     "file":{
#         "path":"/vault/file"
#     }
#   },
#   "listener":{
#     "tcp":{
#         "address":"[::]:8200",
#         "cluster_address":"[::]:8201",
#         "tls_disable":1,
#     }
#   },
#   "default_lease_ttl":"24h",
#   "max_lease_ttl":"168h", 
#   "disable_mlock":true,
#   "ui":true,
# }

sudo docker run --detach --network host --restart always --name vault --hostname $DOMAIN_NAME -v $HOME/vault/config:/vault/config -v $HOME/vault/logs:/vault/logs -v $HOME/vault/file:/vault/file --entrypoint docker-entrypoint.sh --cap-add=IPC_LOCK vault:1.13.3 vault server -config=vault/config/vault.json
# nginx
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl reload nginx
# certbot  
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d $DOMAIN_NAME --register-unsafely-without-email

# add to /etc/nginx/sites-available/default
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

# test

# server {

#     listen [::]:80;
#     listen 80;
#     location / {
#             proxy_pass http://127.0.0.1:8200;
#             proxy_set_header Host $host;
#             proxy_set_header X-Real-IP $remote_addr;
#             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#             proxy_set_header X-Forwarded-Proto https;
#     }
# }