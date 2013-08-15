Here are (most of) the draft slides from last semester, themed with a lite version of [Thomas Kastner's HK Beamer theme](https://github.com/sprungknoedl/hk-template).

# BASH

To clean up behind the TeX build:
 
    cd ~/Documents/Teaching/SRQM/course/slides
    rm *.aux *.dvi *.fls *.toc *.log *.nav *.out *.snm *.synctex.gz *.tex.bak *.vrb *.run.xml *-blx.bib *.idx *.fdb_latexmk

To batch rename the PDF slides:

    cd ~/Documents/Teaching/SRQM/course/slides
    ls week*.tex | awk '{print("mv "$1" "$1)}' | sed 's/from/to/2' | /bin/sh

# SPEC

Each item on one slide, except for theory and Stata recaps; total max. ~ 12.

* intro
  * topic (cover)
  * project management
* recap
	* theory
	* Stata [list of commands](https://github.com/briatte/srqm/wiki/Code)
* practice
  * example
  * coursework
  * [short exercises](https://github.com/briatte/srqm/wiki/Exercises)
