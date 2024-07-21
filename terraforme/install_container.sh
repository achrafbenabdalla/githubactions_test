#!/bin/bash

# Log the start of the script
echo "Starting installation script for SonarQube, Prometheus, Grafana, and Node Exporter..." | tee -a /tmp/install_containers.log

# Update system and install Docker
echo "Updating system and installing Docker..." | tee -a /tmp/install_containers.log
sudo apt update -y
sudo apt install docker.io -y
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl start docker
sudo systemctl enable docker

# Run SonarQube in Docker
echo "Running SonarQube in Docker..." | tee -a /tmp/install_containers.log
sudo docker run -d --name sonarqube -p 9000:9000 sonarqube:lts

# Run Prometheus in Docker
echo "Running Prometheus in Docker..." | tee -a /tmp/install_containers.log
sudo docker run -d --name prometheus -p 9090:9090 prom/prometheus

# Run Grafana in Docker
echo "Running Grafana in Docker..." | tee -a /tmp/install_containers.log
sudo docker run -d --name grafana -p 3000:3000 grafana/grafana

# Install Node Exporter and Create Service for Node Exporter
echo "Installing Node Exporter and setting up service..." | tee -a /tmp/install_containers.log
sudo useradd --system --no-create-home --shell /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter*
sudo cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Log the completion of the script
echo "Script execution completed." | tee -a /tmp/install_containers.log
