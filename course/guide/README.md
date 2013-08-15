
![](https://raw.github.com/briatte/srqm/master/guide/img/0-this-is-stata.jpg)

Work in progress. The index is `0_build.tex`. The math appendix has an extra `Rnw` source.

See the [wiki](https://github.com/briatte/srqm/wiki/stata-guide) for the outline.

# HISTORY

* `[2013-08-15] 0.988` Added exercises, boxed environments, BibLaTeX support.
* `[2013-08-13] 0.987` Detailed chapter structure; improved template.
* `[2013-01-09] 0.986` Reworked chapter structure.
* `[2012-10-18] 0.985` Pushed into [Tufte-LaTeX](https://code.google.com/p/tufte-latex/) template.
* `[2012-02-23] 0.984` Last release of Word version (0.9.8.4).

# SPEC

* `hlred` for red text

Index Stata commands:

* `cmd` to index a command
* `opt` to index an option, `coab` for an abbreviated option
* `pkgfirst` and then `pkg` for packages
* `statacode` for a full command
* `docspec` for a Stata code block (finish lines with `\\%`)

Other indexed commands:

* `ext` for file extensions (include the dot)
* `kbd` for keyboard shortcuts
* `filename` for filenames

Bibliography, MLA-styled:

* `footcite` for ref-in-margin
* `cite` for names

See [example BibLaTeX commands](https://github.com/plk/biblatex/blob/master/doc/latex/biblatex/examples/01-introduction.tex).
