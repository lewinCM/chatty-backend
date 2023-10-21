#!/bin/bash

function program_is_installed {
  local return_=1

  type $1 >/dev/null 2>&1 || { local return_=0; }
  echo "$return_"
}

sudo yum update -y
# sudo yum install ruby -y
# sudo yum install wget -y
# cd /home/ec2-user
# wget https://aws-codedeploy-eu-central-1.s3.eu-central-1.amazonaws.com/latest/install
# sudo chmod +x ./install
# sudo ./install auto


# sudo yum install https://rpm.nodesource.com/pub_16.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
# sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1

# sudo yum install https://rpm.nodesource.com/pub_18.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
# sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1



# sudo yum install https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
# sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1




# Check if NodeJs is installed. If not, install it
if [ $(program_is_installed node) == 0 ]; then
  sudo yum install https://rpm.nodesource.com/pub_16.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
  sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1

fi


# Check if NodeJs is installed. If not, install it
# if [ $(program_is_installed node) == 0 ]; then
#   curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
#   sudo yum install -y nodejs
# fi

if [ $(program_is_installed git) == 0 ]; then
  sudo yum install git -y
fi

if [ $(program_is_installed docker) == 0 ]; then
  sudo amazon-linux-extras install docker -y
  sudo systemctl start docker
  sudo docker run --name chatapp-redis -p 6379:6379 --restart always --detach redis
fi

if [ $(program_is_installed pm2) == 0 ]; then
  npm install -g pm2
fi

cd /home/ec2-user

git clone -b develop https://github.com/lewinCM/chatty-backend.git
cd chatty-backend
npm install
aws s3 sync s3://chattyapp-env-filess/develop .
unzip env-file.zip
cp .env.develop .env
npm run build
npm run start
