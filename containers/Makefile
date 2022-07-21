#
# Linux container images Makefile
#
# Run `make` to build all linux container images
# Run `make spotfire-server` to build just spotfire-sever

DOCKER_CLI ?= docker
#DOCKER_CLI := podman
#DOCKER_CLI_BUILD_ARGS ?= --pull --no-cache # Any extra argument for 'docker build'
IMAGE_REPOSITORY_PREFIX ?= tibco
REGISTRY ?= $(error REGISTRY is unset)
DOWNLOADS_DIR ?= downloads

include ../versions.mk

IMAGE_BUILD_ID ?= $(CLOUD_DEPLOYMENT_KIT_VERSION)

# Images - Default target build: build all images
.SECONDEXPANSION : $(IMAGES)
IMAGES = spotfire-server spotfire-config spotfire-node-manager spotfire-base spotfire-workerhost spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice

# Files needed in image-dir/build by the various targets
.SECONDEXPANSION : $(BUILD_FILES)
BUILD_FILES = spotfire-config/build/tss-$(SPOTFIRE_SERVER_VERSION).x86_64.tar.gz \
              spotfire-node-manager/build/tsnm-$(SPOTFIRE_NODEMANAGER_VERSION).x86_64.tar.gz \
              spotfire-server/build/tss-$(SPOTFIRE_SERVER_VERSION).x86_64.tar.gz \
              spotfire-webplayer/build/Spotfire.Dxp.netcore-linux.sdn \
              spotfire-webplayer/build/TIB_sfire_server_$(SPOTFIRE_NETCORE_VERSION)_languagepack-multi.zip \
              spotfire-automationservices/build/Spotfire.Dxp.netcore-linux.sdn \
              spotfire-terrservice/build/Spotfire.Dxp.TerrServiceLinux.sdn \
              spotfire-pythonservice/build/Spotfire.Dxp.PythonServiceLinux.sdn

# Internal additional makefile rules
-include *.mk

build : BUILD_DATETIME = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
build : GIT_COMMIT_SHA = $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown"))
build : $(IMAGES)
build-files : $(BUILD_FILES)

# Build command
$(IMAGES) : IMAGE_BUILD_ARGS =
spotfire-server spotfire-config spotfire-node-manager spotfire-workerhost spotfire-webplayer spotfire-terrservice spotfire-automationservices spotfire-pythonservice : \
                                                                                        IMAGE_BUILD_ARGS =  "IMAGE_BUILD_ID=$(LOCAL_IMAGE_BUILD_ID)"
spotfire-pythonservice spotfire-terrservice spotfire-node-manager spotfire-workerhost : IMAGE_BUILD_ARGS += "SPOTFIRE_NODEMANAGER_VERSION=$(SPOTFIRE_NODEMANAGER_VERSION)"
spotfire-pythonservice :                                                                IMAGE_BUILD_ARGS += "SPOTFIRE_PYTHONSERVICE_VERSION=$(SPOTFIRE_PYTHONSERVICE_VERSION)"
spotfire-terrservice :                                                                  IMAGE_BUILD_ARGS += "SPOTFIRE_TERRSERVICE_VERSION=$(SPOTFIRE_TERRSERVICE_VERSION)"
spotfire-webplayer spotfire-automationservices :                                        IMAGE_BUILD_ARGS += "SPOTFIRE_NETCORE_VERSION=$(SPOTFIRE_NETCORE_VERSION)"
spotfire-server spotfire-config :                                                       IMAGE_BUILD_ARGS += "SPOTFIRE_SERVER_VERSION=$(SPOTFIRE_SERVER_VERSION)"

# TAGS -
# $(1): IMAGE_BUILD_ID
%potfire-automationservices : IMAGE_TAG  = $(SPOTFIRE_NETCORE_VERSION)-$(1)
%potfire-base :               IMAGE_TAG  = $(1)
%potfire-config :             IMAGE_TAG  = $(SPOTFIRE_SERVER_VERSION)-$(1)
%potfire-server :             IMAGE_TAG  = $(SPOTFIRE_SERVER_VERSION)-$(1)
%potfire-node-manager :       IMAGE_TAG  = $(SPOTFIRE_NODEMANAGER_VERSION)-$(1)
%potfire-workerhost :         IMAGE_TAG  = $(SPOTFIRE_NETCORE_VERSION)-$(1)
%potfire-pythonservice :      IMAGE_TAG  = $(SPOTFIRE_PYTHONSERVICE_VERSION)-$(1)
%potfire-terrservice :        IMAGE_TAG  = $(SPOTFIRE_TERRSERVICE_VERSION)-$(1)
%potfire-webplayer :          IMAGE_TAG  = $(SPOTFIRE_NETCORE_VERSION)-$(1)
# Used when building and pushing
LOCAL_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
LOCAL_IMAGE_TAG = $(call IMAGE_TAG,$(LOCAL_IMAGE_BUILD_ID))
# Used when promoting
SRC_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
SRC_IMAGE_TAG = $(call IMAGE_TAG,$(SRC_IMAGE_BUILD_ID))

$(IMAGES) :
	cd $@ && $(DOCKER_CLI) build $(DOCKER_CLI_BUILD_ARGS) $(addprefix --build-arg ,$(IMAGE_BUILD_ARGS)) --tag "$(IMAGE_REPOSITORY_PREFIX)/$@:$(LOCAL_IMAGE_TAG)" .

# Images dependencies
spotfire-server spotfire-config spotfire-node-manager : spotfire-base
spotfire-workerhost: spotfire-node-manager
spotfire-automationservices spotfire-webplayer : spotfire-workerhost
spotfire-terrservice spotfire-pythonservice : spotfire-node-manager

# Image should depend on all BUILD_FILES that start with path <IMAGE>/build/
$(IMAGES) : % : $$(filter %/$$(PERCENT),$(BUILD_FILES))
$(IMAGES) : PERCENT := %

$(BUILD_FILES) : % : $(DOWNLOADS_DIR)/$$(notdir %)
	cp -p "$<" "$@"

push : $(addprefix push-,$(IMAGES))
push-% : DEST_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
push-% : DEST_IMAGE_TAG = $(call IMAGE_TAG,$(DEST_IMAGE_BUILD_ID))
push-% :
	$(DOCKER_CLI) tag $(IMAGE_REPOSITORY_PREFIX)/$*:$(LOCAL_IMAGE_TAG) $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)
	$(DOCKER_CLI) push $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)

promote : DEST_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
promote : DEST_IMAGE_TAG = $(call IMAGE_TAG,$(DEST_IMAGE_BUILD_ID))
promote : $(addprefix promote-,$(IMAGES))
promote-% :
	$(DOCKER_CLI) pull $(IMAGE_REPOSITORY_PREFIX)/$*:$(SRC_IMAGE_TAG)
	$(DOCKER_CLI) tag $(IMAGE_REPOSITORY_PREFIX)/$*:$(SRC_IMAGE_TAG) $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)
	$(DOCKER_CLI) push $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)

clean :
	$(info Cleaning build directories)
	rm -f $(BUILD_FILES)
	rm -f **/build/*

.PHONY : build push push-% $(IMAGES) clean build-files promote
