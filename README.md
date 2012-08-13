# SRQM Teaching Pack

This document explains how to setup a computer to follow the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) (SRQM) course run at Sciences Po by François Briatte and Ivaylo Petev.

Every student gets a copy of this ‘[Teaching Pack](http://f.briatte.org/srqm/)’ on the first session, and gets assigned to read this file and setup their machines as a warm-up exercise to the course.

* * *

## Requirements

The course requires a working copy of [Stata 12](http://www.stata.com/), by StataCorp. Minimal system requirements are Mac OS X 10.5 or Windows XP.

Backward compatibility extends back to Stata 10, which means that the course do-files should be able to run after a few adjustments on older operating systems.

## Installation

The following steps explain how to configure a system to work with Stata for the duration of this course.

### 1. Copy the ‘Teaching Pack’

Move the whole ‘Teaching Pack’ to a **stable** and **easily accessible** location on your hard drive, preferrably with your other courses in your `Documents` folder.

You can rename the ‘Teaching Pack’ folder to whatever you like, but you will have to use its new name in replacement of `SRQM` in the following instructions.

### 2. Install Stata

Stata should be pre-installed on your workstation.

Make sure that you are running Stata from the __"Applications"__ folder or its system equivalent, such as __"Program Files"__ on Windows. Running Stata from outside your application folder might cripple the software in several respects.

### 3. Set the working directory

Now, open Stata. To set the `SRQM` folder as the working directory, use the __File > Change Working Directory…__ menu item, or type &#8984;&#8679;J (Command-Shift-J) on Mac OS X.

Watch the folder path that Stata will display in the ‘Results’ window when you select the SRQM folder:

	. cd "/Users/fr/Documents/Teaching/SRQM"
	/Users/fr/Documents/Teaching/SRQM

The folder path will look different on your local system, especially on Windows, which uses backslashes:

	. cd "C:\Users\Ivo\Documents\Teaching\SRQM"
	C:\Users\Ivo\Documents\Teaching\SRQM

This folder path will be used to access the course material throughout the semester. If you modify the name and/or the location of the `SRQM` folder during that period, you will need to run through this installation guide again to update your settings.

### 4. Edit `profile.do`

Open the `profile.do` file in Stata, using the __File > Open…__ menu item, or type &#8984;O (Command-O) on Mac OS X, or type Ctrl-O on Windows. Select __“All Stata Files”__ or __“Do-file (*.do)”__ where asked what file format to show.

Stata will open the `profile.do` file in its do-file editor. At the top of the code, at lines 10-11, replace the folder path in quotes by your own folder path to the `SRQM` folder:

	// Edit this command to reflect your local path to the SRQM folder:
	cap cd "~/Documents/Teaching/SRQM"

Save the modified file using the __File > Save__ item, or type &#8984;S (Command-S) on Mac OS X, or type Ctrl-S on Windows. Then quit Stata when you are done.

### 5. Check your edits

Open Stata again. Your `profile.do` file should guide it to the `SRQM` folder, in which case Stata will say “Welcome” among a few other things:

	Welcome. You are running Stata with the SRQM profile.

	Working directory:
	/Users/fr/Documents/Teaching/SRQM

	Course/         README.md       Replication/
	Datasets/       README.pdf      profile.do
	
	...

If Stata says something else that looks like an error, the most probable cause is that there is a mistake in your folder path, in which case you need to restart this installation guide from Step 3.

You will also get an error message if you modify the names and/or the locations of the `Datasets` and `Replication` folders.

### 6. Type `srqm setup`

Finally, type `srqm setup` in the Command window and press `Enter` to run the setup program for this course. The `srqm setup` command is part of a program that will silently load when you open Stata with this configuration. This configuration makes sure that you can run all course do-files.

The program needs to download a few additional packages, so make sure that you are online when running it. If you are not connected to the Internet, as when you get logged off the Sciences Po wifi network, Stata installation commands will systematically fail.

## Troubleshooting

**Please ask for help as early as possible**, so that we can put configuration issues behind us and move to the actual course. Most issues can be covered in a matter of minutes if your computer is not experiencing a more serious issue.

- **If you do not have access to hard drive space** to perform the above installation, the ‘Teaching Pack’ should be able to run from a USB key plugged to a Sciences Po workstation. This requires the ‘Teaching Pack’ folder to be located at `e:\SRQM` (where your USB key should have loaded). Additional packages will be temporarily installed at location `c:\temp` on your hard drive.

- **If you cannot setup Stata and install additional packages**, you will run into errors in the course do-files when we use non-native, user-coded Stata commands. This can sometimes be circumvented, e.g. by replacing all `fre` commands by `tab` commands. You will also need to minimally configure Stata by hand, starting with the working directory (and memory if running Stata 11 or older).

## Readings

When you are done, you should:

1. turn to the [README](https://github.com/briatte/srqm/blob/master/Course/README.md) file of the `Course` folder, to learn about the course material.
2. turn to the [README](https://github.com/briatte/srqm/blob/master/Datasets/README.md) file of the `Datasets` folder, to learn about the data sources we will use.

Welcome to SRQM, and see you soon!

François (<francois.briatte@sciences-po.org>) and Ivaylo (<ivaylo.petev@sciences-po.org>)
