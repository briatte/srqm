This repository contains the [Statistical Reasoning and Quantitative Methods][srqm] (SRQM) course taught at Sciences Po from 2010 to 2013 by [François Briatte][fb] and [Ivaylo Petev][ip]. [Joël Gombin][jg] and [Filip Kostelka][fk] are also running their own forks.

[srqm]: http://f.briatte.org/teaching/quanti/
[fb]: http://f.briatte.org/
[jg]: http://joelgombin.fr/
[ip]: http://ipetev.org/
[fk]: http://www.cee.sciences-po.fr/en/le-centre/phd-and-new-doctors/phd-candidates/153-filip-kostelka.html

The course requires a working copy of [Stata][stata]. Instructions to set up your computer for the course are provided in the introduction of the course handbook. Additional material is distributed in class through Google Docs.

If you are reading this online on GitHub, please feel free to [report issues][issues] or ask for enhancements. Feedback on [running the course in Stata 13](https://github.com/briatte/srqm/issues/12) is particularly welcome.

__Students__ – please check with your instructor _as soon as possible_ if you have any questions or are having difficulties with the course setup, which will be explained extensively in class. Welcome to the course, and talk to you soon!

[stata]: http://www.stata.com/

# FILES

* The `course` folder contains draft teaching material.
* The `code` folder contains the [replication code][wiki-code].
* The `setup` folder contains the [course utilities][wiki-utils].
* The `data` folder contains the teaching datasets:

| Filename       | Data                                  | Year(s)        |
|:---------------|:--------------------------------------|:---------------|
| `ess0810`      | [European Social Survey][ess]         | Rounds 4-5 (2008-2010) |
| `gss0012`      | [General Social Survey][gss]          | 2000-2012      |
| `nhis9711`     | [National Health Interview Survey][nhis] | 1997-2011   |
| `qog2013`      | [Quality of Government][qog]          | 2009 ± 3 years |
| `wvs2000`      | [World Values Survey][wvs]            | Wave 4 (2000)  |

[ess]: http://www.europeansocialsurvey.org/
[gss]: http://www3.norc.org/GSS+Website/
[nhis]: http://www.cdc.gov/nchs/nhis.htm
[qog]: http://www.qog.pol.gu.se/data/datadownloads/qogstandarddata/
[wvs]: http://www.worldvaluessurvey.org/

[issues]: https://github.com/briatte/srqm/issues
[wiki-code]: https://github.com/briatte/srqm/wiki/code
[wiki-utils]: https://github.com/briatte/srqm/wiki/course-utilities

# HISTORY

* 4.5: patches for new Sciences Po computer setups.
* 4.4: correct ESS design weights for Israel; [cleaner repo](http://rtyley.github.io/bfg-repo-cleaner/).
* 4.3: updated NHIS, QOG and ESS datasets.
* 4.2: dedicated FTP server for additional teaching material.
* 4.1: better workaround for admin restrictions.
* 4.0: reworked `srqm` course utilities (Spring 2013).
* 3.0: reworked `srqm` utilities (Spring 2012).
* 2.0: reworked `srqm` utilities (Fall 2012).
* 1.0: first release (Spring 2011).
