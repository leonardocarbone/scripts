#!/bin/bash


install_asdf()
{
	echo " "
    read -p "Install ASDF & Plugins. Press ENTER to continue"

	ASDF_VERSION="v0.10.2"
	ASDF_RUBY_VERSION="3.1.3"
	ASDF_PYTHON_VERSION="3.11.0"
    ASDF_NODEJS_VERSION="17.9.1"
    ASDF_DOTNETCORE_VERSION="6.0.403"
	ASDF_TERRAFORM_VERSION="1.3.5"
	ASDF_AWS_VAULT_VERSION="6.6.0"
	

    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $ASDF_VERSION
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
    echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
    . $HOME/.asdf/asdf.sh
    . $HOME/.asdf/completions/asdf.bash

	
	asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
    asdf install ruby $ASDF_RUBY_VERSION
    asdf global ruby $ASDF_RUBY_VERSION
	
	asdf plugin-add python
	asdf install python $ASDF_PYTHON_VERSION
	asdf global python $ASDF_PYTHON_VERSION

    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf install nodejs $ASDF_NODEJS_VERSION
    asdf global nodejs $ASDF_NODEJS_VERSION
    npm i -g npm

    asdf plugin-add dotnet-core https://github.com/emersonsoares/asdf-dotnet-core.git
    asdf install dotnet-core $ASDF_DOTNETCORE_VERSION
    asdf global dotnet-core $ASDF_DOTNETCORE_VERSION
	
	asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git
	asdf install terraform $ASDF_TERRAFORM_VERSION
	asdf global terraform $ASDF_TERRAFORM_VERSION
	
	asdf plugin-add aws-vault https://github.com/karancode/asdf-aws-vault.git
	asdf install aws-vault $ASDF_AWS_VAULT_VERSION
	asdf global aws-vault $ASDF_AWS_VAULT_VERSION	
}

install_aws()
{
	echo " "
    read -p "Install AWS CLI & CDK. Press ENTER to continue"

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
	mkdir ~/.aws/
    #echo -e '\nexport AWS_DEFAULT_REGION=eu-west-1' >> ~/.bashrc
    #source ~/.bashrc

    rm -rf aws
    rm awscliv2.zip

    npm install -g aws-cdk
}


## Deprecated - Replaced with Starship
install_ohmyposh()
{
	echo " "
	read -p "Install OH-MY-POSH. Press ENTER to continue"
	
	sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
	sudo chmod +x /usr/local/bin/oh-my-posh
	
	mkdir ~/.poshthemes
	wget https://raw.githubusercontent.com/leonardocarbone/dotfiles/main/.oh-my-posh.json -O ~/.poshthemes/.oh-my-posh.json
	#wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
	#unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
	#chmod u+rw ~/.poshthemes/*.omp.*
	#rm ~/.poshthemes/themes.zip
	
	echo -e '\neval "$(oh-my-posh init bash --config $HOME/.poshthemes/.oh-my-posh.omp.json)"' >> ~/.bashrc
}

configure_awsvault()
{
	echo " "
	read -p "Configure AWS-Vault. Press ENTER to continue"
	
	read -p "AWS Region: " aws_region
	read -p "AWS Profile Name: " aws_profile_name	
	read -p "AWS MFA Serial: " aws_mfa_serial
	read -p "AWS Role ARN: " aws_role_arn
	
	
	CONFIG_FILE=~/.aws/config
	if [ -f "$CONFIG_FILE" ]; then
		rm $CONFIG_FILE
	fi
	
	echo -e "[profile $aws_profile_name]\nregion = $aws_region\nmfa_serial = $aws_mfa_serial\nrole_arn = $aws_role_arn" >> $CONFIG_FILE
	
	echo -e '\nexport AWS_VAULT_BACKEND=pass' >> ~/.bashrc
	echo -e "\nalias aws-login='aws-vault exec $aws_profile_name'"  >> ~/.bashrc
	
	echo " "
	gpg --full-generate-key
	
	echo " "
	read -p "Enter gpg-key above:" gpgid
	pass init $gpgid
	
	echo " "
	aws-vault --backend=pass add $aws_profile_name
}

configure_github_key()
{
	echo " "
	read -p "Configure GitHub Key. Press ENTER to continue"
	
	ssh-keygen -t ed25519 -C "githubkey" -f $HOME/.ssh/github_ed25519
	
	echo -e '\neval "$(ssh-agent -s)"'  >> ~/.bashrc
	echo -e 'ssh-add $HOME/.ssh/github_ed25519'  >> ~/.bashrc	
}

create_symlink()
{
	ln -s /mnt/d/Dropbox/Dev $HOME/dev
}


install_packages()
{
	sudo apt update -y
	sudo apt upgrade -y	
	sudo apt install -y tree unzip build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev zlib1g-dev libffi-dev pass gpg
	
	install_asdf
	install_aws	
	configure_awsvault
	configure_github_key
	install_ohmyposh
}

clear

echo -e 'echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null' >>  ~/.bashrc

install_packages

#create_symlink


echo " "
echo "Ruby Version........: `ruby --version`"
echo "Python Version......: `python -V`"
echo "Node Version........: `node --version`"
echo "DotNetCore Version..: `dotnet --version`"
echo "Terraform Version...: `terraform --version`"
echo "AWS Vault Version...: `aws-vault --version`"
echo "AWS CLI Version.....: `aws --version`"
echo "AWS CDK Version.....: `cdk --version`"
echo " "
	
exec bash