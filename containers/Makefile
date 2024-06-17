#
# Linux container images Makefile
#
# Run `make` to build all linux container images
# Run `make spotfire-server` to build just spotfire-server
SHELL                       = /bin/bash
.SHELLFLAGS                 = -o pipefail -c

.DEFAULT_GOAL               = build

DOCKER_CLI ?= docker# podman
DOCKER_CLI_BUILD_ARGS ?= # --no-cache
IMAGE_REPOSITORY_PREFIX ?= spotfire
DOWNLOADS_DIR ?= downloads
IMAGES_DIR ?= images

include ../versions.mk
include build-files.mk

#
# Image dependencies
#

.SECONDEXPANSION : $(IMAGE_TARGETS)

IMAGE_TARGETS = spotfire-server spotfire-config spotfire-nodemanager spotfire-base spotfire-workerhost \
                spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice \
                spotfire-rservice spotfire-deployment

spotfire-server spotfire-config spotfire-nodemanager spotfire-deployment : spotfire-base
spotfire-terrservice spotfire-pythonservice spotfire-rservice            : spotfire-nodemanager
spotfire-workerhost                                                      : spotfire-nodemanager
spotfire-automationservices spotfire-webplayer                           : spotfire-workerhost

NONLOCAL_TARGETS = $(filter-out spotfire-workerhost spotfire-nodemanager spotfire-base,$(IMAGE_TARGETS))

.PHONY : $(IMAGE_TARGETS)

#
# Build files - copy files from downloads/ to images/<imagename>/build
#

# Image should depend on all BUILD_FILES that start with path images/<imagename>/build/
$(IMAGE_TARGETS) : % : $$(filter images/%/$$(PERCENT),$(BUILD_FILES))
$(IMAGE_TARGETS) : PERCENT := %

$(BUILD_FILES) : % : $(DOWNLOADS_DIR)/$$(notdir %)
	cp -p "$<" "$@"

downloads-list : DOWNLOADS_FILES = $(addprefix $(DOWNLOADS_DIR)/,$(sort $(foreach file,$(BUILD_FILES),$(notdir $(file)))))
downloads-list :
	@$(foreach file,$(DOWNLOADS_FILES),echo $(file);)

build-files : $(BUILD_FILES)

.PHONY : build-files downloads-list

#
# Docker cli build and arguments
#

.PHONY : build
build : $(IMAGE_TARGETS)

$(IMAGE_TARGETS) : BUILD_TAG_ARGUMENT = $(IMAGE_REPOSITORY_PREFIX)/$(@):$(IMAGE_TAG)
$(IMAGE_TARGETS) : BUILD_ARGS = $(DOCKER_CLI_BUILD_ARGS) $(addprefix --build-arg ,$(IMAGE_BUILD_ARGS))
$(IMAGE_TARGETS) :
	$(DOCKER_CLI) build $(BUILD_ARGS) --tag $(BUILD_TAG_ARGUMENT) $(IMAGES_DIR)/$(@)

# TAG_SUFFIX can be used to override *_CONTAINER_ITERATION
TAG_SUFFIX ?= $(or $1,$(IMAGE_BUILD_ID))

SPOTFIRE_AUTOMATIONSERVICES_IMAGE_TAG   = $(SPOTFIRE_NETCORE_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_AUTOMATIONSERVICES_CONTAINER_ITERATION)))
SPOTFIRE_BASE_IMAGE_TAG                 = $(or $(IMAGE_BUILD_ID),base)
SPOTFIRE_CONFIG_IMAGE_TAG               = $(SPOTFIRE_SERVER_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_CONFIG_CONTAINER_ITERATION)))
SPOTFIRE_SERVER_IMAGE_TAG               = $(SPOTFIRE_SERVER_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_SERVER_CONTAINER_ITERATION)))
SPOTFIRE_NODEMANAGER_IMAGE_TAG          = $(or $(IMAGE_BUILD_ID),nodemanager)
SPOTFIRE_WORKERHOST_IMAGE_TAG           = $(or $(IMAGE_BUILD_ID),workerhost)
SPOTFIRE_PYTHONSERVICE_IMAGE_TAG        = $(SPOTFIRE_PYTHONSERVICE_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_PYTHONSERVICE_CONTAINER_ITERATION)))
SPOTFIRE_TERRSERVICE_IMAGE_TAG          = $(SPOTFIRE_TERRSERVICE_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_TERRSERVICE_CONTAINER_ITERATION)))
SPOTFIRE_RSERVICE_IMAGE_TAG             = $(SPOTFIRE_RSERVICE_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_RSERVICE_CONTAINER_ITERATION)))
SPOTFIRE_WEBPLAYER_IMAGE_TAG            = $(SPOTFIRE_NETCORE_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_WEBPLAYER_CONTAINER_ITERATION)))
SPOTFIRE_DEPLOYMENT_IMAGE_TAG           = $(SPOTFIRE_DEPLOYMENT_VERSION)$(addprefix -,$(or $(TAG_SUFFIX),$(SPOTFIRE_WEBPLAYER_CONTAINER_ITERATION)))

