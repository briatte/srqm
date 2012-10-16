# SRQM: Setup instructions

This document explains how to setup a computer to follow the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) (SRQM) course run at Sciences Po by François Briatte and Ivaylo Petev.

* * *

## Requirements

The course requires:

- A working copy of [Stata](http://www.stata.com/), by StataCorp. Stata 11 is already installed on Sciences Po workstations. The course was also tested with Stata 10 and Stata 12 on both Mac OS X and Windows.

- An up-to-date copy of this 'Teaching Pack', which is available from [its webpage](http://f.briatte.org/srqm/). Students get to read this file and setup their machines as a warm-up exercise during the first class session.

- Internet access and basic computer skills. Aspects of computer use that are relevant to the course are addressed in the Stata Guide found in the `Handbooks` [folder](https://github.com/briatte/srqm/tree/master/Handbooks), and will be covered in class.

## Installation

Please follow the instructions closely and ask for help as early as possible, so that we can put configuration issues behind us and move to the actual content of the course.

### 1. Course material

Move the whole `SRQM` folder to a stable and easily accessible location on your hard drive. Keep the names of the folders that lead to it intact throughout the course.

If you later move the `SRQM` folder by changing its name or the names of the folders that lead to it on your hard drive, you will have to update your installation.

### 2. Application folder

Make sure that the whole Stata application folder is installed in the `Applications` folder (Mac OS X) or in the `Program Files` folder (Windows), and then open Stata after checking the following:

- On Windows, you might have two versions of Stata, one of which works only on 64-bit computers. Use whichever version works with your system.

- On Windows Vista or above, you will need to open Stata by right-clicking the program icon and selecting 'Run as administrator' for this setup procedure only.

- On Mac OS X, you might need to allow applications downloaded from anywhere in the 'Security & Privacy' panel of your System Preferences (accessible from the Apple menu).

### 3. Working directory

Set the `SRQM` folder as the working directory with the 'File > Change Working Directory…' menu item, also accessible with &#8984;&#8679;J (Command-Shift-J) on Mac OS X.

The folder path that appears in the Results window after you select the `SRQM` folder will be used to access the course material throughout the semester. It might look like the following examples:

| System    | Example of a folder path            |
|:----------|:------------------------------------|
| Mac OS X  | `/Users/fr/Documents/Teaching/SRQM` |
| Windows   | `C:\Users\Ivo\Desktop\SRQM`         |

### 4. Course setup

Make sure that you are connected to the Internet. At Sciences Po, this requires checking that you logged into the wifi network. Then, type `run profile` in the Command window and press `Enter`. 

This command runs the `profile.do` file that will setup Stata for this course by running some of the code stored in the `Programs` [folder](https://github.com/briatte/srqm/tree/master/Programs), which accomplishes three things:

- The setup adjusts some common Stata settings for screen output, including memory on versions older than Stata 12.

- The setup installs some additional packages that are not part of the default Stata software. Some of their commands, like `fre` or `spineplot`, are used in the course material.
	
- The setup creates another `profile.do` file in your Stata application folder that points to the `SRQM` folder. This makes sure that Stata will automatically run from that location.

At the end of the semester, you can erase the `profile.do` file in your Stata application folder, either manually or with the `srqm clean folder` command.

## Troubleshooting

This is the section to read if you get error messages in your Stata screen (they read in red), if you forget your laptop to class, or if things just stop working in any other way.

### Fixing the `SRQM` folder path

If you need to update your installation because you renamed or moved the `SRQM` folder since you performed the course setup, run through installation steps 2--4 (again).

The folder path that you modified must stay intact throughout the course for Stata to find the course material. If you inadvertently break the path, unnecessary panic and time loss will ensue.

### Running in 'temporary' mode

If you need to use a different computer, get the `SRQM` folder offline or [online](http://f.briatte.org/srqm/), copy it to a USB key, rename it to `SRQM-USB` and run through installation steps 2--4.

This allows you to run the course in 'temporary' mode from a Sciences Po workstation or any other computer with Stata. System restrictions and administrator privileges might still cause trouble.

* * *

You can now start reading the Stata Guide. The sections on Stata.

Welcome to SRQM, and see you soon!
