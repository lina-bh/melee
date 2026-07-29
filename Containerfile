FROM quay.io/fedora/fedora-iot:44@sha256:917991f78b300cf2564aad7c7afda37ad7a12bf7aadbcde0101f36367b0fae1a AS fedora

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    dnf5 -y config-manager setopt 'fedora-cisco-openh264*'.enabled=0

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    --mount=type=tmpfs,destination=/run \
    curl -fL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo && \
    sed -i 's/^enabled=1/enabled=0/' /etc/yum.repos.d/tailscale.repo && \
    dnf -y --setopt='tailscale*'.enabled=1 install tailscale

RUN rm -r /opt && mkdir -p /var/opt && ln -s /var/opt /opt && \
    rm -r /usr/local && mkdir -p /var/usrlocal && ln -s /var/usrlocal /usr/local && \
    setsebool -P container_use_dri_devices=1 container_use_devices=1

COPY ./build_files/packages /tmp/packages
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    --mount=type=tmpfs,destination=/run \
    dnf5 -y --setopt=install_weak_deps=False install $(cat /tmp/packages) && rm /tmp/packages

COPY --from=ghcr.io/ublue-os/brew:latest@sha256:07799dfe9ed44812a63d1b23c74e3e30b758a976f647032d916c34daf30f60a4 /system_files /
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=tmpfs,destination=/var/log \
    systemctl preset brew-setup.service && \
    systemctl preset brew-update.timer && \
    systemctl preset brew-upgrade.timer

COPY ./system_files/ /

RUN bootc container lint
