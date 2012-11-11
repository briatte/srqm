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

> If you later move the `SRQM` folder by changing its name or the names of the folders that lead to it on your hard drive, you will have to run the next installation steps again.

### 2. Application folder

Open Stata:

### Windows users: 

- Make sure that the *entire Stata application folder* is installed in the `Program Files` folder (sometimes renamed in your language). The application needs to run from its folder to work.

- On Windows Vista, 7 or above, open Stata by right-clicking the program icon and selecting 'Run as administrator' for this setup procedure to complete.

- If you see two versions of Stata, one of which works only on 64-bit computers: use whichever version works with your system.

### Mac OS X users:

- Make sure that the *entire Stata application folder* is installed in the `Applications` folder. The application needs to run from its folder to work.

- If you are using Mac OS X Gatekeeper settings, you will need to authorize Stata by allowing applications downloaded from anywhere in the 'Security & Privacy' panel of your System Preferences (accessible from the Apple menu).

### 3. Working directory

Set the `SRQM` folder as the working directory with the 'File : Change Working Directory…' menu item, also accessible with &#8984;&#8679;J (Command-Shift-J) on Mac OS X. Select the `SRQM` folder and press `OK`.

The folder path that appears in the Results window might look like the following examples:

| System    | Example of a folder path            |
|:----------|:------------------------------------|
| Mac OS X  | `/Users/fr/Documents/Teaching/SRQM` |
| Windows   | `C:\Users\Ivo\Desktop\SRQM`         |

This path is where the course setup will tell Stata to look for the SRQM teaching material. This folder path must stay intact throughout the semester for Stata to access the course material.

> If you inadvertently modify the path to your `SRQM` folder by moving or renaming it, you will get an error message and will have to run through installation steps 2 to 4 again. Be careful!

### 4. Course setup

Make sure that you are connected to the Internet. At Sciences Po, this requires checking that you logged into the wifi network. Then, type `run profile` in the Command window and press `Enter`. 

This command runs the `profile.do` file that will setup Stata for this course by running some of the code stored in the `Programs` [folder](https://github.com/briatte/srqm/tree/master/Programs). The setup accomplishes three things:

- it adjusts some common Stata settings for screen output and installs an improved graph scheme;

- it installs some user-contributed Stata commands like `fre` or `spineplot` that are used in the course; and 

- it creates another `profile.do` file in the Stata application folder to redirect it to the `SRQM` folder.

## Uninstall

At the end of the semester, type `srqm clean folder`. This will stop redirecting Stata to the `SRQM` folder.

* * *

You can now enjoy the rest of the course and start reading the Stata Guide.  Welcome to SRQM, and see you soon!
