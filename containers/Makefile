#
# Linux container images Makefile
#
# Run `make` to build all linux container images
# Run `make spotfire-server` to build just spotfire-server
SHELL                       = /bin/bash
.SHELLFLAGS                 = -o pipefail -c

DOCKER_CLI ?= docker
#DOCKER_CLI := podman
#DOCKER_CLI_BUILD_ARGS ?= --pull --no-cache # Any extra argument for 'docker build'
IMAGE_REPOSITORY_PREFIX ?= spotfire
DOWNLOADS_DIR ?= downloads
IMAGES_DIR ?= images

include ../versions.mk
include build-files.mk

build-files : $(BUILD_FILES)

IMAGE_BUILD_ID ?= $(CLOUD_DEPLOYMENT_KIT_VERSION)

# Images - Default target build: build all images
.SECONDEXPANSION : $(IMAGE_TARGETS)
IMAGE_TARGETS = spotfire-server spotfire-config spotfire-nodemanager spotfire-base spotfire-workerhost \
				spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice \
				spotfire-rservice spotfire-deployment


.DEFAULT_GOAL := build
build : $(IMAGE_TARGETS)

# Build command
$(IMAGE_TARGETS) : IMAGE_BUILD_ARGS =
spotfire-base:                                   IMAGE_BUILD_ARGS =  $(addprefix DEBIAN_TAG=,$(DEBIAN_TAG))
spotfire-server spotfire-config spotfire-nodemanager spotfire-workerhost spotfire-webplayer spotfire-terrservice spotfire-automationservices spotfire-pythonservice spotfire-rservice spotfire-deployment : \
                                                 IMAGE_BUILD_ARGS =  "IMAGE_BUILD_ID=$(LOCAL_IMAGE_BUILD_ID)"
spotfire-deployment :                            IMAGE_BUILD_ARGS += "SPOTFIRE_DEPLOYMENT_VERSION=$(SPOTFIRE_DEPLOYMENT_VERSION)"
spotfire-rservice :                              IMAGE_BUILD_ARGS += "SPOTFIRE_RSERVICE_VERSION=$(SPOTFIRE_RSERVICE_VERSION)"
spotfire-deployment :                            IMAGE_BUILD_ARGS += "SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION=$(SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION)"
spotfire-pythonservice :                         IMAGE_BUILD_ARGS += "SPOTFIRE_PYTHONSERVICE_VERSION=$(SPOTFIRE_PYTHONSERVICE_VERSION)"
spotfire-pythonservice spotfire-terrservice spotfire-rservice spotfire-nodemanager spotfire-workerhost : \
                                                 IMAGE_BUILD_ARGS += "SPOTFIRE_NODEMANAGER_VERSION=$(SPOTFIRE_NODEMANAGER_VERSION)"
spotfire-server spotfire-config :                IMAGE_BUILD_ARGS += "SPOTFIRE_SERVER_VERSION=$(SPOTFIRE_SERVER_VERSION)"
spotfire-terrservice :                           IMAGE_BUILD_ARGS += "SPOTFIRE_TERRSERVICE_VERSION=$(SPOTFIRE_TERRSERVICE_VERSION)"
spotfire-webplayer spotfire-automationservices : IMAGE_BUILD_ARGS += "SPOTFIRE_NETCORE_VERSION=$(SPOTFIRE_NETCORE_VERSION)"
spotfire-webplayer :                             IMAGE_BUILD_ARGS += "SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION=$(SPOTFIRE_NETCORE_LANGUAGEPACKS_VERSION)"


# TAGS -
# $(1): IMAGE_BUILD_ID
%-spotfire-automationservices spotfire-automationservices : IMAGE_TAG  = $(SPOTFIRE_NETCORE_VERSION)-$(1)
%-spotfire-base spotfire-base :                             IMAGE_TAG  = $(1)
%-spotfire-config spotfire-config :                         IMAGE_TAG  = $(SPOTFIRE_SERVER_VERSION)-$(1)
%-spotfire-server spotfire-server :                         IMAGE_TAG  = $(SPOTFIRE_SERVER_VERSION)-$(1)
%-spotfire-nodemanager spotfire-nodemanager :             IMAGE_TAG  = $(SPOTFIRE_NODEMANAGER_VERSION)-$(1)
%-spotfire-workerhost spotfire-workerhost :                 IMAGE_TAG  = $(SPOTFIRE_NETCORE_VERSION)-$(1)
%-spotfire-pythonservice spotfire-pythonservice :           IMAGE_TAG  = $(SPOTFIRE_PYTHONSERVICE_VERSION)-$(1)
%-spotfire-terrservice spotfire-terrservice :               IMAGE_TAG  = $(SPOTFIRE_TERRSERVICE_VERSION)-$(1)
%-spotfire-rservice spotfire-rservice :                     IMAGE_TAG  = $(SPOTFIRE_RSERVICE_VERSION)-$(1)
%-spotfire-webplayer spotfire-webplayer :                   IMAGE_TAG  = $(SPOTFIRE_NETCORE_VERSION)-$(1)
%-spotfire-deployment spotfire-deployment :                 IMAGE_TAG  = $(SPOTFIRE_DEPLOYMENT_VERSION)-$(1)

