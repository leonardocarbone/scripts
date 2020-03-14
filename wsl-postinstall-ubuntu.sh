#!/bin/bash

install_packages() {

    clear
    read -p  $'\e[92mUpdate & Install System Packages. Press ENTER to continue'

    sudo apt-get -y update

    sudo apt install -y tree unzip
    sudo apt install -y build-essential 
    sudo apt install -y libcurl4-gnutls-dev 
    sudo apt install -y libxml2-dev 
    sudo apt install -y libssl-dev
}

install_asdf() {

    ASDF_VERSION="v0.7.7"
    ASDF_RUBY_VERSION="2.7.0"
    ASDF_NODEJS_VERSION="13.10.1"
    ASDF_DOTNETCORE_VERSION="3.1.102"

    clear
    read -p $'\e[92mInstall ASDF. Press ENTER to continue'

    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $ASDF_VERSION
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
    echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash
    
    clear
    read -p $'\e[92mInstall ASDF Ruby '"[$ASDF_RUBY_VERSION]. Press ENTER to continue"
    asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
    asdf install ruby $ASDF_RUBY_VERSION
    asdf global ruby $ASDF_RUBY_VERSION

    clear
    read -p $'\e[92mInstall ASDF NodeJS '"[$ASDF_NODEJS_VERSION]. Press ENTER to continue"
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
    asdf install nodejs $ASDF_NODEJS_VERSION
    asdf global nodejs $ASDF_NODEJS_VERSION
    npm i -g npm

    clear
    read -p $'\e[92mInstall ASDF .NetCore '"[$ASDF_DOTNETCORE_VERSION]. Press ENTER to continue"
    asdf plugin-add dotnet-core https://github.com/emersonsoares/asdf-dotnet-core.git
    asdf install dotnet-core $ASDF_DOTNETCORE_VERSION
    asdf global dotnet-core $ASDF_DOTNETCORE_VERSION
}

install_aws() {

    clear
    read -p "Install AWS CLI & CDK. Press ENTER to continue"

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    echo -e '\nexport AWS_DEFAULT_REGION=eu-west-1' >> ~/.bashrc
    source ~/.bashrc

    rm -rf aws
    rm awscliv2.zip

    npm install -g aws-cdk
}

install_terraform() {

    clear
    read -p "Install Terraform. Press ENTER to continue"

    curl "https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_linux_amd64.zip" -o "terraform.zip"
    unzip terraform.zip
    sudo mv terraform /usr/local/bin/
    rm terraform.zip    
}

main() {
    #Symlink
    ln -s /mnt/e/Dropbox/Dev /home/carbone/dev

    cd /home/carbone
    mkdir tmp
    cd tmp

    install_packages
    install_asdf
    install_aws
    install_terraform

    clear
    echo "Ruby Version........: `ruby --version`"
    echo "Node Version........: `node --version`"
    echo "DotNetCore Version..: `dotnet --version`"
    echo "AWS CLI Version.....: `aws --version`"
    echo "AWS CDK Version.....: `cdk --version`"
    echo "Terraform Version...: `terraform --version`"

    echo -e  "\e[92mDone!"
}

main 2>&1 | tee WSL-UbuntuScript.log