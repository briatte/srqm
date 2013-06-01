# SRQM: Programs

This file listing covers the datasets distributed as part of the [Statistical Reasoning and Quantitative Methods][srqm] course taught by François Briatte and Ivaylo Petev.

[srqm]: http://f.briatte.org/teaching/quanti/

This file describes the commands used in class to assist students in following the course and completing their research projects.

* * *

## `sbar`

__Experimental.__ Produces categorical plots that use colored gradients to draw the bars. Relies on Nick Cox's `catplot` command.

See its [blog post][srqm-sbar] for an example, or type `sbar_demo`.

[srqm-sbar]: http://srqm.tumblr.com/post/44705634349/plotting-survey-data-a-wrapper-for-catplot

## `srqm_data`

Prepares the [course datasets][srqm-data], which are slight variations of the original ones. All datasets are saved in Stata 9/10 format for backward compatibility.

[srqm-data]: https://github.com/briatte/srqm/blob/master/data/README.md

## `srqm_get`

Downloads the course material from a personal server address. Used in class to distribute updated versions of the code, programs and slides for the course.

Examples:

    srqm_get week7.pdf
    srqm_get week11.do

Details:

- The command knows where to put the files and will rename any older files to backup filenames.
- The command accepts any number of consecutive valid filenames, as in `srqm_get week1.do week1.pdf`.

## `srqm`

The `srqm` utilities rely on the architecture of the `SRQM` folder, a.k.a the '[Teaching Pack](http://f.briatte.org/srqm/)', which contains the course material. All `srqm` commands should be run with this folder set as the working directory.

The `srqm` utilities require one command and optionally one subcommand to execute:

	srqm command [subcommand] [, log forced]

The commands and subcommands form four blocks. The first of them, `setup`, is called from the `profile.do` file of the `SRQM` folder and is used to set up computers for the course:

	srqm setup
	srqm setup folder
	srqm setup packages

To minimize trouble with working directory errors, the setup creates a mock symbolic link to the `SRQM` folder and performs a quick folder integrity check at startup. A few more similar checks are available:

	srqm check
	srqm check course
	srqm check folder
	srqm check packages

The mock symbolic link to the `SRQM` folder is generally erased at the end of the semester, and a few more cleanup utilities can be used for testing purposes:

	srqm clean
	srqm clean folder
	srqm clean packages

When the additional `log` option is specified, all commands send verbose output to a log in order to help users report issues.

Usually runs in five minutes or less.

### `srqm setup`

Tries to permanently set up a few options like screen breaks and scrollback buffer size in Stata, including `memory` on software versions older than Stata 12. Also sets the `burd` scheme (documented above).

### `srqm setup folder`

Tries to tell Stata to automatically run from the `SRQM` folder by copying its path to the global macro `$srqm_wd`. The macro is saved into a `profile.do` file located in the Stata application folder.

The `profile.do` file saved to the Stata application folder acts as a symbolic link that also runs the `profile.do` file from the SRQM folder, to perform further integrity checks on the course setup.

This command requires to run Stata as administrator on Windows Vista and 7, or it will fail due to a [system restriction](http://www.stata.com/support/faqs/windows/updating-on-vista/) in recent versions of Windows.

### `srqm setup packages`

Installs the additional Stata packages used in the course do-files, including the [BuRd][burd] scheme, which was developed for the course. Requires Internet access to execute properly.

[burd]: https://github.com/briatte/burd/

The command will try to run as quickly as possible by skipping packages that are [already installed][statalist-tip]. This behaviour can be overriden by passing the `forced` option.

[statalist-tip]: http://www.stata.com/statalist/archive/2009-12/msg00461.html

### `srqm check`

Produces a report on the current setup, covering the basic system options obtained with `query` and the list of installed packages obtained with `ado dir`.

If the `demo' option is specified, as in `srqm check, demo(1/4 12)`, the command runs the course do-files to test their executability (the whole course usually runs in less than five minutes).

### `srqm check folder`

Checks the existence of the `Datasets` and `Replication` folders used in class. This subcommand is automatically run with the `nolog` option every time Stata loads with the `SRQM` working directory.

### `srqm check packages`

Checks whether the additional packages installed from the SSC server by the `srqm setup packages` subcommand are up to date.

### `srqm clean`

Cleans up the `SRQM` folder by erasing temporary workfiles produced by the course do-files. The workfiles consist of logs.

#### `srqm clean folder`	

Unlinks Stata from the `SRQM` folder by erasing the `profile.do` file that is installed in the application folder as part of the setup for the course. Used at the end of the semester.

#### `srqm clean packages`

Uninstalls course packages. Used for testing purposes.

## `srqm_utils`

Undocumented shortcut commands that slightly modify the behaviour of a few built-in Stata commands.

* `find`: a quicker `lookfor` command.
* `load`: a quicker `use` command.

## `stab`

__Experimental.__ Produces summary statistics and correlation matrix tables in plain text format, for maximum compatibility with external editors like Google Documents.

The basic syntax for `stab` is:

	stab using week8 [aw,fw] [if,in] [, su(v1 v2) corr fr(v3 v4) ttest by(varname) f(0) replace]

The `su` option produces five-number summaries for continuous variables. The `fr` option produces frequencies for categorical variables. Both results are combined into a single table.

The `by(varname)` option creates multiple tables based on the categories of `varname`. The `corr` option adds a correlation matrix of the continuous variables specified in `su`.

Less frequent options are `ttest` to add *t*-tests for all groups, and `float(n)` to modify the level of decimal precision. The command also supports analytical and frequency survey weights, `if` and `in`.
