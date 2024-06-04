sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo EXTERNAL_URL="https://git.thisiszerak.net" apt-get install gitlab-ce

# sudo snap install docker
# sudo mkdir -p /var/lib/gitlab
# export GITLAB_HOME=/var/lib/gitlab
# sudo docker run --detach \
#   --hostname git.thisiszerak.net \
#   --env GITLAB_OMNIBUS_CONFIG="external_url 'http://git.thisiszerak.net'" \
#   --publish 443:443 --publish 80:80 --publish 22:22 \
#   --name gitlab \
#   --restart always \
#   --volume $GITLAB_HOME/config:/etc/gitlab \
#   --volume $GITLAB_HOME/logs:/var/log/gitlab \
#   --volume $GITLAB_HOME/data:/var/opt/gitlab \
#   --shm-size 256m \
#   --network host \
#   gitlab/gitlab-ce:17.0.1-ce.0