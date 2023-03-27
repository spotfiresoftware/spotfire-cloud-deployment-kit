TEST_CHARTS = $(filter-out spotfire-common,$(CHARTS))

test : $(addprefix test-,$(TEST_CHARTS))
test-% : lint-% template-% kubeconform-%
	@echo Test of chart $* completed.

lint : $(addprefix lint-,$(TEST_CHARTS))
lint-% :
	$(foreach v, $(wildcard charts/$*/test/*-values.yaml), \
		helm lint charts/$* --values $(v); \
	)

# Set to VALIDATE=1 validate against running kubernetes cluster
templat% : VALIDATE ?= 1
template : $(addprefix template-,$(TEST_CHARTS))
template-% :
	$(foreach v, $(wildcard charts/$*/test/*-values.yaml), \
		helm template $(if $(filter 1,$(VALIDATE)),--validate,) charts/$* --values $(v); \
	)

kubeconform : $(addprefix kubeconform-,$(TEST_CHARTS))
kubeconform-% :
	$(foreach v, $(wildcard charts/$*/test/*-values.yaml), \
		helm template charts/$* --values $(v) | kubeconform -summary -ignore-missing-schemas; \
	)

.PHONY: kubeconform kubeconform-% lint lint-% template template-% test test-%
