FROM quay.io/fedora/fedora-iot:44@sha256:6bb547e2ad195c5e7f96cd4d93516787c2fa5d2f07dbeaf8e303df1cb4b3e1f9 AS fedora

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    dnf5 -y config-manager setopt 'fedora-cisco-openh264*'.enabled=0

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    --mount=type=tmpfs,destination=/run \
    curl -fL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo && \
    sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/tailscale.repo

RUN rm -r /opt && mkdir -p /var/opt && ln -s /var/opt /opt && \
    rm -r /usr/local && mkdir -p /var/usrlocal && ln -s /var/usrlocal /usr/local && \
    setsebool -P container_use_dri_devices=1 container_use_devices=1

COPY ./build_files/packages /tmp/packages
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    --mount=type=tmpfs,destination=/run \
    dnf5 -y config-manager setopt keepcache=True && \
    dnf -y --setopt='tailscale*'.enabled=1 install tailscale && \
    dnf -y --setopt=install_weak_deps=False install $(cat /tmp/packages) && rm /tmp/packages && \
    dnf5 -y config-manager setopt keepcache=False

COPY --from=ghcr.io/ublue-os/brew:latest@sha256:60ada2d65891d8797beef49d8b43f2108519cbbaf04c9c7363e1a008677fcd35 /system_files /
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=tmpfs,destination=/var/log \
    systemctl preset brew-setup.service && \
    systemctl preset brew-update.timer && \
    systemctl preset brew-upgrade.timer

COPY ./system_files/ /

RUN bootc container lint
