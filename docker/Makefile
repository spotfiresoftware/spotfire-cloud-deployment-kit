#
# Linux container images Makefile
#
# Run `make` to build all linux container images
# Run `make spotfire-server` to build just spotfire-sever

BUILDER ?= docker
#BUILDER := podman
IMAGE_REPOSITORY_PREFIX ?= tibco
REGISTRY ?= $(error REGISTRY is unset)
DOWNLOADS_DIR ?= downloads

include ../versions.mk

# Images - Default target build: build all images
.SECONDEXPANSION : $(IMAGES)
IMAGES = spotfire-server spotfire-config spotfire-node-manager spotfire-base spotfire-terrservice spotfire-pythonservice

# Files needed in image-dir/build by the various targets
.SECONDEXPANSION : $(BUILD_FILES)
BUILD_FILES = spotfire-config/build/tss-$(SPOTFIRE_SERVER_VERSION).x86_64.tar.gz \
              spotfire-node-manager/build/tsnm-$(SPOTFIRE_NODEMANAGER_VERSION).x86_64.tar.gz \
              spotfire-server/build/tss-$(SPOTFIRE_SERVER_VERSION).x86_64.tar.gz \
              spotfire-terrservice/build/Spotfire.Dxp.TerrServiceLinux.sdn \
              spotfire-pythonservice/build/Spotfire.Dxp.PythonServiceLinux.sdn

# Internal additional makefile rules
-include *.mk

build : $(IMAGES)
build-files : $(BUILD_FILES)

# Build command
$(IMAGES) : BUILD_ARGS =
spotfire-server spotfire-config spotfire-node-manager spotfire-terrservice spotfire-pythonservice: BUILD_ARGS = "IMAGE_BUILD_ID=$(LOCAL_IMAGE_BUILD_ID)"

spotfire-pythonservice spotfire-terrservice spotfire-node-manager:  BUILD_ARGS += "SPOTFIRE_NODEMANAGER_VERSION=$(SPOTFIRE_NODEMANAGER_VERSION)"
spotfire-server spotfire-config : BUILD_ARGS += "SPOTFIRE_SERVER_VERSION=$(SPOTFIRE_SERVER_VERSION)"

# TAGS - 
# $(1): IMAGE_BUILD_ID
%potfire-base :               IMAGE_TAG  = $(1)
%potfire-config :             IMAGE_TAG  = $(SPOTFIRE_SERVER_VERSION)-$(1)
%potfire-server :             IMAGE_TAG  = $(SPOTFIRE_SERVER_VERSION)-$(1)
%potfire-node-manager :       IMAGE_TAG  = $(SPOTFIRE_NODEMANAGER_VERSION)-$(1)
%potfire-pythonservice :      IMAGE_TAG  = $(SPOTFIRE_PYTHONSERVICE_VERSION)-$(1)
%potfire-terrservice :        IMAGE_TAG  = $(SPOTFIRE_TERRSERVICE_VERSION)-$(1)
# Used when building and pushing
LOCAL_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
LOCAL_IMAGE_TAG = $(call IMAGE_TAG,$(LOCAL_IMAGE_BUILD_ID))
# Used when promoting
SRC_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
SRC_IMAGE_TAG = $(call IMAGE_TAG,$(SRC_IMAGE_BUILD_ID))

$(IMAGES) :
	cd $@ && $(BUILDER) build $(addprefix --build-arg ,$(BUILD_ARGS)) --tag "$(IMAGE_REPOSITORY_PREFIX)/$@:$(LOCAL_IMAGE_TAG)" .

# Images dependencies
spotfire-server spotfire-config spotfire-node-manager : spotfire-base
spotfire-terrservice spotfire-pythonservice : spotfire-node-manager

# Image should depend on all BUILD_FILES that start with path <IMAGE>/build/
$(IMAGES) : % : $$(filter %/$$(PERCENT),$(BUILD_FILES))
$(IMAGES) : PERCENT := %

$(BUILD_FILES) : % : $(DOWNLOADS_DIR)/$$(notdir %)
	cp -p "$<" "$@"

push : DEST_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
push : DEST_IMAGE_TAG = $(call IMAGE_TAG,$(DEST_IMAGE_BUILD_ID))
push : $(addprefix push-,$(IMAGES))
push-% :
	$(BUILDER) tag $(IMAGE_REPOSITORY_PREFIX)/$*:$(LOCAL_IMAGE_TAG) $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)
	$(BUILDER) push $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)

promote : DEST_IMAGE_BUILD_ID ?= $(IMAGE_BUILD_ID)
promote : DEST_IMAGE_TAG = $(call IMAGE_TAG,$(DEST_IMAGE_BUILD_ID))
promote : $(addprefix promote-,$(IMAGES))
promote-% :
	$(BUILDER) pull $(IMAGE_REPOSITORY_PREFIX)/$*:$(SRC_IMAGE_TAG)
	$(BUILDER) tag $(IMAGE_REPOSITORY_PREFIX)/$*:$(SRC_IMAGE_TAG) $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)
	$(BUILDER) push $(REGISTRY)/$(IMAGE_REPOSITORY_PREFIX)/$*:$(DEST_IMAGE_TAG)

clean :
	$(info Cleaning build directories)
	rm -f $(BUILD_FILES)
	rm -f **/build/*

.PHONY : build push push-% $(IMAGES) clean build-files promote
