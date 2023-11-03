#!/usr/bin/env bash

###
### Tested Ubuntu 20.04
### curl -sSL https://raw.githubusercontent.com/leonardocarbone/scripts/master/ubuntu_postinstall.sh | bash
###

install_asdf() {
	echo " "
	#read -p "Install ASDF & Plugins. Press ENTER to continue"

	ASDF_VERSION="v0.13.1"

	ASDF_PLUGINS=("yq" "jq" "terraform" "awscli" "aws-vault" "python" "ruby" "nodejs" "dotnet" "powershell-core")

	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $ASDF_VERSION
	echo -e '\n. $HOME/.asdf/asdf.sh' >>~/.bashrc
	echo -e '\n. $HOME/.asdf/completions/asdf.bash' >>~/.bashrc
	. $HOME/.asdf/asdf.sh
	. $HOME/.asdf/completions/asdf.bash

	echo " "

	for plugin in ${ASDF_PLUGINS[@]}; do
		#echo "[INFO] ... Installing ASDF Plugin '$plugin'"

		asdf plugin add $plugin
		asdf install $plugin latest
		asdf global $plugin latest

		echo " "
	done
}

install_ohmyposh() {
	echo " "
	#read -p "Install OH-MY-POSH. Press ENTER to continue"

	sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
	sudo chmod +x /usr/local/bin/oh-my-posh

	mkdir ~/.poshthemes
	wget https://raw.githubusercontent.com/leonardocarbone/dotfiles/main/.oh-my-posh.json -O ~/.poshthemes/.oh-my-posh.json
	wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
	unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
	chmod u+rw ~/.poshthemes/*.omp.*
	rm ~/.poshthemes/themes.zip

	echo -e '\neval "$(oh-my-posh init bash --config $HOME/.poshthemes/.oh-my-posh.json)"' >>~/.bashrc
}

configure_awsvault() {
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

	echo -e "[profile $aws_profile_name]\nregion = $aws_region\nmfa_serial = $aws_mfa_serial\nrole_arn = $aws_role_arn" >>$CONFIG_FILE

	echo -e '\nexport AWS_VAULT_BACKEND=pass' >>~/.bashrc
	echo -e "\nalias aws-login='aws-vault exec $aws_profile_name'" >>~/.bashrc

	echo " "
	gpg --full-generate-key

	echo " "
	read -p "Enter gpg-key above:" gpgid
	pass init $gpgid

	echo " "
	aws-vault --backend=pass add $aws_profile_name
}

configure_github_key() {
	echo " "
	#read -p "Configure GitHub Key. Press ENTER to continue"

	ssh-keygen -t ed25519 -C "githubkey" -f $HOME/.ssh/github_ed25519 -N ""

	echo -e '\neval "$(ssh-agent -s)"' >>~/.bashrc
	echo -e 'ssh-add $HOME/.ssh/github_ed25519' >>~/.bashrc
}

install_packages() {
	sudo apt update -y
	sudo apt upgrade -y
	sudo apt install -y tree unzip build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev zlib1g-dev libffi-dev pass gpg libbz2-dev lzma sqlite3 libreadline-dev libyaml-dev

	install_ohmyposh
	install_asdf
	#configure_awsvault
	configure_github_key

	npm install -g aws-cdk

}

clear

#echo -e 'echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null' >>  ~/.bashrc

install_packages

git config --global user.email "myemail@gmail.com"
git config --global user.name "My Name"

asdf list

echo " "
echo "Ruby Version........: $(ruby --version)"
echo "Python Version......: $(python -V)"
echo "Node Version........: $(node --version)"
echo "DotNetCore Version..: $(dotnet --version)"
echo "Terraform Version...: $(terraform --version)"
echo "AWS Vault Version...: $(aws-vault --version)"
echo "AWS CLI Version.....: $(aws --version)"
echo "AWS CDK Version.....: $(cdk --version)"
echo "YQ Version..........: $(yq --version)"
echo "JQ Version..........: $(jq --version)"
echo " "

exec bash
