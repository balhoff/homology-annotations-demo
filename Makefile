#########################################################################################################################
# This Makefile assumes you have Java 8 and robot on your PATH.
# Robot can be obtained from GitHub:
# - https://github.com/ontodev/robot
#########################################################################################################################

RELATIONS=--term obo:BFO_0000050 --term obo:RO_0002202 --term obo:RO_0002160 --term obo:RO_0002162

.PHONY: all
all: annotations-ream.ofn annotations-rolification.ofn annotations-vahm.ofn

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

annotations-rolification.ofn: annotations.ofn homology-rolification.owl background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input annotations.ofn --input homology-rolification.owl --input background.ofn --input relations.ofn --output $@

annotations-vahm.ofn: annotations.ofn homology-vahm.owl background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input annotations.ofn --input homology-vahm.owl --input background.ofn --input relations.ofn --output $@

forelimb-terms.txt:
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot query --input annotations-forelimb.ofn --select query-terms.rq $@

forelimb-background.ofn: background-base.ofn relations.ofn forelimb-terms.txt
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input background-base.ofn --output background-merged.ofn &&\
	grep -v '^Import(' background-merged.ofn | grep -v 'ObjectUnionOf' >background-trimmed.ofn &&\
	robot filter --input background-trimmed.ofn $(RELATIONS) extract --method BOT --term-file forelimb-terms.txt merge --input relations.ofn --output $@

forelimb-rolification.ofn: annotations-forelimb.ofn homology-rolification.owl forelimb-background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input annotations-forelimb.ofn --input homology-rolification.owl --input forelimb-background.ofn --input relations.ofn --output $@