%potfire-automationservices : IMAGE_TAG = $(SPOTFIRE_AUTOMATIONSERVICES_IMAGE_TAG)
%potfire-base :               IMAGE_TAG = $(SPOTFIRE_BASE_IMAGE_TAG)
%potfire-config :             IMAGE_TAG = $(SPOTFIRE_CONFIG_IMAGE_TAG)
%potfire-server :             IMAGE_TAG = $(SPOTFIRE_SERVER_IMAGE_TAG)
%potfire-nodemanager :        IMAGE_TAG = $(SPOTFIRE_NODEMANAGER_IMAGE_TAG)
%potfire-workerhost :         IMAGE_TAG = $(SPOTFIRE_WORKERHOST_IMAGE_TAG)
%potfire-pythonservice :      IMAGE_TAG = $(SPOTFIRE_PYTHONSERVICE_IMAGE_TAG)
%potfire-terrservice :        IMAGE_TAG = $(SPOTFIRE_TERRSERVICE_IMAGE_TAG)
%potfire-rservice :           IMAGE_TAG = $(SPOTFIRE_RSERVICE_IMAGE_TAG)
%potfire-webplayer :          IMAGE_TAG = $(SPOTFIRE_WEBPLAYER_IMAGE_TAG)
%potfire-deployment :         IMAGE_TAG = $(SPOTFIRE_DEPLOYMENT_IMAGE_TAG)

# --build-arg image tags
$(IMAGE_TARGETS) :                                                         IMAGE_BUILD_ARGS =
spotfire-base:                                                             IMAGE_BUILD_ARGS += $(addprefix DEBIAN_IMAGE_TAG=,$(DEBIAN_IMAGE_TAG))
spotfire-server spotfire-config spotfire-nodemanager spotfire-deployment : IMAGE_BUILD_ARGS += "SPOTFIRE_BASE_IMAGE_TAG=$(SPOTFIRE_BASE_IMAGE_TAG)"
spotfire-pythonservice spotfire-terrservice spotfire-rservice :            IMAGE_BUILD_ARGS += "SPOTFIRE_NODEMANAGER_IMAGE_TAG=$(SPOTFIRE_NODEMANAGER_IMAGE_TAG)"
spotfire-workerhost :                                                      IMAGE_BUILD_ARGS += "SPOTFIRE_NODEMANAGER_IMAGE_TAG=$(SPOTFIRE_NODEMANAGER_IMAGE_TAG)"
spotfire-webplayer spotfire-automationservices :                           IMAGE_BUILD_ARGS += "SPOTFIRE_WORKERHOST_IMAGE_TAG=$(SPOTFIRE_WORKERHOST_IMAGE_TAG)"

