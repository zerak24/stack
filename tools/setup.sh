function install_terraform() {
  if [ $(which terraform | grep -w "not found" | wc -l) -eq 1 ]
  then
    curl -O /tmp/terraform_1.8.4_linux_amd64.zip https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
    unzip /tmp/terraform_1.8.4_linux_amd64.zip -d /tmp/terraform
    mv /tmp/terraform/terraform /usr/local/bin
    rm -rf /tmp/terraform /tmp/terraform_1.8.4_linux_amd64.zip
  fi
}

function install_yq() {
  :;
}

function install_helm3() {
  :;
}