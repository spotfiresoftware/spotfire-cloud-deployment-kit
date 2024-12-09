SHELL=/bin/bash
.SHELLFLAGS                 = -o errexit -o pipefail -c
.DEFAULT_GOAL              := package

# Variables
PACKAGE_DIR                ?= packages
REPO_URL                   ?= # http://example.com/helm-repo/

# Charts to package
CHARTS                      = spotfire-common spotfire-server spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice spotfire-platform
PUBLIC_CHARTS 				= $(filter-out spotfire-common,$(CHARTS))

.PHONY: $(CHARTS) documentation package $(PACKAGE_DIR)/index.yaml clean list

# Targets
package : $(PACKAGE_DIR)/index.yaml
package-% : %
	helm package charts/$* -d $(PACKAGE_DIR)
$(PACKAGE_DIR)/index.yaml : $(CHARTS) $(addprefix package-,$(PUBLIC_CHARTS))
	helm repo index $(addprefix --url ,$(REPO_URL)) $(PACKAGE_DIR)/

$(CHARTS) :
	helm dependency update charts/$@

push : HELM_OCI_REGISTRY ?= $(error HELM_OCI_REGISTRY must be set e.g. oci://registry.example.com/)
push : $(PACKAGE_DIR)/*.tgz
	for chart in $^; do \
		helm push $${chart} $(HELM_OCI_REGISTRY) $(HELM_PUSH_FLAGS); \
	done

list : 
	@echo $(PUBLIC_CHARTS)

all : package

# Chart dependencies
spotfire-server : spotfire-common
spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice: spotfire-common
spotfire-platform : spotfire-webplayer spotfire-automationservices spotfire-terrservice spotfire-pythonservice spotfire-rservice spotfire-server

clean :
	rm -rf -- $(PACKAGE_DIR)/
	find . -name tmpcharts -type d -exec rm -rf -- {} \;
	find . -wholename "*/charts/*.tgz" -exec rm -- {} \;
	find . -iname "*.lock" -type f -exec rm -rf -- {} \;

documentation :
	helm-docs --document-dependency-values --chart-search-root .

test : $(addprefix test-,$(PUBLIC_CHARTS))
test-% : lint-% template-% kubeconform-%
	@echo Test of chart $* completed.

lint : $(addprefix lint-,$(PUBLIC_CHARTS))
lint-% :
	$(foreach v, $(wildcard charts/$*/test/*-values.yaml), \
		helm lint charts/$* --values $(v); \
	)

# Set to VALIDATE=1 validate against running kubernetes cluster
templat% : VALIDATE ?= 1
template : $(addprefix template-,$(PUBLIC_CHARTS))
template-% :
	$(foreach v, $(wildcard charts/$*/test/*-values.yaml), \
		helm template $(if $(filter 1,$(VALIDATE)),--validate,) charts/$* --values $(v); \
	)

kubeconform : $(addprefix kubeconform-,$(PUBLIC_CHARTS))
kubeconform-% :
	$(foreach v, $(wildcard charts/$*/test/*-values.yaml), \
		helm template charts/$* --values $(v) | kubeconform -summary -ignore-missing-schemas; \
	)

# Almost like template but renders notes
notes : $(addprefix notes-,$(TEST_CHARTS))
notes-% :
	$(foreach v, $(wildcard charts/$*/test/*-values.yaml), \
		helm install --generate-name --dry-run --render-subchart-notes charts/$* --values $(v); \
	)

.PHONY: kubeconform kubeconform-% lint lint-% template template-% test test-% notes notes-%
