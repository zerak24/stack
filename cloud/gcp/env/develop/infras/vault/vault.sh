# vault
sudo snap install docker
sudo mkdir -p ./vault/logs
sudo mkdir -p ./vault/file
sudo mkdir -p ./vault/config
sudo docker volume create --opt device=/home/duyle/vault/config
sudo echo << EOF >> /vault/config/vault.json
{
  "backend":{
    "file":{
        "path":"/vault/file"
    }
  },
  "listener":{
    "tcp":{
        "address":"[::]:8200",
        "cluster_address:"[::]:8201"
        "tls_disable":1
    }
  },
  "default_lease_ttl":"24h",
  "max_lease_ttl":"168h",
  "disable_mlock":true,
  "ui":true,
}
EOF
sudo docker run --detach --name vault-container --hostname vault.thisiszerak.net -v /home/duyle/vault/config:/vault/config -v /home/duyle/vault/logs:/vault/logs -v /home/duyle/vault/file:/vault/file --entrypoint docker-entrypoint.sh --publish 80:8200 --cap-add=IPC_LOCK vault:1.13.3 vault server -config=/vault/config/vault.json
# certbot
# nginx ssl
