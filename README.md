# SRQM: Teaching Pack

This document explains how to setup a computer to follow the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) (SRQM) course run at Sciences Po by François Briatte and Ivaylo Petev.

* * *

## Requirements

The course requires:

- A working copy of [Stata](http://www.stata.com/), by StataCorp. Stata is already installed on the Sciences Po microlab computers.

- An up-to-date copy of the [Teaching Pack](http://f.briatte.org/srqm/). Students get to read this file and setup their machines as a warm-up exercise during the first class session.

## Installation

**Please follow the instructions closely and ask for help as early as possible**, so that we can put configuration issues behind us and move to the actual course.

1.	Move the whole `SRQM` folder to a stable and easily accessible location on your hard drive. Keep the path (folder names) to the folder intact throughout the semester.

	If you later rename or relocate the `SRQM` folder by changing its name or the names of the folders that lead to it, you will have to update your installation.

2.	Open Stata and set the `SRQM` folder as the working directory with the 'File > Change Working Directory…' menu item, also accessible with &#8984;&#8679;J (Command-Shift-J) on Mac OS X.

	The folder path that appears in the Results window after you select the `SRQM` folder will be used to access the course material throughout the semester.
	
3.	Type `run profile` in the Command window and press `Enter`. This command runs the `profile.do` file that will setup Stata for this course.

	The setup creates another `profile.do` file in your Stata application folder that points to the `SRQM` folder. This makes sure that Stata will automatically run from that location.

At the end of the semester, you can erase the `profile.do` file in your Stata application folder, either manually or with the `srqm clean folder` command.

## Troubleshooting

**If you are running Windows Vista or above**, the above installation steps will work only if you open Stata by right-clicking its icon and selecting 'Run as administrator'.

**If you need to update your installation** because you renamed or moved the `SRQM` folder since you performed the course setup, run through installation steps 2-3 again.

**If you need to use a different computer** , copy the `SRQM` folder to a USB key and run through installation steps 2-3 again.

* * *

Welcome to SRQM, and see you soon!
