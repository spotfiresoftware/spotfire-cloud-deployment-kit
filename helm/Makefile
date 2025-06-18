SHELL          = /bin/bash
.SHELLFLAGS    = -o errexit -o pipefail -c
.DEFAULT_GOAL := build

PACKAGE_DIR   ?= packages
REPO_URL      ?= # http://example.com/helm-repo/

include ../versions.mk

# Charts to package
CHARTS := spotfire-common spotfire-server spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice spotfire-platform

# Define package file names for each chart
SPOTFIRE_SERVER_TGZ             := $(PACKAGE_DIR)/spotfire-server-$(SPOTFIRE_SERVER_CHART_VERSION).tgz
SPOTFIRE_WEBPLAYER_TGZ          := $(PACKAGE_DIR)/spotfire-webplayer-$(SPOTFIRE_WEBPLAYER_CHART_VERSION).tgz
SPOTFIRE_AUTOMATIONSERVICES_TGZ := $(PACKAGE_DIR)/spotfire-automationservices-$(SPOTFIRE_AUTOMATIONSERVICES_CHART_VERSION).tgz
SPOTFIRE_TERRSERVICE_TGZ        := $(PACKAGE_DIR)/spotfire-terrservice-$(SPOTFIRE_TERRSERVICE_CHART_VERSION).tgz
SPOTFIRE_PYTHONSERVICE_TGZ      := $(PACKAGE_DIR)/spotfire-pythonservice-$(SPOTFIRE_PYTHONSERVICE_CHART_VERSION).tgz
SPOTFIRE_RSERVICE_TGZ           := $(PACKAGE_DIR)/spotfire-rservice-$(SPOTFIRE_RSERVICE_CHART_VERSION).tgz
SPOTFIRE_PLATFORM_TGZ           := $(PACKAGE_DIR)/spotfire-platform-$(SPOTFIRE_PLATFORM_CHART_VERSION).tgz
SPOTFIRE_COMMON_TGZ             := $(PACKAGE_DIR)/spotfire-common-$(SPOTFIRE_COMMON_CHART_VERSION).tgz

CHART_PACKAGES = $(SPOTFIRE_SERVER_TGZ) $(SPOTFIRE_WEBPLAYER_TGZ) $(SPOTFIRE_AUTOMATIONSERVICES_TGZ) $(SPOTFIRE_TERRSERVICE_TGZ) $(SPOTFIRE_PYTHONSERVICE_TGZ) $(SPOTFIRE_RSERVICE_TGZ) $(SPOTFIRE_PLATFORM_TGZ)

# Define phony targets for each chart, $(CHARTS) to allow running 'make spotfire-server' etc.
.PHONY: build $(CHARTS) clean list push push-% documentation

# Main target to package all charts and update index.yaml
# Try -j to parallelize packaging but be aware of issues in helm - https://github.com/helm/helm/issues/10735
build : $(PACKAGE_DIR)/index.yaml $(CHART_PACKAGES)
$(PACKAGE_DIR)/index.yaml : $(CHART_PACKAGES)
	helm repo index $(addprefix --url ,$(REPO_URL)) $(PACKAGE_DIR)/

