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
ARCH_TARGET := linux/amd64

include ../versions.mk
include build-files.mk

#
# Image dependencies
#

.SECONDEXPANSION : $(IMAGE_TARGETS)

IMAGE_TARGETS += spotfire-server spotfire-config spotfire-nodemanager spotfire-base spotfire-workerhost \
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
	$(DOCKER_CLI) build --platform $(ARCH_TARGET) $(BUILD_ARGS) --tag $(BUILD_TAG_ARGUMENT) $(IMAGES_DIR)/$(@)

# TAG_SUFFIX can be called with an optional argument to override IMAGE_BUILD_ID when requiring different values, useful when pushing images
TAG_SUFFIX = v$(SPOTFIRE_CDK_VERSION)$(addprefix -,$(or $(1),$(IMAGE_BUILD_ID)))

space = $() $()

SPOTFIRE_AUTOMATIONSERVICES_IMAGE_TAG   = $(subst $(space),-,$(SPOTFIRE_NETCORE_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_BASE_IMAGE_TAG                 = $(subst $(space),-,$(TAG_SUFFIX))
SPOTFIRE_CONFIG_IMAGE_TAG               = $(subst $(space),-,$(SPOTFIRE_SERVER_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_SERVER_IMAGE_TAG               = $(subst $(space),-,$(SPOTFIRE_SERVER_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_NODEMANAGER_IMAGE_TAG          = $(subst $(space),-,$(SPOTFIRE_NODEMANAGER_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_WORKERHOST_IMAGE_TAG           = $(subst $(space),-,$(SPOTFIRE_NETCORE_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_PYTHONSERVICE_IMAGE_TAG        = $(subst $(space),-,$(SPOTFIRE_PYTHONSERVICE_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_TERRSERVICE_IMAGE_TAG          = $(subst $(space),-,$(SPOTFIRE_TERRSERVICE_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_RSERVICE_IMAGE_TAG             = $(subst $(space),-,$(SPOTFIRE_RSERVICE_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_WEBPLAYER_IMAGE_TAG            = $(subst $(space),-,$(SPOTFIRE_NETCORE_VERSION)-$(TAG_SUFFIX))
SPOTFIRE_DEPLOYMENT_IMAGE_TAG           = $(subst $(space),-,$(SPOTFIRE_DEPLOYMENT_VERSION)-$(TAG_SUFFIX))

%potfire-server            : IMAGE_TAG = $(SPOTFIRE_SERVER_IMAGE_TAG)
%potfire-config            : IMAGE_TAG = $(SPOTFIRE_CONFIG_IMAGE_TAG)
%potfire-nodemanager       : IMAGE_TAG = $(SPOTFIRE_NODEMANAGER_IMAGE_TAG)
%potfire-base              : IMAGE_TAG = $(SPOTFIRE_BASE_IMAGE_TAG)
%potfire-workerhost        : IMAGE_TAG = $(SPOTFIRE_WORKERHOST_IMAGE_TAG)
%potfire-webplayer         : IMAGE_TAG = $(SPOTFIRE_WEBPLAYER_IMAGE_TAG)
%potfire-automationservices: IMAGE_TAG = $(SPOTFIRE_AUTOMATIONSERVICES_IMAGE_TAG)
%potfire-terrservice       : IMAGE_TAG = $(SPOTFIRE_TERRSERVICE_IMAGE_TAG)
%potfire-pythonservice     : IMAGE_TAG = $(SPOTFIRE_PYTHONSERVICE_IMAGE_TAG)
%potfire-rservice          : IMAGE_TAG = $(SPOTFIRE_RSERVICE_IMAGE_TAG)
%potfire-deployment        : IMAGE_TAG = $(SPOTFIRE_DEPLOYMENT_IMAGE_TAG)

# --build-arg image tags
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
spotfire-deployment :                                                      IMAGE_BUILD_ARGS += "SPOTFIRE_DEPLOYMENT_VERSION=$(SPOTFIRE_DEPLOYMENT_VERSION)"
spotfire-terrservice :                                                     IMAGE_BUILD_ARGS += "SPOTFIRE_TERRSERVICE_VERSION=$(SPOTFIRE_TERRSERVICE_VERSION)"
spotfire-rservice :                                                        IMAGE_BUILD_ARGS += "SPOTFIRE_RSERVICE_VERSION=$(SPOTFIRE_RSERVICE_VERSION)"
spotfire-pythonservice :                                                   IMAGE_BUILD_ARGS += "SPOTFIRE_PYTHONSERVICE_VERSION=$(SPOTFIRE_PYTHONSERVICE_VERSION)"

# tag, push, list
#
# DEST_IMAGE_BUILD_ID: push this destination build id
# SOURCE_IMAGE_BUILD_ID: push this source build id
# SOURCE_CONTAINER_REGISTRY
# DEST_CONTAINER_REGISTRY
DEST_CONTAINER_REGISTRY ?= $(CONTAINER_REGISTRY)

DEST_IMAGE_REFERENCE    = $(addsuffix /,$(DEST_CONTAINER_REGISTRY))$(IMAGE_REPOSITORY_PREFIX)/$(*):$(call IMAGE_TAG,$(DEST_IMAGE_BUILD_ID))
SOURCE_IMAGE_REFERENCE  = $(addsuffix /,$(SOURCE_CONTAINER_REGISTRY))$(IMAGE_REPOSITORY_PREFIX)/$(*):$(call IMAGE_TAG,$(SOURCE_IMAGE_BUILD_ID))

push : $(addprefix push-,$(NONLOCAL_TARGETS))
# push-% : CONTAINER_REGISTRY ?= $(error CONTAINER_REGISTRY is unset)
push-% :
	$(DOCKER_CLI) tag $(SOURCE_IMAGE_REFERENCE) $(DEST_IMAGE_REFERENCE)
	$(DOCKER_CLI) push $(DEST_IMAGE_REFERENCE)
	$(DOCKER_CLI) rmi $(DEST_IMAGE_REFERENCE)

# make CONTAINER_REGISTRY=registry.com list
list-images : $(addprefix list-image-,$(NONLOCAL_TARGETS))
list-image-% :
	@echo $(DEST_IMAGE_REFERENCE)

# source <(make --silent list-tags)
list-tags : create_var_assignment = $(if $(filter $(EXPORT),1),export ,)$(shell echo '$(*)' | tr '[:lower:]-' '[:upper:]_')_$(1)=$(2)
list-tags : $(addprefix list-tag-,$(NONLOCAL_TARGETS))
list-tag-% :
	@echo $(call create_var_assignment,IMAGE_TAG,$(IMAGE_TAG))

# pull + push can be used to copy images from one place to the other
# 1. make pull --dry-run IMAGE_BUILD_ID=<source-tag> CONTAINER_REGISTRY=<source-registry>
# 2. SOURCE_IMAGE_BUILD_ID=<source-tag> IMAGE_BUILD_ID= make push --dry-run CONTAINER_REGISTRY=<destination-registry>
pull : $(addprefix pull-,$(NONLOCAL_TARGETS))
pull-% :
	$(DOCKER_CLI) pull $(DEST_IMAGE_REFERENCE)

tag : $(addprefix tag-,$(NONLOCAL_TARGETS))
tag-% :
	$(DOCKER_CLI) tag $(SOURCE_IMAGE_REFERENCE) $(DEST_IMAGE_REFERENCE)

.PHONY : push push-% list list-% tag tag-%
	
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
	@echo "$($(VAR))"

clean : $(addprefix clean-,$(NONLOCAL_TARGETS))
	rm -f $(BUILD_FILES)
	rm -f $(IMAGES_DIR)/**/build/*
	rm -rf licenses/

clean-% :
	$(DOCKER_CLI) rmi $(DEST_IMAGE_REFERENCE) 2>/dev/null || :

.PHONY : clean clean-% licenses licenses-% variable
