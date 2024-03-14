SHELL=/bin/bash
.SHELLFLAGS                 = -o errexit -o pipefail -c
.DEFAULT_GOAL              := package

# Variables
PACKAGE_DIR                ?= packages
REPO_URL                   ?= # http://example.com/helm-repo/

# Charts to package
CHARTS                      = spotfire-common spotfire-server spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice

.PHONY: $(CHARTS) documentation package $(PACKAGE_DIR)/index.yaml clean

# Targets
package : $(PACKAGE_DIR)/index.yaml
$(PACKAGE_DIR)/index.yaml : $(CHARTS) spotfire-umbrella-example
	helm repo index $(addprefix --url ,$(REPO_URL)) $(PACKAGE_DIR)/

$(CHARTS) :
	helm dependency update charts/$@
	helm package charts/$@ -d $(PACKAGE_DIR)

push : HELM_PUSH_REMOTE ?= $(error HELM_PUSH_REMOTE must be set e.g. oci://registry.example.com/)
push : $(PACKAGE_DIR)/*.tgz
	for chart in $^; do \
		helm push $${chart} $(HELM_PUSH_REMOTE) $(HELM_PUSH_FLAGS); \
	done


spotfire-umbrella-example :
	helm dependency update examples/$@
	helm package examples/$@ -d $(PACKAGE_DIR)

all : package

# Chart dependencies
spotfire-server : spotfire-common
spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice: spotfire-common
spotfire-umbrella-example : spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice spotfire-server

clean :
	rm -rf -- $(PACKAGE_DIR)/
	find . -name tmpcharts -type d -exec rm -rf -- {} \;
	find . -wholename "*/charts/*.tgz" -exec rm -- {} \;
	find . -iname "*.lock" -type f -exec rm -rf -- {} \;

documentation :
	helm-docs --chart-search-root charts/

# Test targets
include test.mk
