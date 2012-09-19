* What: SRQM Session 1
* Who:  F. Briatte and I. Petev
* When: 2012-01-26


* ================
* = INTRODUCTION =
* ================


* Hi! Welcome to your first SRQM do-file.

* This line is a comment due to the '*' symbol at its beginning.
* This do-file is fully commented to guide you through the basics.
* In your own code, use comments to document your operations.


* Practice
* --------

* Your mission for next week is to replicate this do-file. That means running 
* it in full, reading the comments along as you execute its commands. Use the 
* course slides to learn about running do-files and read from the Stata Guide 
* to understand the commands used.

* There is no substitute to practice to learn statistical software.


* Interface
* ---------

* Quickly review the Stata windows. The Command window is where you will enter
* all commands, the results of which will show in the Results window. All your
* past commands will also show in the Review window; you can access them again
* by pressing the PageUp key (or Fn-UpArrow on a laptop). Refer to the Stata
* Guide for more help with the Stata interface.

* The Variables window should be empty at that stage, because no dataset is
* currently loaded in Stata. Identically, the Data Editor should be empty if
* you open it, either by typing the 'browse' or 'edit' commands, or by using
* the 'Window > Data Editor' menu item from the graphical user interface. 
* Again, refer to the Stata guide for additional help.


* Commands
* --------

* Tip (1): Get to learn some syntax
*
* - Stata commands share a similar syntax, most commonly: 
*   command <argument>
* - Most Stata commands will call one or several variables as the main argument:
*   command <variable>
* - Most Stata commands will also allow one or more options, after a comma:
*   command <variable>, <options>

* Tip (2): Run all lines in sequential order
*
* - Applies to all do-files.
* - Requires you execute do-files in full.
* - Requires you know where you are in your code.
*
clear
set obs 100
gen test=1
ren test x // This line will not run if you do not run the previous ones.

* Tip (3): Run multiple lines together
*
* - Applies every time you see '///' at the end of a line.
* - Requires you select all adjacent lines. Use Ctrl-L (Win) or Cmmd-L (Mac).
* - Requires you run them with Ctrl-D (Win) or Cmmd-Shift-D (Mac).
*
di "This is a test. Execute me by selecting this line, " ///
	"and this line too, " _newline ///
	"and this line too. Well done :)"


* Coursework
* ----------

* Remember that you will have to produce such a do-file for your own research
* project. The easiest option is to use the built-in do-file editor in Stata,
* which features syntax colouring and keyboard shortcuts to edit and execute
* do-files. You can also use any plain text editor to do so.


* =========
* = SETUP =
* =========


* The following steps teach you about setting up Stata on any computer. It is
* recommended that you use your own computer for this class, because this setup
* works best if you have extensive privileges over your computer system. The
* computers at Sciences Po grant you user but not admin privileges, which makes
* setting up Stata much less convenient.

* For starters, make sure that you just launched Stata and have nothing stored
* in memory. This command will ensure that this is the case:
clear 

* (1) Memory
* ----------

* Skip this section if you are running Stata 12+.

* Your first step with Stata consists in allocating enough memory to it. The
* default amount of memory that Stata loads at startup is too small to open
* large datasets: if you forget to set memory, Stata will reply with an error
* message. The basic command to allocate 500MB memory follows:
cap set mem 500m

* Note: the 'cap' (capture) prefix is not part of the command, it is an extra
* safety to allow this do-file to run through the line even if it returns an
* error, as it should if you are using Stata 12+.

* You need to repeat that command every time you run Stata. The command works
* only if Stata has no data in storage: if you already have a dataset opened,
* then Stata will reply with an error message. Fortunately, if you are running
* Stata from your own computer, you can set memory permanently:
cap set mem 500m, perm 

* There is more to learn about memory size and default settings in Stata, but
* for the purpose of this course, this will largely suffice. Furthermore, if
* you are running Stata 12, you are spared from setting memory yourself: Stata
* will do it automatically.


* (2) Breaks
* ----------

* By default, Stata uses screen breaks. If you forget to disable those, the
* 'Results' window will nag you with useless prompts. Save yourself the hassle
* of screen breaks by disabling them:
set more off

* Identically to memory, you can disable screen breaks permanently if you are
* running Stata from your own computer:
set more off, perm


* (3) Packages
* ------------

* Stata can be extended by installing packages, just like you would install a
* plugin or an extension for another software. Installing packages in Stata is
* pretty straightforward thanks to its centralised, online server called 'SSC'.
* Make sure that you are connected to the Internet before continuing, and refer
* to tutorials or to Stata help pages for additional documentation on packages.

* You should be able to permanently install packages on your own computer, but
* not on Sciences Po computers. In the latter case, you will need to perform a
* temporary installation at the beginning of each session. To do so, uncomment
* the following line by removing the '*', and run the command:

* sysdir set PLUS "c:\temp"

* This course makes heavy use of the 'fre' package to view frequencies.
* Install the package with this command (requires that you are online):
ssc install fre, replace

* The code below will install a selection of packages that should be installed
* to run the course do-files properly. These packages should have already been
* installed by the 'srqm setup' command that you should have run when starting
* to use the SRQM Teaching Pack, but this additional check might avoid running
* into 'unknown command' errors later in class :)
ssc install catplot, replace
ssc install spineplot, replace
ssc install tabout, replace
ssc install tab_chi, replace
ssc install estout, replace

* The settings covered in this section of the do-file should now be permanently
* stored on your computer. You will not need to come back to them. The settings
* covered in the next section are different in that respect.


