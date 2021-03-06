ifeq ($(RTE_SDK),)
$(error "Please define RTE_SDK environment variable")
endif

ifndef RTE_TARGET
export RTE_TARGET=x86_64-native-linuxapp-gcc
endif

export RTE_SRCDIR=$(abspath src)
export RTE_OUTPUT=$(abspath build)


# `make` without argument calls the first rule. Call make in src/ to build
# natasha.
default:
	$(MAKE) -C . -f $(RTE_SRCDIR)/Makefile


############
# Unitests #
############

# Directories names in src/tests/
TESTS=$(shell find $(RTE_SRCDIR)/tests    \
         -mindepth 1 -maxdepth 1 -type d  \
         -exec basename {} \;)

build_tests:
	@for test in $(TESTS); do                               \
		$(MAKE) -C . -f $(RTE_SRCDIR)/tests/$$test/Makefile \
			--no-print-directory                            \
			RTE_OUTPUT=$(RTE_OUTPUT)/$$test                 \
			UNITTEST=1                                      \
			build_test                                      \
	; done


run_tests: build_tests
	@for test in $(TESTS); do                                \
		sudo $(RTE_OUTPUT)/$$test/test                       \
                  && echo "[OK] $$test" ||                   \
                           echo "[FAIL] $$test (status=$$?)" \
	; done


test: run_tests
