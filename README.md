# SRQM: Setup instructions

This document explains how to setup a computer to follow the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) (SRQM) course run at Sciences Po by François Briatte and Ivaylo Petev.

The course requires Internet access, basic computer skills and a working copy of [Stata](http://www.stata.com/), by StataCorp. Stata 11 is already installed on Sciences Po workstations.

In the setup instructions below, the `SRQM` folder is the folder that you downloaded from [its webpage](http://f.briatte.org/srqm/). We call this folder the 'Teaching Pack' in class.

If you are enrolled in our course, you will read this file and setup your computer during our first class.

* * *

## Installation

Please follow the instructions closely and ask for help as early as possible, so that we can put configuration issues behind us and move to the actual content of the course.

### 1. Course material

Move the whole `SRQM` folder to a stable and easily accessible location on your hard drive. Keep the names of that folder and the folders that lead to it intact throughout the course.

If you later move the `SRQM` folder by changing its name or the names of the folders that lead to it on your hard drive, you will have to run the next installation steps again.

### 2. Application folder

Make sure that the whole Stata application folder is installed in the `Applications` folder (Mac OS X) or in the `Program Files` folder (Windows), and then open Stata after checking the following:

- On Windows, you might have two versions of Stata, one of which works only on 64-bit computers. Use whichever version works with your system.

- On Windows Vista or above, you will need to open Stata by right-clicking the program icon and selecting 'Run as administrator' for this setup procedure only.

- On Mac OS X, you might need to allow applications downloaded from anywhere in the 'Security & Privacy' panel of your System Preferences (accessible from the Apple menu).

### 3. Working directory

Set the `SRQM` folder as the working directory with the 'File > Change Working Directory…' menu item, also accessible with &#8984;&#8679;J (Command-Shift-J) on Mac OS X. Select the `SRQM` folder and press `OK`.

The folder path that appears in the Results window might look like the following examples:

| System    | Example of a folder path            |
|:----------|:------------------------------------|
| Mac OS X  | `/Users/fr/Documents/Teaching/SRQM` |
| Windows   | `C:\Users\Ivo\Desktop\SRQM`         |

> **IMPORTANT** -- This folder path must stay intact throughout the semester for Stata to access the course material. If you inadvertently modify its elements, it will break and lead to errors in your code, and you will need to run through installation steps 2 to 4 again. Be careful!

### 4. Course setup

Make sure that you are connected to the Internet. At Sciences Po, this requires checking that you logged into the wifi network. Then, type `run profile` in the Command window and press `Enter`. 

This command runs the `profile.do` file that will setup Stata for this course by running some of the code stored in the `Programs` [folder](https://github.com/briatte/srqm/tree/master/Programs), which accomplishes three things:

- The setup adjusts some common Stata settings for screen output, including memory on versions older than Stata 12.

- The setup installs some additional packages that are not part of the default Stata software. Some of their commands, like `fre` or `spineplot`, are used in the course material.
	
- The setup creates another `profile.do` file in your Stata application folder that points to the `SRQM` folder. This makes sure that Stata will automatically run from that location.

## Uninstall

At the end of the semester, you can erase the `profile.do` file in your Stata application folder, either manually or with the `srqm clean folder` command. This will 'unlink' Stata from the `SRQM` folder.

* * *

You can now enjoy the rest of the course and start reading the Stata Guide. Welcome!

Welcome to SRQM, and see you soon!
