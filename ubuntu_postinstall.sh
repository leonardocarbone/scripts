#!/usr/bin/env bash

###
### Tested Ubuntu 20.04
### curl -sSL https://raw.githubusercontent.com/leonardocarbone/scripts/master/ubuntu_postinstall.sh -o ubuntu_postinstall.sh && bash ubuntu_postinstall.sh
###

install_asdf() {
	echo " "
	#read -p "Install ASDF & Plugins. Press ENTER to continue"

	ASDF_VERSION="v0.13.1"

        ASDF_PLUGINS=("yq@4.40.1" "jq@1.7" "terraform@1.6.3" "awscli@2.13.33" "aws-vault@7.2.0" "python@3.12.0" "ruby@3.2.2" "nodejs@18.18.2" "dotnet@7.0.403" "powershell-core@7.3.9")

	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $ASDF_VERSION
	echo -e '\n. $HOME/.asdf/asdf.sh' >>~/.bashrc
	echo -e '\n. $HOME/.asdf/completions/asdf.bash' >>~/.bashrc
	. $HOME/.asdf/asdf.sh
	. $HOME/.asdf/completions/asdf.bash

	echo " "

        OLD_IFS="$IFS"
	for plugin_version in ${ASDF_PLUGINS[@]}; do
		#echo "[INFO] ... Installing ASDF Plugin '$plugin'"

                IFS="@"
                read -ra tmparr <<< "$plugin_version"
                plugin=${tmparr[0]}
                version=${tmparr[1]}
		
                asdf plugin add $plugin
                asdf install $plugin $version
                asdf global $plugin $version

		echo " "
                IFS="$OLD_IFS"
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

	mkdir -p $HOME/.aws
 
	CONFIG_FILE=$HOME/.aws/config
	if [ -f "$CONFIG_FILE" ]; then
		rm $CONFIG_FILE
	fi

	echo -e "[profile $aws_profile_name]\nregion = $aws_region\nmfa_serial = $aws_mfa_serial\nrole_arn = $aws_role_arn" >>$CONFIG_FILE

	echo -e '\nexport AWS_VAULT_BACKEND=pass' >>~/.bashrc
	echo -e "\nalias aws-cli='aws-vault exec $aws_profile_name -- aws'" >> ~/.bashrc 
 	echo -e "\nalias awslogin='aws-vault exec $aws_profile_name'" >> ~/.bashrc 

	echo " "
	gpg --full-generate-key

	echo " "
	read -p "Enter gpg-key above:" gpgid
	pass init $gpgid

	echo " "
	aws-vault --backend=pass add $aws_profile_name
}

configure_git() {
	echo " "

 	read -p "GIT Config. Press ENTER to continue"
 
 	read -p "User Email: " git_user_email
	read -p "User Name: " git_user_name

 	git config --global user.email "$git_user_email"
  	git config --global user.name "$git_user_name"
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
	sudo apt install -y tree unzip build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev zlib1g-dev libffi-dev pass gpg libbz2-dev lzma sqlite3 libreadline-dev libyaml-dev ntpdate

	install_ohmyposh
	install_asdf
	npm install -g aws-cdk
}


#echo -e 'echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null' >>  ~/.bashrc

install_packages
configure_git
configure_github_key
configure_awsvault

echo -e "\nalias upd-clock='sudo ntpdate time.windows.com'" >> ~/.bashrc
echo -e "\nalias tfvalidate='terraform validate'" >> ~/.bashrc
echo -e "\nalias tffmt='terraform fmt -recursive .'" >> ~/.bashrc
echo -e "\nalias tfplan='terraform plan -out=terraform.tfplan'" >> ~/.bashrc
echo -e "\nalias tfapply='terraform apply -auto-approve terraform.tfplan'" >> ~/.bashrc
echo -e "\nalias tfdestroy='terraform apply -destroy'" >> ~/.bashrc
echo -e "\nalias tftest='terraform test'" >> ~/.bashrc


asdf current
