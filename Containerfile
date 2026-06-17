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

RUN rm -r /opt && mkdir -p /var/opt && ln -s /var/opt /opt && \
    rm -r /usr/local && mkdir -p /var/usrlocal && ln -s /var/usrlocal /usr/local && \
    setsebool -P container_use_dri_devices=1 container_use_devices=1

COPY ./build_files/packages /tmp/packages
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    dnf5 -y --setopt=install_weak_deps=False install $(cat /tmp/packages)

COPY ./system_files/ /

RUN bootc container lint
