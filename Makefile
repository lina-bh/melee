HOST := melee

ETC := /etc/containers/systemd /etc/beets/config.yaml /etc/transmission-daemon/settings.json /etc/cockpit/cockpit.conf

NAME := ghcr.io/lina-bh/$(HOST)
TAG := latest

EXTRA_BUILD_ARGS :=

.PHONY: all
all:

.PHONY: build
build:
	podman build --rm=false --pull=newer --no-hosts --arch=amd64 --tag=$(NAME):$(LATEST) --layers=true --cache-to=$(NAME) --cache-from=$(NAME) $(EXTRA_BUILD_ARGS) .

.PHONY: push
push:
	podman push --format=oci $(NAME):$(TAG)

.PHONY: tag
tag:
	podman tag $(NAME):latest $(NAME):$(TAG)

.PHONY: run
run:
	podman run --rm -it --no-hostname --no-hosts --pull=never --entrypoint=bash $(NAME) -l -

.PHONY: copy
copy:
	rsync --recursive --links --verbose --delete-after --mkpath --relative $(foreach src,$(ETC),$(HOST):$(src)) system_files/
