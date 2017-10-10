#########################################################################################################################
# This Makefile assumes you have Java 8 and robot on your PATH.
# These can be obtained from GitHub:
# - https://github.com/ontodev/robot
#########################################################################################################################

.PHONY: all
all: minimal.ofn

minimal.ofn: import-terms.txt
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot extract --method BOT --input annotations.ofn --term-file import-terms.txt --output $@

import-terms.txt:
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot query --input annotations.ofn --select query-terms.rq $@
