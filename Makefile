HOST := melee

ETC := /etc/containers/systemd /etc/copyparty/copyparty.conf /var/lib/navidrome/navidrome.toml /var/lib/slskd/slskd.yml /var/lib/prowlarr/config.xml

NAME := ghcr.io/lina-bh/$(HOST)
TAG := latest

DOCKER := podman

EXTRA_BUILD_ARGS :=

.PHONY: all
all:

.PHONY: build
build:
	$(DOCKER) build \
		--rm=false \
		--no-hosts \
		--arch=amd64 \
		--tag=$(NAME):latest \
		--layers=true \
		--cache-from=$(NAME) \
		--label=org.opencontainers.image.version="$(shell git log -n1 --oneline --no-decorate)" \
		--label=org.opencontainers.image.revision="$(shell git rev-parse HEAD)" \
		--annotation=org.opencontainers.image.version="$(shell git log -n1 --oneline --no-decorate)" \
		--annotation=org.opencontainers.image.revision="$(shell git rev-parse HEAD)" \
		$(EXTRA_BUILD_ARGS) .

.PHONY: push
push:
	$(DOCKER) push --format=oci --compression-format=zstd:chunked --compression-level=2 $(NAME):$(TAG)

.PHONY: tag
tag:
	$(DOCKER) tag $(NAME):latest $(NAME):$(TAG)

.PHONY:
tag_HEAD:
	$(MAKE) tag TAG=$(shell git rev-parse HEAD)

.PHONY:
push_HEAD: tag_HEAD
	$(MAKE) push TAG=$(shell git rev-parse HEAD)

.PHONY: run
run:
	$(DOCKER) run --rm -it --no-hostname --no-hosts --pull=never --entrypoint=bash $(NAME) -l -

.PHONY: copy
copy:
	rsync --recursive --links --verbose --delete-after --mkpath --relative $(foreach src,$(ETC),$(HOST):$(src)) system_files/
