function install_terraform() {
  if [ $(which terraform | grep -w "not found" | wc -l) -eq 1 ]
  then
    wget -O /tmp/terraform_1.8.4_linux_amd64.zip https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
    unzip /tmp/terraform_1.8.4_linux_amd64.zip -d /tmp/terraform
    mv /tmp/terraform/terraform /usr/local/bin
    rm -rf /tmp/terraform /tmp/terraform_1.8.4_linux_amd64.zip
  fi
}

function install_yq() {
  wget -O /tmp/yq_linux_amd64.tar.gz https://github.com/mikefarah/yq/releases/download/v4.44.1/yq_linux_amd64.tar.gz
  tar -xvzf /tmp/yq_linux_amd64.tar.gz -C /tmp/yq_linux_amd64
  mv /tmp/yq_linux_amd64/yq_linux_amd64 /usr/local/bin/yq
  rm -rf /tmp/yq_linux_amd64 /tmp/yq_linux_amd64.tar.gz
}

function install_helm3() {
  wget -O /tmp/helm-v3.15.1-linux-amd64.tar.gz https://get.helm.sh/helm-v3.15.1-linux-amd64.tar.gz
  tar -xvzf /tmp/helm-v3.15.1-linux-amd64.tar.gz -C /tmp/helm-v3
  mv /tmp/helm-v3/linux-amd64/helm /usr/local/bin/helm
  rm -rf /tmp/helm-v3 /tmp/helm-v3.15.1-linux-amd64.tar.gz
}