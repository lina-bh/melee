FROM quay.io/fedora/fedora-iot:43

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    dnf5 -y config-manager setopt 'fedora-cisco-openh264*'.enabled=0

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    curl -fL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo && \
    dnf5 -y config-manager setopt 'tailscale*'.enabled=0 && \
    dnf5 -y --setopt='tailscale*'.enabled=1 install tailscale

RUN setsebool -P container_use_dri_devices=1 container_use_devices=1

COPY ./build_files/packages /tmp/packages
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    dnf5 -y --setopt=install_weak_deps=False install $(cat /tmp/packages)

ENV KUBERNETES_RELEASE=1.35
COPY ./build_files/k8s.sh /tmp/k8s.sh
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    sh /tmp/k8s.sh

COPY ./system_files/ /

RUN bootc container lint
