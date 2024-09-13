#!/bin/bash

set -x

sudo cp /tmp/tf-packer.pub /home/ec2-user/.ssh/authorized_keys
sudo chmod 600 /home/ec2-user/.ssh/authorized_keys

sudo yum update
sudo yum install -y firewalld
sudo systemctl enable firewalld --now
sudo firewall-cmd --permanent --zone=public --add-port=6443/tcp --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --zone=public --add-port=10251/tcp
sudo firewall-cmd --permanent --zone=public --add-port=10252/tcp
sudo firewall-cmd --permanent --zone=public --add-port=10250/tcp
sudo firewall-cmd --permanent --zone=public --add-port=30000-32767/tcp
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
sudo firewall-cmd --permanent --zone=public --add-port=22/tcp
sudo firewall-cmd --reload

sudo modprobe overlay
sudo modprobe br_netfilter
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

sudo yum install -y containerd
sudo mkdir  -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo yum update
sudo yum install -y kubelet.x86_64 0:1.31.0-150500.1.1 kubeadm.x86_64 0:1.31.0-150500.1.1 kubectl.x86_64 0:1.31.0-150500.1.1 --disableexcludes=kubernetes --disableplugin=priorities
sudo yum versionlock add kubelet kubeadm kubectl

sudo systemctl enable --now containerd
sudo ctr image pull registry.k8s.io/pause:3.10
