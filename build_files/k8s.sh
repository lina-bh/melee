#!/bin/sh
set -eux
: "${KUBERNETES_RELEASE:=1.35}"
cat >/etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes ${KUBERNETES_RELEASE}
baseurl=https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_RELEASE}/rpm/
enabled=0
gpgcheck=0
gpgkey=https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_RELEASE}/rpm/repodata/repomd.xml.key
EOF
mkdir -p /opt/cni/bin
# --setopt=kubernetes.enabled=1
exec dnf5 -y install \
  "cri-o${KUBERNETES_RELEASE}" \
  "kubernetes${KUBERNETES_RELEASE}-kubeadm"
