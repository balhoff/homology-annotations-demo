#########################################################################################################################
# This Makefile assumes you have Java 8 and robot on your PATH.
# Robot can be obtained from GitHub:
# - https://github.com/ontodev/robot
#########################################################################################################################

RELATIONS=--term obo:BFO_0000050 --term obo:RO_0002202 --term obo:RO_0002160 --term obo:RO_0002162

.PHONY: all
all: annotations-ream.ofn

annotation-terms.txt:
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot query --input annotations.ofn --select query-terms.rq $@

background.ofn: background-base.ofn relations.ofn annotation-terms.txt
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input background-base.ofn --output background-merged.ofn &&\
	grep -v '^Import(' background-merged.ofn | grep -v 'ObjectUnionOf' >background-trimmed.ofn &&\
	robot filter --input background-trimmed.ofn $(RELATIONS) extract --method BOT --term-file annotation-terms.txt merge --input relations.ofn --output $@

annotations-ream.ofn: annotations.ofn homology-ream.owl background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input annotations.ofn --input homology-ream.owl --input background.ofn --input relations.ofn --output $@
