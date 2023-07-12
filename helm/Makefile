SHELL=/bin/bash
.SHELLFLAGS                 = -o errexit -o pipefail -c
.DEFAULT_GOAL              := all

# Variables
PACKAGE_DIR                ?= packages
REPO_URL                   ?= # http://example.com/helm-repo/

# Charts to package
CHARTS                      = spotfire-common spotfire-server spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice

.PHONY: all $(CHARTS) documentation package $(PACKAGE_DIR)/index.yaml clean spotfire-umbrella-example

all : package spotfire-umbrella-example

# Targets
package : $(PACKAGE_DIR)/index.yaml

$(PACKAGE_DIR)/index.yaml : $(CHARTS)
	helm repo index $(addprefix --url ,$(REPO_URL)) $(PACKAGE_DIR)/

$(CHARTS) :
	helm dependency update charts/$@
	helm package charts/$@ -d $(PACKAGE_DIR)

# Chart dependencies
spotfire-server : spotfire-common
spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice: spotfire-common

clean :
	rm -rf -- $(PACKAGE_DIR)/
	find . -name tmpcharts -type d -exec rm -rf -- {} \;
	find . -wholename "*/charts/*.tgz" -exec rm -- {} \;
	find . -iname "*.lock" -type f -exec rm -rf -- {} \;

documentation :
	helm-docs --chart-search-root charts/

spotfire-umbrella-example : spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice spotfire-server
	helm dependency update examples/$@

# Test targets
include test.mk
