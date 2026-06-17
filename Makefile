HOST := melee

ETC := /etc/containers/systemd /etc/copyparty/copyparty.conf /var/lib/navidrome/navidrome.toml /var/lib/slskd/slskd.yml

NAME := ghcr.io/lina-bh/$(HOST)
TAG := latest

EXTRA_BUILD_ARGS :=

.PHONY: all
all:

.PHONY: build
build:
	podman build --rm=false --pull=newer --no-hosts --arch=amd64 --tag=$(NAME):latest --layers=true --cache-from=$(NAME) $(EXTRA_BUILD_ARGS) .

.PHONY: push
push:
	podman push --format=oci $(NAME):$(TAG)

.PHONY: tag
tag:
	podman tag $(NAME):latest $(NAME):$(TAG)

.PHONY:
tag_HEAD:
	$(MAKE) tag TAG=$(shell git rev-parse HEAD)

.PHONY:
push_HEAD: tag_HEAD
	$(MAKE) push TAG=$(shell git rev-parse HEAD)

.PHONY: run
run:
	podman run --rm -it --no-hostname --no-hosts --pull=never --entrypoint=bash $(NAME) -l -

.PHONY: copy
copy:
	rsync --recursive --links --verbose --delete-after --mkpath --relative $(foreach src,$(ETC),$(HOST):$(src)) system_files/
