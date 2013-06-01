# SRQM: Setup instructions

This file listing covers the datasets distributed as part of the [Statistical Reasoning and Quantitative Methods][srqm] course taught by François Briatte and Ivaylo Petev.

[srqm]: http://f.briatte.org/teaching/quanti/

The course requires Internet access, basic computer skills and a working copy of [Stata][stata], by StataCorp. Stata 11 is already installed on Sciences Po workstations. The Small version of Stata cannot open large datasets, so make sure that you are using Stata IC (InterCooled), MP (Multiple Processors) or SE (Standard Edition, which is what Sciences Po workstations run on).

[stat]: http://www.stata.com/

In the setup instructions below, the `SRQM` folder is the folder that you can download from [its webpage][srqm-page] or [repository][srqm-repo]. We call this folder the 'Teaching Pack' in class.

[srqm-page]: http://f.briatte.org/srqm/
[srqm-repo]: https://github.com/briatte/srqm

If you are enrolled in our course, you will read this file and setup your computer during our first class.

* * *

## Installation

Please follow the instructions closely and ask for help as early as possible, so that we can put configuration issues behind us and move to the actual content of the course.

__One-line USB setup:__ copy the `SRQM` folder to a USB key, open Stata, set the `SRQM` folder as your Stata working directory from the "File", type `run profile` and wait five minutes.

### 1. Course material

Move the whole `SRQM` folder to a stable and easily accessible location on your hard drive. Keep the names of that folder and the folders that lead to it intact throughout the course.

> If you later move the `SRQM` folder by changing its name or the names of the folders that lead to it on your hard drive, you will have to run the next installation steps again.

### 2. Application folder

Check your Stata installation:

### Windows users: 

- Make sure that the *entire Stata application folder* is installed in the `Program Files` folder (sometimes renamed in your language). Stata needs to run _from its own folder_ to work.
- On Windows Vista, 7 or above, you will need to open Stata by right-clicking the program icon and selecting 'Run as administrator' for this setup procedure to fully complete.
- If you see two versions of Stata, one of them will work only on 64-bit computers: use whichever version works with your system, preferrably the 64-bit version for better speed performance.

### Mac OS X users:

- Make sure that the *entire Stata application folder* is installed in the `Applications` folder. Stata needs to run _from its own folder_ to work.
- If you are using Mac OS X Gatekeeper settings, access the 'Security & Privacy' panel of your System Preferences from the Apple menu and allow applications downloaded from anywhere.
- If you know how to use the Terminal, note that you can run Stata from there. The class does not require that you are that much of a geek.

Now open Stata and skip the update dialog by disabling automatic updates, as we will learn to update Stata and packages by ourselves, in true nerd spirit.

### 3. Working directory

Set the `SRQM` folder as the working directory with the 'File : Change Working Directory…' menu item, also accessible with &#8984;&#8679;J (Command-Shift-J) on Mac OS X.

Select the `SRQM` folder and press `OK`.

The folder path that appears in the Results window might look like the following examples:

| System    | Example of a folder path            |
|:----------|:------------------------------------|
| Mac OS X  | `/Users/fr/Documents/Teaching/SRQM` |
| Windows   | `C:\Users\Ivo\Desktop\SRQM`         |

This path is where the course setup will tell Stata to look for the SRQM teaching material.

> __Important:__ This folder path must stay intact throughout the semester for Stata to access the course material. If you inadvertently modify the path to your `SRQM` folder by moving or renaming it, you will get an error message and will have to run through installation steps 2 to 4 of this setup again. Be careful!

Have you read the "Important" message above?

### 4. Course setup

1. Make sure that you are connected to the Internet. At Sciences Po, this requires checking that you logged into the wifi network. 
2. Then type `run profile` in the Command window and press `Enter`.
3. Wait for the run to complete and salute you with a 'Hello!' message.

This command runs the `profile.do` file that will setup Stata for this course by running some of the code stored in the [`setup` folder][setup]. The setup accomplishes three things:

- it adjusts some common Stata settings for screen output and installs an [improved graph scheme][burd];
- it adjusts memory to 500MB on versions of Stata before 11 (Stata 12 does it automatically);
- it installs some user-contributed Stata commands like `fre` or `spineplot` that are used in the course; and 
- it creates another `profile.do` file in the Stata application folder to redirect it to the `SRQM` folder.

[setup]: https://github.com/briatte/srqm/tree/master/setup
[burd]: https://github.com/briatte/burd

The installation will go fine as long as you are running with administrative privileges on a machine that has a decent amount of RAM (1GB is a strict minimum) and a minimal amount of disk space (aim at 10% of your hard drive capacity, or at a minimum of 1GB if you are living dangerously). The entire course material takes less than 400MB with all datasets uncompressed.

## Uninstalling

- If you do not like the course graph scheme, type `set scheme s2color` to revert to the default Stata scheme, or use any other scheme of your choice (see `help scheme`).
- At the end of the semester, type `srqm clean folder` to stop redirecting Stata to the `SRQM` folder.

* * *

You can now start reading the Stata Guide.

Welcome to the course, and see you soon!
