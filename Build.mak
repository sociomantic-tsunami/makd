# Avoid errors when looking for sources we don't use
SRC := .

# Test sources and run targets
makd-test-src := $(wildcard $T/test/*.test)
makd-test-run := $(patsubst $T/test/%.test,$O/makd-test-%.stamp,$(makd-test-src))

# Simplified for now, just make all run targets phony
.PHONY: test-makd
test-makd: $(makd-test-run)

# How to run our tests
$O/makd-test-%.stamp: $T/test/%.test
	$(call exec,$< $(ITFLAGS),$<,run)
	$Vtouch $@

# Extra dependencies
$O/makd-test-gitver2deb.stamp: $T/test/gitver2deb.versions.txt

# Trick to disable unittests
$O/allunittests.stamp:
	$Vtouch $@

# Add the test target
test := test-makd
