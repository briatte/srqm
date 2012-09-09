# SRQM: Teaching Pack

This document explains how to setup a computer to follow the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) (SRQM) course run at Sciences Po by François Briatte and Ivaylo Petev.

Every student gets a copy of this ‘[Teaching Pack](http://f.briatte.org/srqm/)’ on the first session, and gets assigned to read this file and setup their machines as a warm-up exercise to the course.

* * *

## Requirements

The course requires a working copy of [Stata 12](http://www.stata.com/), by StataCorp. Minimal system requirements are Mac OS X 10.5 ("Leopard") or Windows XP SP2 (Service Pack 2).

Backward compatibility extends back to Stata 10, which means that the course do-files should be able to run after a few adjustments on older operating systems.

**Please ask for help as early as possible**, so that we can put configuration issues behind us and move to the actual course. Most issues can be covered in a matter of minutes if your computer is not experiencing a more serious issue.

## Installation

The following steps explain how to configure a system to work with Stata for the duration of this course.

### 1. Install Stata

Stata should be pre-installed on your workstation.

Make sure that you are running Stata from the __"Applications"__ folder or its system equivalent, such as __"Program Files"__ on Windows. Running Stata from outside your application folder might cripple the software.

### 2. Copy the ‘Teaching Pack’

Move the whole `SRQM` folder to a **stable** and **easily accessible** location on your hard drive.

You can rename the `SRQM` folder to whatever you like, as long as you do not modify it or move it later on. If you do, you will need to update your installation (see the first item in the 'Troubleshooting' section).

### 3. Set the working directory

Now, open Stata and set the `SRQM` folder (or whatever your renamed it to) as the **working directory**.

Use the __File > Change Working Directory…__ menu item, or type &#8984;&#8679;J (Command-Shift-J) on Mac OS X. The folder path that appears in the Results window will be used to access the course material throughout the semester.

### 4. Run the course profile

Type `run profile` in the Command window and press `Enter`.

This command runs the `profile.do` file that will setup Stata for this course. It will create another `profile.do` file in your Stata application folder that will point to the `SRQM` folder. This setup makes sure that you will be able to work from the ‘Teaching Pack’ for the whole semester.

## Troubleshooting

### Uninstalling
You will not need this setup when the course is over. At the end of the semester, you can erase the `profile.do` file that you will find in your Stata application folder. Alternatively, just type `srqm leave` in the Command window. Other issues might also show up with your installation:

### Updating
**If you need to update your installation** because you renamed or moved the ‘Teaching Pack’ on your hard drive after performing the setup, simply erase the `profile.do` file that you will find in your Stata application folder and then run again through the installation steps detailed above. Please ask for help in class if you get stuck.

### Running from a USB key
**If you do not have access to hard drive space** to perform the above installation, the ‘Teaching Pack’ should be able to run from a USB key plugged to a Sciences Po workstation. Follow the instructions above and the course will try to run in 'experimental mode' directly from the USB key. This mode might easily fail to install additional packages.

### Running without setup
**If you cannot setup Stata and install additional packages**, you will occasionally run into errors in the course do-files. This can sometimes be circumvented, e.g. by replacing all `fre` commands by `tab` commands. You will also need to minimally configure Stata by hand, starting with the working directory (and `memory` if running Stata 11 or older).

## Readings

When you are done, you should:

1. turn to the [README](https://github.com/briatte/srqm/blob/master/Course/README.md) file of the `Course` folder, to learn about the course material.
2. turn to the [README](https://github.com/briatte/srqm/blob/master/Datasets/README.md) file of the `Datasets` folder, to learn about the data sources we will use.

Welcome to SRQM, and see you soon!

François (<francois.briatte@sciences-po.org>) and Ivaylo (<ivaylo.petev@sciences-po.org>)
