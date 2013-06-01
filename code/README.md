# SRQM: Code

This folder contains the Stata replication code required to follow the [Statistical Reasoning and Quantitative Methods][srqm] (SRQM) course taught by François Briatte and Ivaylo Petev.

[srqm]: http://f.briatte.org/teaching/quanti/

The code is written as weekly do-files. All do-files use a short `foreach` loop to make sure that non-built-in commands are properly installed prior to execution, which means that the code should execute properly even if your workstation is not fully setup for the course. Once installed, commands are documented from within Stata with the `help` command.

## Coursework

All students are required to execute the full do-file at home as a review and extension of the practice session that is run every week of class. Executing the code requires running commands sequentially while reading their syntax and comments.

For the do-files to execute properly, the working directory must be set to the `SRQM` folder. The datasets called by the do-files are stored in the `data` folder and are documented in its [README][srqm-data] file.

[srqm-data]: https://github.com/briatte/srqm/blob/master/data/README.md
