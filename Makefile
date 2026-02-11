HOST := melee

ETC := /etc/containers/systemd /etc/beets/config.yaml /etc/transmission-daemon/settings.json /etc/cockpit/cockpit.conf

NAME := ghcr.io/lina-bh/$(HOST)

.PHONY: all
all:

.PHONY: build
build:
	podman build --rm=false --pull=newer --no-hosts --arch=amd64 --retry=0 --tag $(NAME) --layers=true .

.PHONY: push
push:
	podman push $(NAME)

.PHONY: run
run:
	podman run --rm -it --no-hostname --no-hosts --pull=never --entrypoint=bash $(NAME) -l -

.PHONY: copy
copy:
	rsync --recursive --links --verbose --delete-after --mkpath --relative $(foreach src,$(ETC),$(HOST):$(src)) system_files/
