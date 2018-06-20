#########################################################################################################################
# This Makefile assumes you have Java 8 and robot on your PATH.
# Robot can be obtained from GitHub:
# - https://github.com/ontodev/robot
#########################################################################################################################

RELATIONS=--term obo:RO_0002160 --term obo:RO_0002162 #--term obo:RO_0002202 --term obo:BFO_0000050 

.PHONY: all
all: annotations-reahm.ofn annotations-rolification.ofn annotations-vahm.ofn

annotation-terms.txt: annotations.ofn homology-reahm.owl
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input annotations.ofn --input homology-reahm.owl query --select query-terms.rq $@

background.ofn: background-base.ofn relations.ofn annotation-terms.txt
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge -c true --input background-base.ofn --output background-merged.ofn &&\
	grep -v '^Import(' background-merged.ofn | grep -v 'ObjectUnionOf' >background-trimmed.ofn &&\
	robot filter --input background-trimmed.ofn $(RELATIONS) extract --method STAR --term-file annotation-terms.txt merge --input relations.ofn --output $@

annotations-reahm.ofn: annotations.ofn homology-reahm.owl background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input annotations.ofn --input homology-reahm.owl --input background.ofn --input relations.ofn --output $@

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

# With HermiT:
## REAHM is quick
## VAHM should take about 5 minutes
## rolification - something much greater than 30 minutes
