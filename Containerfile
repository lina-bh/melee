FROM quay.io/fedora/fedora-iot:44@sha256:f3058175f250e6893c2d21ae5f6ae17dc92c7a1de796510505ccd0899588a05e AS fedora

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

COPY --from=ghcr.io/ublue-os/brew:latest@sha256:9449d3ce4bec06b815dcf33bc5547cc76204317a59df01c511c63063679ec90a /system_files /
RUN --mount=type=cache,destination=/var/cache \
    --mount=type=tmpfs,destination=/var/log \
    systemctl preset brew-setup.service && \
    systemctl preset brew-update.timer && \
    systemctl preset brew-upgrade.timer

COPY ./system_files/ /

RUN bootc container lint
