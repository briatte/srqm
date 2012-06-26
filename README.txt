# SRQM: Startup Guide

This document explains how to survive the Statistical Reasoning and Quantitative Methods course run at Sciences Po by François Briatte and Ivaylo Petev.

## What is this?

This is the "Teaching Pack" for the course.

It contains the course material, at the exception of the course handbooks, _[Making History Count](http://www.cambridge.org/gb/knowledge/isbn/item1113695/)_ by Feinstein and Thomas (2003), and _[Introduction to the Practice of Statistics](http://bcs.whfreeman.com/ips6e/)_ by Moore, McCabe and Craig (2009).

The course also requires a working copy of Stata 10+ for Mac OS X 10.4+ or Windows XP SP2+. The course was written under that version, and later upgraded for Stata 11 and then Stata 12. It might run alright on older versions.

The [course web page](http://f.briatte.org/teaching/quanti/) contains links to the most pertinent items of the Teaching Pack:

- course syllabus
- course guide (Stata Guide)
- session slides
- replication do-files
- replication datasets

Every student gets a copy of the Teaching Pack on the first session, and gets assigned to read this file as a warm-up exercise. You will also get weekly emails about coursework, assignments and logistics.

## Installation

This installation guide covers everything you need to run through the whole course.

## 1. Copy the Teaching Pack to your computer.

The Teaching Pack needs to be installed at a stable and easily accessible location on your hard drive. It can also run temporarily from a USB key on Sciences Po workstations.

You can rename the SRQM folder to whatever you like, but you will have to use its new name in replacement of `SRQM` in the following instructions. __“SRQM”__ is also the acronym prefix used in all email correspondence for this course.

## 2. Install Stata

Stata will be pre-installed on your workstation.

Make sure that you are running Stata from the __"Applications"__ folder or its system equivalent, such as __"Program Files"__ on Windows. Running Stata from outside your system application folder might cripple the graphic user interface or even make Stata commands inoperable.

Now, open Stata.

## 3. Set the working directory

To set the SRQM folder as the working directory, use the __File__ menu, __Change Working Directory…__ item, or type &#8984;&#8679;J (Command-Shift-J) on Mac OS X. Alternatively, use the `cd`, `dir` and `pwd` commands if you know some Stata already.

Watch the folder path that Stata will display when you select the SRQM folder:

	. cd "/Users/fr/Documents/Teaching/SRQM"
	/Users/fr/Documents/Teaching/SRQM

The folder path will look different on your local system, especially on Windows, which uses backslashes:

	. cd "C:\Users\Ivo\Documents\Teaching\SRQM"
	C:\Users\Ivo\Documents\Teaching\SRQM

This folder path will be used to access the course material throughout the semester.

If you modify the name and/or the location of the SRQM folder during that period, you will need to run through this installation guide again to update your settings.

## 4. Copy the folder path to `profile.do`

Open the `profile.do` file in Stata, using the __File__ menu, __Open…__ item, or type &#8984;O (Command-O) on Mac OS X, or type Ctrl-O on Windows. Select __“All Stata Files”__ or __“Do-file (*.do)”__ where asked what file format to show.

Stata will open the `profile.do` file in its do-file editor. At the top of the code, at lines 10-11, replace the folder path in quotes by your own folder path to the `SRQM` folder:

	// Edit this command to reflect your local path to the SRQM folder:
	cap cd "~/Documents/Teaching/SRQM"

Save the modified file using the __File__ menu, __Save__ item, or type &#8984;S (Command-S) on Mac OS X, or type Ctrl-S on Windows. Then quit Stata when you are done.

## 5. Check your edits

Open Stata again. Your `profile.do` file should guide it to the `SRQM` folder, in which case Stata will say “Welcome” among a few other things:

	Welcome. You are running Stata with the SRQM profile.

	Working directory:
	/Users/fr/Documents/Teaching/SRQM

	Datasets/       README.md       utils.sh*      Course/
	Replication/    profile.do
	
	...

If Stata says something else that looks like an error, the most probable cause is that there is a mistake in your folder path, in which case you need to run through this installation guide again. You will also get an error message if you have modified the names of the `Datasets` or `Replication` folders.

If you are trying to run the `SRQM` folder from a USB key at Sciences Po, your `profile.do` file might find it for you. It will scan location `e:\SRQM` and also try to allow temporary package installations at `c:\temp`.

## 6. Finish

Finally, type `srqm setup` in the Command window and press `Enter` to run the setup program for this course.

The program needs to download a few additional packages, so make sure that you are online when running it. If you are not connected to the Internet, as when you get logged off the Sciences Po wifi network, Stata installation commands will systematically fail.

The `srqm install` command is part of a program that will silently load when you open Stata with this configuration.

## Readings

When you are done, your first reading should be the Stata Guide, Part 1 (Sections 1-4), to learn more on the course contents and requirements. You will also want to browse through the opening sections of your handbook.

A list of readings is available in your syllabus and as a [Google document](http://goo.gl/BJHkQ). We will use a few more Google documents throughout the course, in particular to log your [student projects](http://goo.gl/brYmB).

Welcome to the course, and see you soon!

François (<francois.briatte@sciences-po.org>) and Ivaylo (<ivaylo.petev@sciences-po.org>)