# Define dependencies for each chart to ensure subcharts are packaged first and to rebuild only when needed
spotfire-common $(SPOTFIRE_COMMON_TGZ)                         : $(wildcard charts/spotfire-common/*)
spotfire-server $(SPOTFIRE_SERVER_TGZ)                         : $(SPOTFIRE_COMMON_TGZ) $(wildcard charts/spotfire-server/*)
spotifre-webplayer $(SPOTFIRE_WEBPLAYER_TGZ)                   : $(SPOTFIRE_COMMON_TGZ) $(wildcard charts/spotfire-webplayer/*)
spotfire-automationservices $(SPOTFIRE_AUTOMATIONSERVICES_TGZ) : $(SPOTFIRE_COMMON_TGZ) $(wildcard charts/spotfire-automationservices/*)
spotfire-terrservice $(SPOTFIRE_TERRSERVICE_TGZ)               : $(SPOTFIRE_COMMON_TGZ) $(wildcard charts/spotfire-terrservice/*)
spotfire-pythonservice $(SPOTFIRE_PYTHONSERVICE_TGZ)           : $(SPOTFIRE_COMMON_TGZ) $(wildcard charts/spotfire-pythonservice/*)
spotfire-rservice $(SPOTFIRE_RSERVICE_TGZ)                     : $(SPOTFIRE_COMMON_TGZ) $(wildcard charts/spotfire-rservice/*)
spotfire-platform $(SPOTFIRE_PLATFORM_TGZ)                     : $(SPOTFIRE_COMMON_TGZ) $(SPOTFIRE_SERVER_TGZ) $(SPOTFIRE_WEBPLAYER_TGZ) $(SPOTFIRE_AUTOMATIONSERVICES_TGZ) $(SPOTFIRE_TERRSERVICE_TGZ) $(SPOTFIRE_PYTHONSERVICE_TGZ) $(SPOTFIRE_RSERVICE_TGZ) $(wildcard charts/spotfire-platform/*)

# Package each chart, the chart-name is inferred from packaged chart tgz name
# e.g. chart-name for '$(PACKAGE_DIR)/spotfire-server-1.0.0.tgz' becomes 'spotfire-server'
$(CHART_PACKAGES) $(SPOTFIRE_COMMON_TGZ) : chart-name = $(shell basename $@ .tgz | sed 's/-[0-9]*\.[0-9]*\.[0-9]*//')
$(CHART_PACKAGES) $(SPOTFIRE_COMMON_TGZ) :
	helm package -u charts/$(chart-name) --destination $(PACKAGE_DIR)

push : HELM_OCI_REGISTRY ?= $(error HELM_OCI_REGISTRY must be set e.g. oci://registry.example.com/)
push : $(addprefix push-,$(CHARTS))
push-% : $(PACKAGE_DIR)/%-*.tgz
	helm push $(^) $(HELM_OCI_REGISTRY) $(HELM_PUSH_FLAGS)

list : 
	@echo $(CHARTS)

documentation :
	helm-docs --document-dependency-values --chart-search-root .

clean :
	rm -rf -- $(PACKAGE_DIR)/
	find . -name tmpcharts -type d -exec rm -rf -- {} \;
	find . -wholename "*/charts/*.tgz" -exec rm -- {} \;
	find . -iname "*.lock" -type f -exec rm -rf -- {} \;

# Test targets for each chart
# Charts will rebuild automatically before tests, but build them manually once first.
.PHONY : kubeconform kubeconform-% lint lint-% template template-% test test-% notes notes-%

# Extract the chart name from the target stem and find the test values for the chart
TEST_VALUES  = $(wildcard charts/$(*)/test/*-values.yaml)
TEST_CHARTS := $(filter-out spotfire-common,$(CHARTS))

# Run 'command' with newline at the end
define run
$(command)

endef

test : $(addprefix test-,$(TEST_CHARTS))
test-% : lint-% template-% kubeconform-%
	@echo Test of chart $* completed.

lint : $(CHART_PACKAGES) $(addprefix lint-,$(TEST_CHARTS))
lint-% : command = helm lint charts/$* --values $(v)
lint-% : $(wildcard $(PACKAGE_DIR)/%-*.tgz)
	$(foreach v, $(TEST_VALUES), $(run))

# Set VALIDATE=0 to skip validating against running a kubernetes cluster
template : $(CHART_PACKAGES) $(addprefix template-,$(TEST_CHARTS))
template-% : command = helm template $(if $(filter 1,$(VALIDATE)),--validate,) charts/$* --values $(v)
template-% : $(wildcard $(PACKAGE_DIR)/%-*.tgz)
	$(foreach v, $(TEST_VALUES), $(run))

kubeconform : $(CHART_PACKAGES) $(addprefix kubeconform-,$(TEST_CHARTS))
kubeconform-% : command = helm template charts/$* --values $(v) | kubeconform -summary -ignore-missing-schemas
kubeconform-% : $(wildcard $(PACKAGE_DIR)/%-*.tgz)
	$(foreach v, $(TEST_VALUES), $(run))

notes : $(CHART_PACKAGES) $(addprefix notes-,$(TEST_CHARTS))
notes-% : command = helm install --generate-name --dry-run --render-subchart-notes charts/$* --values $(v)
notes-% : $(wildcard $(PACKAGE_DIR)/%-*.tgz)
	$(foreach v, $(TEST_VALUES), $(run))