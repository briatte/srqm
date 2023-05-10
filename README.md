This repository contains the [Statistical Reasoning and Quantitative Methods][srqm] (SRQM) course, taught at [Sciences Po][scpo] in Paris by [François Briatte][frbr] (since 2010), [Ivaylo Petev][ivpe] (2010-2013) and [many others](#thanks).

[srqm]: https://f.briatte.org/teaching/quanti/
[scpo]: https://www.sciencespo.fr/
[frbr]: https://f.briatte.org/
[ivpe]: http://ipetev.org/

The course requires a working copy of [Stata][stata]. Due to it being over 10 years old, the course was designed on very old versions of Stata, but should still work fine on Stata 13+ at least, with minor issues due to a few syntax changes.

[stata]: https://www.stata.com/

__GitHub users__ - please feel free to [report issues][issues] or ask for enhancements. Feedback on [running the course with Stata 13+](https://github.com/briatte/srqm/issues/12) is particularly welcome, as is feedback on [running the course with older versions of Stata](https://github.com/briatte/srqm/issues/18).

[issues]: https://github.com/briatte/srqm/issues

__Sciences Po users__ - this course is currently on offer in the [PSIA][scpo-psia] (International Affairs) Masters, under code  KOUT 2030. The course used to be on offer in the [GLM][scpo-glm] (Urban School) Master until 2018, under code KGLM 2015.

[scpo-glm]: https://www.sciencespo.fr/ecole-urbaine/en/glm
[scpo-psia]: https://www.sciencespo.fr/psia/

- _Instructors_ – please email me at <francois.briatte@sciencespo.fr> in order to receive an additional 'briefing pack' (detailed instructions and recommendations on how to run the course).

- _Students_ – your course instructor will provide you with all necessary course material, and will tell you in your first class how it should be installed on your computer. Welcome to the course!

# FILES

- The `course` folder contains draft teaching material.
  * The [course slides][srqm-slides] contain material for 12 course sessions.
  * The [Stata Guide][stata-guide] contains detailed help and instructions.
- The `code` folder contains the [replication code][wiki-code] of all course sessions.
- The `data` folder contains the [teaching datasets][wiki-data] in zipped format.
- The `setup` folder contains the [course utilities][wiki-util].

[stata-guide]: https://github.com/briatte/srqm/blob/master/course/stata-guide-2012.pdf
[srqm-slides]: https://github.com/briatte/srqm/tree/master/course/slides
[wiki-code]: https://github.com/briatte/srqm/wiki/code
[wiki-data]: https://github.com/briatte/srqm/wiki/data
[wiki-util]: https://github.com/briatte/srqm/wiki/course-utilities

See the course wiki for additional information and links:

> <https://github.com/briatte/srqm/wiki>

# THANKS

Thanks first and foremost to [Ivaylo Petev][ivpe], who taught on the first versions of the course from 2010 to 2013, and who helped design much of the current course material. Thanks to [Vincent Tiberj][viti], who put us in touch, and who did lots for statistics education at Sciences Po.

[viti]: https://durkheim.u-bordeaux.fr/Notre-equipe/Chercheur-e-s-et-enseignant-e-s-chercheur-e-s/CV/Vincent-Tiberj

Thanks also to all instructors who have run their own forks of the course over the years, including Mathilde Bauwin, [Cyril Benoît][cybe], [Joël Gombin][jogo], [Andrey Indukaev][anid], [Antoine Jardin][anja], [Filip Kostelka][fiko], [Antonin de Laever][andl], [Antoine Marsaudon][anma], [Haley McAvay][hama], [Sarah Schneider-Strawczynski][sasc], [Pavlos Vasilopoulos][pava], and many, many others, who are unfortunately not listed here because I lost track around fall 2018.

[anja]: http://antoinejardin.com/
[cybe]: https://cyrilbenoit.com/
[jogo]: https://datactivist.coop/
[anid]: https://tuhat.helsinki.fi/portal/en/persons/andrey-indukaev(c77ccdd8-bb80-4aa5-bf3d-bbb632e9c1e4).html
[fiko]: https://filipkostelka.com/
[andl]: https://fr.linkedin.com/in/antonin-de-laever-a2039958
[anma]: https://www.parisschoolofeconomics.eu/en/marsaudon-antoine/
[hama]: http://haleymcavay.weebly.com/
[pava]: https://pvasilopoulos.weebly.com/
[sasc]: https://www.parisschoolofeconomics.eu/en/schneider-sarah/

Additional thanks go to [Emiliano Grossman][emgr], [Simon Persico][sipe], [Daniel Stockemer][dast], [Tommaso Vitale][tovi] and Hyungsoo Woo, and to the Sciences Po admin teams, with special thanks to Carole Bacheter, Andreas Roessner, Régine Serra and Mimi Maung-Trentin.

[emgr]: http://www.emilianogrossman.eu/
[sipe]: https://www.pacte-grenoble.fr/membres/simon-persico
[dast]: https://uniweb.uottawa.ca/members/860
[tovi]: https://www.sciencespo.fr/centre-etudes-europeennes/fr/chercheur/tommaso-vitale

Last but not least, thanks to all current and past SRQM students, especially Alba Guesch, [Leila Ferrali][lefe], [Laura Maria Führer][lamf] and Gabriel Odin, who took the course in the fall of 2010, and who generously suggested many improvements to it.

[lefe]: https://www.linkedin.com/in/leilaferrali/
[lamf]: https://www.sv.uio.no/iss/english/people/aca/lauramf/

# VERSION

This is version ~~[0.7.x][wiki-hist]~~ "whatever" of the course, with just a few updates since 2019 to ensure that the course still runs on Stata 17.

[wiki-hist]: https://github.com/briatte/srqm/wiki/course-history

# LICENSE

This repository contains Stata datasets that were downloaded from [various data providers](https://github.com/briatte/srqm/wiki/data), and then slightly altered for teaching purposes. Please do not redistribute those.

The rest of the repository is under a [CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/) license, where 'by' are François Briatte and Ivaylo Petev (Stata code) or François Briatte alone (related teaching material).
