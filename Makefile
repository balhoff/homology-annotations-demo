#########################################################################################################################
# This Makefile assumes you have Java 8, robot, and Phenoscape kb-owl-tools on your PATH.
# Robot can be obtained from GitHub:
# - https://github.com/ontodev/robot
# Currently ROBOT 1.0.0 is required for this workflow, due to changes in the the behavior of the 'filter' command.
# The versions of both tools used for this demo are included in the repo, and can be added to your path by running:
# export PATH=./bin:$PATH
#########################################################################################################################

RELATIONS=--term obo:RO_0002160 --term obo:RO_0002162 #--term obo:RO_0002202 --term obo:BFO_0000050
ROBOT=ROBOT_JAVA_ARGS=-Xmx16G ./bin/robot
KB_OWL_TOOLS=JAVA_OPTS=-Xmx4G ./bin/kb-owl-tools

.PHONY: all
all: annotations-rea.ofn annotations-rolification.ofn annotations-ava.ofn

annotation-terms.txt: annotations.ofn homology-rea.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	$(ROBOT) merge --input annotations.ofn --input homology-rea.ofn query --select query-terms.rq $@

background.ofn: background-base.ofn relations.ofn annotation-terms.txt
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge -c true --input background-base.ofn --output background-merged.ofn &&\
	grep -v '^Import(' background-merged.ofn | grep -v 'ObjectUnionOf' >background-trimmed.ofn &&\
	$(ROBOT) filter --input background-trimmed.ofn $(RELATIONS) extract --method STAR --term-file annotation-terms.txt merge --input relations.ofn --output $@

annotations-rea.ofn: annotations.ofn homology-rea.ofn background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	$(ROBOT) merge --input annotations.ofn --input homology-rea.ofn --input background.ofn --input relations.ofn --output $@

annotations-rolification.ofn: annotations.ofn homology-rolification.ofn background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	$(ROBOT) merge --input annotations.ofn --input homology-rolification.ofn --input background.ofn --input relations.ofn --output $@

annotations-ava.ofn: annotations.ofn homology-ava.ofn background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	$(ROBOT) merge --input annotations.ofn --input homology-ava.ofn --input background.ofn --input relations.ofn --output $@

forelimb-terms.txt:
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	$(ROBOT) query --input annotations-forelimb.ofn --select query-terms.rq $@

forelimb-background.ofn: background-base.ofn relations.ofn forelimb-terms.txt
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	robot merge --input background-base.ofn --output background-merged.ofn &&\
	grep -v '^Import(' background-merged.ofn | grep -v 'ObjectUnionOf' >background-trimmed.ofn &&\
	$(ROBOT) filter --input background-trimmed.ofn $(RELATIONS) extract --method BOT --term-file forelimb-terms.txt merge --input relations.ofn --output $@

forelimb-rolification.ofn: annotations-forelimb.ofn homology-rolification.ofn forelimb-background.ofn relations.ofn
	export ROBOT_JAVA_ARGS=-Xmx16G &&\
	$(ROBOT) merge --input annotations-forelimb.ofn --input homology-rolification.ofn --input forelimb-background.ofn --input relations.ofn --output $@

homology-ava.ofn: homology_assertions.tsv
	$(KB_OWL_TOOLS) homology-table-to-owl rea $< $@

homology-rea.ofn: homology_assertions.tsv
	$(KB_OWL_TOOLS) homology-table-to-owl ava $< $@

homology-rolification.ofn: homology_assertions.tsv
	$(KB_OWL_TOOLS) homology-table-to-owl rolification $< $@

# With HermiT:
## REAHM is quick
## VAHM should take about 5 minutes
## rolification - something much greater than 30 minutes
