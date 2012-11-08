# SRQM: Replication code

This folder contains the replication do-files required to follow the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) (SRQM) course run at Sciences Po by François Briatte and Ivaylo Petev.

## Coursework

All students are required to execute the full do-file at home as a review and extension of the practice session that is run every week of class. Executing the code requires running commands sequentially, one after the other, while reading their syntax and comments.

## Commands

The course do-files use built-in Stata commands as well as a few additional ones that are installed from online in the first week of class, as described in the [README](https://github.com/briatte/srqm/blob/master/README.md) file of the `SRQM` folder.

All course do-files use a short `foreach` loop to make sure that their additional commands are properly installed, which means that the code should execute properly even if your workstation is not fully setup for the course.

Once installed, commands are documented from within Stata with the `help` command. The only exceptions are the two following teaching utilities, which are loaded from the `Programs` folder and documented in its [README](https://github.com/briatte/srqm/blob/master/Programs/README.md) file instead: 

- `stab` exports summary statistics, *t*-tests and correlations
- `repl` exports complete research projects (do-file, log, tables, plots)

## Datasets

The datasets used in the do-files are stored in the `Datasets` folder and are documented in its [README](https://github.com/briatte/srqm/blob/master/Datasets/README.md) file. For the do-files to execute properly, the working directory must be set to the `SRQM` folder.