# --build-arg product versions
spotfire-nodemanager :                                                     IMAGE_BUILD_ARGS += "SPOTFIRE_NODEMANAGER_VERSION=$(SPOTFIRE_NODEMANAGER_VERSION)"
spotfire-server spotfire-config :                                          IMAGE_BUILD_ARGS += "SPOTFIRE_SERVER_VERSION=$(SPOTFIRE_SERVER_VERSION)"
spotfire-webplayer spotfire-automationservices :                           IMAGE_BUILD_ARGS += "SPOTFIRE_NETCORE_VERSION=$(SPOTFIRE_NETCORE_VERSION)"
spotfire-webplayer spotfire-automationservices spotfire-deployment :       IMAGE_BUILD_ARGS += "SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION=$(SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION)"
spotfire-terrservice :                                                     IMAGE_BUILD_ARGS += "SPOTFIRE_TERRSERVICE_VERSION=$(SPOTFIRE_TERRSERVICE_VERSION)"
spotfire-rservice :                                                        IMAGE_BUILD_ARGS += "SPOTFIRE_RSERVICE_VERSION=$(SPOTFIRE_RSERVICE_VERSION)"
spotfire-pythonservice :                                                   IMAGE_BUILD_ARGS += "SPOTFIRE_PYTHONSERVICE_VERSION=$(SPOTFIRE_PYTHONSERVICE_VERSION)"

#
# tag, push, list
#
# REMOTE_IMAGE_BUILD_ID: push this destination build id
# LOCAL_IMAGE_BUILD_ID: push this source build id

REMOTE_IMAGE_REFERENCE    = $(addsuffix /,$(CONTAINER_REGISTRY))$(IMAGE_REPOSITORY_PREFIX)/$(*):$(call IMAGE_TAG,$(REMOTE_IMAGE_BUILD_ID))
LOCAL_IMAGE_REFERENCE     = $(IMAGE_REPOSITORY_PREFIX)/$(*):$(call IMAGE_TAG,$(LOCAL_IMAGE_BUILD_ID))

push : $(addprefix push-,$(NONLOCAL_TARGETS))
push-% : CONTAINER_REGISTRY ?= $(error CONTAINER_REGISTRY is unset)
push-% :
	$(DOCKER_CLI) tag $(LOCAL_IMAGE_REFERENCE) $(REMOTE_IMAGE_REFERENCE)
	$(DOCKER_CLI) push $(REMOTE_IMAGE_REFERENCE)
	$(DOCKER_CLI) rmi $(REMOTE_IMAGE_REFERENCE)

# make CONTAINER_REGISTRY=registry.com list
list-images : $(addprefix list-image-,$(NONLOCAL_TARGETS))
list-images : $(if $(ALL),$(addprefix list-image-,$(IMAGE_TARGETS)))
list-image-% :
	@echo $(REMOTE_IMAGE_REFERENCE)

# source <(make --silent list-tags)
list-tags : create_var_assignment = $(if $(filter $(EXPORT),1),export ,)$(shell echo '$(*)' | tr '[:lower:]-' '[:upper:]_')_$(1)=$(2)
list-tags : $(addprefix list-tag-,$(NONLOCAL_TARGETS))
list-tag-% :
	@echo $(call create_var_assignment,IMAGE_TAG,$(IMAGE_TAG))

.PHONY : push push-% list list-%
	
#
# additional targets
#
licenses licenses-% : LICENSE_DIR = licenses/$(*)
licenses : $(addprefix licenses-,$(filter-out spotfire-base spotfire-deployment,$(NONLOCAL_TARGETS)))
	$(info Licenses exported to $(LICENSE_DIR))
	@find $(LICENSE_DIR) -type f
licenses-% :
	mkdir -p $(LICENSE_DIR)
	tc=$$($(DOCKER_CLI) create "$(IMAGE_REPOSITORY_PREFIX)/$(*):$(IMAGE_TAG)"); \
	$(DOCKER_CLI) export $${tc} | tar --strip-components=3 -C $(LICENSE_DIR) --wildcards -x "*license.pdf"; \
	$(DOCKER_CLI) rm $${tc}

# echos the value of given variable
# make variable VAR=SPOTFIRE_DEPLOYMENT_VERSION
variable :
	@echo "$(value $(VAR))"

clean :
	for image in $$(make list-images ALL=true --silent); do \
		$(DOCKER_CLI) image inspect $$image >/dev/null 2>&1 && $(DOCKER_CLI) rmi $${image};\
	done || :
	rm -f $(BUILD_FILES)
	rm -f $(IMAGES_DIR)/**/build/*
	rm -rf licenses/

.PHONY : clean licenses licenses-% variable
