# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Master node configuration
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/jammy64"
    master.vm.hostname = "k3s-master"
    master.vm.network "private_network", ip: "192.168.56.10"
    
    master.vm.provider "virtualbox" do |vb|
      vb.name = "k3s-master"
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    
    master.vm.provision "shell", inline: <<-SHELL
      # Update system
      apt-get update
      apt-get install -y curl wget git vim htop
      
      # Install Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      usermod -aG docker vagrant
      
      # Install kubectl
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      mv kubectl /usr/local/bin/
      
      # Create directories for offline images
      mkdir -p /home/vagrant/offline-images
      mkdir -p /home/vagrant/registry
      
      # Set up local registry
      docker run -d --name registry -p 5000:5000 --restart=always registry:2
      
      echo "Master node setup complete!"
    SHELL
  end

  # Worker node configuration
  config.vm.define "worker" do |worker|
    worker.vm.box = "ubuntu/jammy64"
    worker.vm.hostname = "k3s-worker"
    worker.vm.network "private_network", ip: "192.168.56.11"
    
    worker.vm.provider "virtualbox" do |vb|
      vb.name = "k3s-worker"
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    
    worker.vm.provision "shell", inline: <<-SHELL
      # Update system
      apt-get update
      apt-get install -y curl wget git vim htop
      
      # Install Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      usermod -aG docker vagrant
      
      # Create directories for offline images
      mkdir -p /home/vagrant/offline-images
      
      echo "Worker node setup complete!"
    SHELL
  end
end