* ===========
* = STARTUP =
* ===========


* The following steps cover starting up Stata for this specific course session.
* You will need to adapt them to your computer system, so pay extra attention.


* (4) Working directory
* ---------------------

* Set the working directory (folder) to the main SRQM folder on your computer.
* The working folder is where Stata will look to open and save stuff like logs
* or datasets. This line sets the working directory on my (François) computer:
cd "/Users/fr/Documents/Teaching/SRQM/"

* I use Mac OS X, which is why my file path takes that form. Ivaylo uses a PC,
* and his own working directory is located at "C:\Users\Ivo\Desktop\SRQM". You
* will need to identify the file path on your own computer. We recommend that
* you choose a simple location for the SRQM folder and then keep it there.

* The path to your main SRQM folder depends on your operating system. If you do
* not know that path, use the 'File > Change Working Directory...' menu item in
* the Stata graphical user interface to select your main SRQM folder.

* It is crucial that you understand how to set the working directory, since we
* will open datasets and save log files from there. We also assume that you are
* using the default folder structure from the SRQM Teaching Pack. If not, you
* will need to replace "Datasets/" and "Replication/" with your own choices of
* folders throughout the course.


* (5) Dataset
* -----------

* We will now load data from the U.S. National Health Interview Survey (2009).
use "Datasets/nhis2009.dta", clear

* The 'clear' option gets rid of any data previously loaded into memory, since
* Stata can only open one dataset at once.

* All datasets are in the SRQM Teaching Pack, and will load only if your working
* directory is correctly set. The README file of the Datasets folder holds links
* to essential documents for you to read.
use "Datasets/ess2008.dta", clear
use "Datasets/wvs2000.dta", clear
use "Datasets/nhis2009.dta", clear // etc.

// Show all datasets for this course.
ls "Datasets/*.dta"

* Tip: an additional package can help you search for variables across datasets.
ssc install lookfor_all, replace
lookfor_all health, dir(Datasets) // requires SRQM set as the working directory


* (6) Log
* -------

* You can save the commands and results from this do-file to a log file, which
* will serve as a backup of your work. To log this session, type:
log using "Replication/week1.log", name(week1) replace

* The log command will now create a history of your work on this do-file. You
* should keep it for replication purposes. It will log all your commands and
* their results, including commands that returned an error. Refer to the Stata
* Guide for further guidance on log files, and do not forget to produce logs in
* the .log plain text format rather than in the less handy SMCL default format.
* Also make sure that you specify the 'replace' option to overwite any previous
* log file that might have been created by running this do-file in the past.
* The 'name' option can be omitted.

* Now run these example commands (do not worry about the comments):

d year sex weight raceb // describe a few variables
keep if year==2009 // keep observations for year 2009

* Calculate the frequencies for each racial-ethnic group.
fre raceb

* Obtain summary statistics for the weight variable.
su weight

* List gender groups from the sex variable.
tab sex

* Crosstabulate sex and race.
tab raceb

* Plot average weight by sex and race.
gr dot weight, over(raceb) over(sex) name(weight_race_sex, replace)

* To close the 'week1' log file previously opened, type the following command:
log close week1

* You will not be able to run the above command if no 'week1' log is opened.
* To close all potentially opened logs, use the following command (uncomment
* it first by removing the asterisk at the beginning of the command line):
* cap log close _all

* If you now go to your 'Replication' folder and open the week1.log file with 
* any plain text editor, you will find a copy of everything that was entered 
* between the 'log using' and 'log close' commands, including comments, the 
* example above and its output for each command.

* The dot graph will need to be saved separately: this can be done in several
* ways that are documented in the course slides and in the Stata Guide. The
* Stata help pages also cover each graph command. Have a look at them:
help graph

* Identically, there is more about logs in the Stata Guide and in several of
* the tutorials included in the course material, but we also recommend that you
* use the Stata help pages, as explained below.


* ========
* = HELP =
* ========


* It is essential to the methods covered by this course that you learn to use
* help extensively. The course material includes a lot of help with Stata, but
* you should also learn to use the internal Stata help pages.

* This command will serve as an example:
su weight if raceb==1, d

* To understand what 'su' means and does, type 'help' followed by 'su':
help su

* The underline tells you that 'su' is shorthand for 'summarize', which returns
* a few summary statistics for the variable 'weight' in this example. The 'if'
* component of the command is also documented in Stata:
help if

* The 'd' option is documented on the help page for 'summarize'. It specifies
* that you want more detailed statistics: 'd' is shorthand for 'detail' here.

* The 'help' command itself can be abbreviated to simply 'h'. Try this example
* to realise how quick accessing Stata help pages can be:
h su

* Finally, take a look at the help page for 'cap' prefix that we used with the
* 'log close' command above. You will not need to use this command yourself, 
* but it comes in handy if you engage in more advanced Stata programming.
h cap  


* ========
* = EXIT =
* ========


* The course will teach you to write commands like the ones featured in this
* do-file. If you combine practice, documentation and a bit of intuition, you
* can learn most of the Stata syntax in a few weeks through trial-and-error.
* Get ready by practicing as soon as possible! Programming works that way.

* Last words: when you leave Stata, DO NOT SAVE YOUR DATASET. Keep it intact as
* originally downloaded. Instead, save the do-file that contains the commands
* you used to perform your analysis. Stata will automatically save the log file
* for you when you shut it down, so this requires no action on your side. For
* additional help, please turn again to the Stata Guide.

* Close log (if opened).
cap log close week1

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