# Used when building and pushing
LOCAL_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
LOCAL_IMAGE_TAG = $(call IMAGE_TAG,$(LOCAL_IMAGE_BUILD_ID))
# Used when promoting
SRC_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
SRC_IMAGE_TAG = $(call IMAGE_TAG,$(SRC_IMAGE_BUILD_ID))

$(IMAGE_TARGETS) : IMAGENAME = $(IMAGE_REPOSITORY_PREFIX)/$(@):$(LOCAL_IMAGE_TAG)
$(IMAGE_TARGETS) : BUILD_ARGS = $(DOCKER_CLI_BUILD_ARGS) $(addprefix --build-arg ,$(IMAGE_BUILD_ARGS))
$(IMAGE_TARGETS) :
	$(DOCKER_CLI) build $(BUILD_ARGS) --tag $(IMAGENAME) $(IMAGES_DIR)/$(@)

# make REGISTRY=registry.com list
list : IMAGENAME = $(@:list-%=%)
list : TAG = $(IMAGE_REPOSITORY_PREFIX)/$(IMAGENAME):$(LOCAL_IMAGE_TAG)
list : $(addprefix list-,$(IMAGE_TARGETS))
list-% :
	@echo $(addsuffix /,$(REGISTRY))$(TAG)

# Images dependencies
spotfire-server spotfire-config spotfire-nodemanager spotfire-deployment : spotfire-base
spotfire-workerhost : spotfire-nodemanager
spotfire-automationservices spotfire-webplayer : spotfire-workerhost
spotfire-terrservice spotfire-pythonservice spotfire-rservice : spotfire-nodemanager

# Image should depend on all BUILD_FILES that start with path images/<IMAGE>/build/
$(IMAGE_TARGETS) : % : $$(filter images/%/$$(PERCENT),$(BUILD_FILES))
$(IMAGE_TARGETS) : PERCENT := %

$(BUILD_FILES) : % : $(DOWNLOADS_DIR)/$$(notdir %)
	cp -p "$<" "$@"

downloads-list : DOWNLOADS_FILES = $(addprefix $(DOWNLOADS_DIR)/,$(sort $(foreach file,$(BUILD_FILES),$(notdir $(file)))))
downloads-list :
	@$(foreach file,$(DOWNLOADS_FILES),echo $(file);)

push promote : REGISTRY ?= $(error REGISTRY is unset)
push : REMOTE_TARGET = $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$(@:push-%=%):$(DEST_IMAGE_TAG)
push : $(addprefix push-,$(IMAGE_TARGETS))
push-spotfire-% : DEST_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
push-spotfire-% : DEST_IMAGE_TAG = $(call IMAGE_TAG,$(DEST_IMAGE_BUILD_ID))
push-spotfire-% :
	$(DOCKER_CLI) tag $(IMAGE_REPOSITORY_PREFIX)/$(@:push-%=%):$(LOCAL_IMAGE_TAG) $(REMOTE_TARGET)
	$(DOCKER_CLI) push $(REMOTE_TARGET)

promote : DEST_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
promote : DEST_IMAGE_TAG = $(call IMAGE_TAG,$(DEST_IMAGE_BUILD_ID))
promote : $(addprefix promote-,$(IMAGE_TARGETS))
promote-% :
	$(DOCKER_CLI) pull $(IMAGE_REPOSITORY_PREFIX)/$*:$(SRC_IMAGE_TAG)
	$(DOCKER_CLI) tag $(IMAGE_REPOSITORY_PREFIX)/$*:$(SRC_IMAGE_TAG) $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)
	$(DOCKER_CLI) push $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)

licenses licenses-% : LICENSE_DIR = licenses/$(*)
licenses : $(addprefix licenses-,$(filter-out spotfire-base spotfire-deployment,$(IMAGE_TARGETS)))
	$(info Licenses exported to $(LICENSE_DIR))
	@find $(LICENSE_DIR) -type f
licenses-% :
	mkdir -p $(LICENSE_DIR)
	tc=$$($(DOCKER_CLI) create "$(IMAGE_REPOSITORY_PREFIX)/$(*):$(LOCAL_IMAGE_TAG)"); \
	$(DOCKER_CLI) export $${tc} | tar --strip-components=3 -C $(LICENSE_DIR) --wildcards -x "*license.pdf"; \
	$(DOCKER_CLI) rm $${tc}

clean :
	$(info Cleaning build directories)
	rm -f $(BUILD_FILES)
	rm -f $(IMAGES_DIR)/**/build/*
	rm -rf licenses/

.PHONY : build push push-% $(IMAGE_TARGETS) clean build-files licenses licenses-% list list-% downloads-list
