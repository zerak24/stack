#! /bin/bash

function install_terraform() {
  if [ $(which terraform | wc -l) -eq 0 ]
  then
    wget -O /tmp/terraform_1.8.4_linux_amd64.zip https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
    mkdir -p /tmp/terraform
    unzip /tmp/terraform_1.8.4_linux_amd64.zip -d /tmp/terraform
    mv /tmp/terraform/terraform /usr/local/bin/terraform
    rm -rf /tmp/terraform /tmp/terraform_1.8.4_linux_amd64.zip
  fi
}

function install_gcloud() {
  if [ $(which gcloud | wc -l) -eq 0 ]
  then
    wget -O /tmp/google-cloud-cli-478.0.0-linux-x86_64.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-478.0.0-linux-x86_64.tar.gz
    mkdir -p /usr/local/bin/gcloud
    tar -xvzf /tmp/google-cloud-cli-478.0.0-linux-x86_64.tar.gz -C /usr/local/bin/gcloud
    /usr/local/bin/gcloud/google-cloud-sdk/install.sh
    rm -rf /tmp/google-cloud-cli-478.0.0-linux-x86_64.tar.gz
  fi
}

function install_aws() {
  if [ $(which aws | wc -l) -eq 0 ]
  then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip /tmp/awscliv2.zip
    sudo /tmp/aws/install
    rm -rf /tmp/aws /tmp/awscliv2.zip
  fi
}

function install_terragrunt() {
  if [ $(which terragrunt | wc -l) -eq 0 ]
  then
    wget "https://github.com/gruntwork-io/terragrunt/releases/download/v0.67.2/terragrunt_linux_amd64" -O "/tmp/terragrunt"
    chmod +x /tmp/terragrunt
    sudo mv /tmp/terragrunt /usr/local/bin/terragrunt
    terragrunt --install-autocomplete
  fi
}

function install_yq() {
  if [ $(which yq | wc -l) -eq 0 ]
  then
    wget -O /tmp/yq_linux_amd64.tar.gz https://github.com/mikefarah/yq/releases/download/v4.44.1/yq_linux_amd64.tar.gz
    mkdir -p /tmp/yq_linux_amd64
    tar -xvzf /tmp/yq_linux_amd64.tar.gz -C /tmp/yq_linux_amd64
    sudo mv /tmp/yq_linux_amd64/yq_linux_amd64 /usr/local/bin/yq
    rm -rf /tmp/yq_linux_amd64 /tmp/yq_linux_amd64.tar.gz
  fi
}

function install_helm3() {
  if [ $(which helm | wc -l) -eq 0 ]
  then
    wget -O /tmp/helm-v3.15.1-linux-amd64.tar.gz https://get.helm.sh/helm-v3.15.1-linux-amd64.tar.gz
    mkdir -p /tmp/helm-v3
    tar -xvzf /tmp/helm-v3.15.1-linux-amd64.tar.gz -C /tmp/helm-v3
    sudo mv /tmp/helm-v3/linux-amd64/helm /usr/local/bin/helm
    rm -rf /tmp/helm-v3 /tmp/helm-v3.15.1-linux-amd64.tar.gz
  fi

  ## install helm plugins
  
  if [ $(helm plugin list | awk '{print $1}' | grep diff | wc -l) -eq 0 ]; then
    helm plugin install https://github.com/databus23/helm-diff
  fi
  if [ $(helm plugin list | awk '{print $1}' | grep secrets | wc -l) -eq 0 ]; then
    helm plugin install https://github.com/jkroepke/helm-secrets
  fi
  if [ $(helm plugin list | awk '{print $1}' | grep cm-push | wc -l) -eq 0 ]; then
    helm plugin install https://github.com/chartmuseum/helm-push
  fi
}

function install_kubectl() {
  if [ $(which kubectl | wc -l) -eq 0 ]
  then
    wget -O /tmp/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x /tmp/kubectl
    sudo mv /tmp/kubectl /usr/local/bin/kubectl
  fi
}
