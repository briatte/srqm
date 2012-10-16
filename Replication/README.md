# SRQM: Replication code

This document lists the replication do-files required to follow the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) (SRQM) course run at Sciences Po by François Briatte and Ivaylo Petev.

The datasets used in the do-files are stored in the `Datasets` folder and are documented in its [README](https://github.com/briatte/srqm/blob/master/Datasets/README.md) file. For the do-files to execute properly, the working directory must be set to the `SRQM` folder.

* * *

## Contents

The following tables list the different files and the datasets that they load.

### Replication homework:

| Filename    | Data |
|:------------|:-----|
| `week1.do`  | Many |
| `week2.do`  | NHIS |
| `week3.do`  | WVS	 |
| `week4.do`  | NHIS |
| `week5.do`  | ESS  |
| `week6.do`  | ESS  |
| `week7.do`  | QOG  |
| `week8.do`  | QOG  |
| `week9.do`  | GSS  |
| `week10.do` | EBM  |
| `week11.do` | QOG  |
| `week12.do` | Many |

*Note:* the first and last sessions use a mix of external datasets.

### Draft templates:

| Filename    | Data |
|:------------|:-----|
| `draft1.do` | NHIS |
| `draft2.do` | NHIS |
| `draft3.do` | ESS	 |

## Syntax

Each do-file follows more or less the same code structure. The next table lists common sections and commands, as covered in class during the practice hour of each session:

| Block     | Commands |
|:----------|:------------------------------------ |
| Setup     | Folders, packages, log.              |
|           | `ssc install` |
|           | `cd`, `ls`, `mkdir` |
|           | `browse`, `doedit` |
|           | `do`, `run`, `log` |
| Data      | Load, subset, weight. |
|           | `use`, `clear` |
|           | `d`, `codebook`, `ren` |
|           | `count`, `if`, `in` |
|           | `keep`, `drop`, `mi()` |
|           | `svyset` |
| Variables | Descriptions, recodes, summary.      |
|           | `su`, `fre`, `tab` |
|           | `replace`, `recode`, `irecode` |
|           | `la`, `decode`, `encode` |
|           | `ci`, `ciplot` |
|           | `hist`, `kdensity`, `gladder` |
|           | `symplot`, `pnorm`, `qnorm` |
|           | `catplot`, `gr box`, `gr dot` |
|           | `spineplot`, `sc` |
|           | `tabout` |
| Model     | Tests, estimation, diagnosis.        |
|           | `ttest`, `prtest`, `tabchi` |
|           | `corr`, `pwcorr`, `mkcorr` |
|           | `reg`, `predict` |
|           | `rvfplot`, `rvpplot`, `vif` |
|           | `logit`, `margins`, `marginsplot`    |
|           | `tsset`, `xtset` |
|           | `estout` |
| End       | Clear, stop, bye.                    |
|           | `exit` |

In the actual do-files, some commands have been given simpler alternatives further documented in the [README](https://github.com/briatte/srqm/blob/master/Programs/README.md) file of the `Programs` folder:

- `ssc install` commands are replaced with the less intrusive `packages_required` command
- `tabout` is demonstrated alongside the simpler `tsst` alternative to export summary statistics

* * *

Running the code for this course usually requires that you are connected to the Internet and that you have followed the setup instructions detailed in the [README](https://github.com/briatte/srqm/blob/master/README.md) file of the `SRQM` folder.