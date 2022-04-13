SHELL                       = /bin/bash
.SHELLFLAGS                 = -o pipefail -c
.DEFAULT_GOAL 			    := package
	#
# Variables
PACKAGE_DIR                ?= packages
REPO_URL				   ?= # http://example.com/helm-repo/

# Charts to package
CHARTS                      = spotfire-common spotfire-fluentbit-configuration spotfire-server spotfire-terrservice spotfire-pythonservice

# See https://github.com/helm/helm/issues/4463
.NOTPARALLEL :

# Include additional makefile rules, if any
-include *.mk

# Targets
package : $(PACKAGE_DIR)/index.yaml

$(PACKAGE_DIR)/index.yaml : $(CHARTS)
	helm repo index $(addprefix --url ,$(REPO_URL)) $(PACKAGE_DIR)/

$(CHARTS) :
	helm dependency update charts/$@
	helm package charts/$@ -d $(PACKAGE_DIR)

clean :
	rm -rf -- $(PACKAGE_DIR)/
	find charts/ -name tmpcharts -type d -exec rm -rf -- {} \;
	find charts/ -wholename charts/*.tgz -exec rm -- {} \;

.PHONY: package $(PACKAGE_DIR)/index.yaml clean $(CHARTS)
	
# Chart dependencies
spotfire-server : spotfire-common
spotfire-terrservice spotfire-pythonservice : spotfire-common spotfire-fluentbit-configuration
