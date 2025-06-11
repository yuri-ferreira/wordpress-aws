#!/bin/bash
sudo yum update -y
sudo yum install -y nfs-utils docker

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user


sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sleep 15

sudo mkdir -p /mnt/efs
sudo mount -t efs -o tls,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,nofail fs-1111111111111:/ /mnt/efs

sudo mkdir -p /mnt/efs/html
sudo chown -R 33:33 /mnt/efs/html
sudo chmod -R 775 /mnt/efs/html 

mkdir -p /home/ec2-user/wordpress-app
cd /home/ec2-user/wordpress-app

cat <<EOF > docker-compose.yaml
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress-na-aws
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: 
      WORDPRESS_DB_NAME: 
      WORDPRESS_DB_USER: 
      WORDPRESS_DB_PASSWORD: 
    volumes:
      - /mnt/efs/html:/var/www/html
EOF

sleep 15
docker compose up -d
