FROM quay.io/fedora/fedora-iot:43

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    curl -fL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo && \
    dnf5 -y config-manager setopt 'tailscale*'.enabled=0 && \
    dnf5 -y --setopt='tailscale*'.enabled=1 install tailscale && \
    systemctl enable tailscaled.service

RUN systemctl enable \
        bootc-fetch-apply-updates.timer \
        podman-auto-update.timer \
        podman-restart.service \
        && \
    systemctl mask \
        ModemManager.service \
        && \
    echo 'containers:524288:65536' > /etc/subuid && \
    echo 'containers:524288:65536' > /etc/subgid && \
    setsebool -P container_use_dri_devices=1 container_use_devices=1

RUN --mount=type=cache,destination=/var/cache \
    --mount=type=cache,destination=/var/lib/dnf \
    --mount=type=tmpfs,destination=/var/log \
    dnf5 -y config-manager setopt 'fedora-cisco-openh264*'.enabled=0 && \
    dnf5 -y --setopt=install_weak_deps=False install \
        beets \
        btrfs-progs \
        cockpit-{files,machines,networkmanager,storaged,system} \
        distrobox \
        ffmpeg \
        git-core \
        gobject-introspection \
        g++ \
        htop \
        intel-gpu-firmware \
        mandoc \
        neovim \
        netcat \
        pciutils \
        pipx \
        python3-devel \
        qemu-char-spice \
        rsync \
        usbutils \
        uv \
        libvirt-daemon-driver-storage-logical \
        libvirt-nss \
        udisks2{,-btrfs,-lvm2} \
    && :

COPY ./system_files/ /

RUN bootc container lint
