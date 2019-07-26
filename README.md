#Homology model demonstration

This project provide a GNU `make` workflow which converts Phenoscape's table of homology assertions (`homology_assertions.tsv`) into various OWL renderings (`homology-rea.ofn`, `homology-ava.ofn`, `homology-rolification.ofn`). It then extracts a subset of axioms from referenced OBO ontologies which are relevant to the homology assertions and also relevant to the demonstrator annotations used in the Phenoscape paper on homology models (`annotations.ofn`).

The homology axioms and annotations OWL files contain only those OWL axioms, and not external information like term labels. The `all` target of the makefile produces three composite files (`annotations-rea.ofn`, `annotations-ava.ofn`, `annotations-rolification.ofn`), which are the end products to be explored in Protégé. These files include axioms merged from the homology assertions, demonstrator annotations, and referenced OBO ontologies.

## Running

You should have GNU `make` and Java (version 8 or greater) installed on your machine. The makefile depends on two external tools, appropriate version of which are bundled in this repository and will be automatically used by the workflow:

- [ROBOT](http://robot.obolibrary.org), a general purpose OWL manipulation tool
- [Phenoscape kb-owl-tools](https://github.com/phenoscape/phenoscape-owl-tools), which contains the code which converts the homology assertions table into particular OWL models.

## Pre-built products

The `make` workflow allows you to see which code is executed to build the demonstration files. If you just want to explore these in Protégé, you can skip running the workflow and just view the pre-built versions in the `products` folder.
