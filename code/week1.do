
* Check setup. This line appears in every course do-file. It makes sure that
* you have the appropriate files and packages to successfully run the code.
run setup/require fre lookfor_all

* Allow Stata to scroll through the results.
set more off

/* ------------------------------------------ SRQM Session 1 -------------------

   F. Briatte and I. Petev

 - Hi! Welcome to your first SRQM do-file.

 - You are probably viewing this file from the Stata do-file editor, after
   opening it with the -doedit code/week1- command. If so, you are
   doing it right: congratulations.
   
 - You will be reading through your first do-file in just a minute. It is
   essential that you read through each week's do-file to become familiar
   with Stata commands.

 - We will start exploring do-files in class, and you get to finish them on your
   own as homework, along with reading one chapter from the course handbook and
   a few sections from the Stata Guide. These tasks complement each other.
   
 - Everything that you learn from the course do-files will be put to use in your
   research project. Practice with Stata by trying out commands as you learn
   them. If things do not work out, try again after checking the command syntax.

   Last updated 2013-08-17.

----------------------------------------------------------------------------- */


* Comments
* --------

* This line is a comment due to the '*' symbol at its beginning. It takes a
* green colour in the Stata do-file editor. This do-file is fully commented
* to guide you through the basics. In your own code, you should also use
* comments to document and section your operations.

// note: lines or chunks of code that start with '//' are also comments, ...

/* and blocks of code that start with that symbol
   and end with the reverse one are also comments */

// ... and Stata helps you to detect comments by coloring them in green.

* When you see the words 'uncomment to run', it means 'remove the comment to run
* the code'. Remove the asterisk and trailing space on the next line, then run 
* it by copy-pasting it into the Command window and pressing Enter:

* di "Hello world."

* When I cite a Stata command in the comments, I cite it -between dashes-, but
* the dashes are not part of the command. They are just here to delimit where
* the command starts and where it stops.


* Practice
* --------

* Your mission for next week is to replicate this do-file. That means running
* it in full, reading the comments along as you execute its commands. Use the
* course slides to learn about running do-files and read from the Stata Guide
* to understand the commands used.

* There is no substitute to practice to learn statistical software. Code is
* like music, you will recognize the tune and notation if you listen to it.
* When you learn to code, you learn to play, either for yourself or for the
* audience of your programming language. For Stata, the audience is a pretty
* wide range of people and institutions.


* Interface
* ---------

* Quickly review the Stata windows. The Command window is where you will enter
* all commands, the results of which will show in the Results window. Your
* past commands will also show in the Review window. Finally, the Variables
* window should be empty at that stage, because no dataset is currently loaded
* in Stata. More windows will be opened as we go on.

* Note that we will use windows but not, as you are used to, menus. The menu
* interface in Stata offers point-and-click accessibility but is not suited
* for programming purposes. Instead, everything we do will be command-based.


* ====================
* = WARM-UP EXERCISE =
* ====================


* Type or copy and paste the following line to the Command window:
pwd

* The previous command returns the path to your working directory. It prints
* its output to the Results window, and the command is stored in history as
* shown in the Review window.

* Now, load a sample Stata dataset that is included with the software:
sysuse lifeexp, clear

* The previous command loads data in the background. You can access the data
* with the following command. Close the window after taking a look.
browse

* Back to the main window, the Variables window shows the list of variables.
* We are going to use two of them to build a plot. Type the following:
scatter lexp safewater

* This command creates your first Stata graph. Close the Graph window when
* you are done inspecting the graph. Finally, type the following command after
* uncommenting it (remove the asterisk and trailing space):

* doedit

* The previous command creates an empty do-file in the Do-file Editor, so that
* you can edit it from Stata directly. Copy and paste the four lines below into
* that empty do-file window:

// Example do-file.
sysuse lifeexp, clear
sc lexp safewater
clear

* Notice that the syntax used for the -scatter- command is different because
* it has been abbreviated to -sc-. The first line is a comment that uses an
* alternative way to tell Stata that the line is a comment. Save and close
* the do-file window when you have copied the full code to it.

* The do-file can now be run with the following command (uncomment to run):
* do example

* The do-file can now be erased with the following command (uncomment to run):
* rm example.do

* These commands quickly show you how we are going to use the software: by
* running (executing) code from Stata do-files, so that you can write your
* own do-file for your research projects.


* ============
* = COMMANDS =
* ============


* Tip (1): Get to learn some syntax
* ---------------------------------

* Most Stata commands share an identical syntax that calls one or several
* variables as the main argument:

*   command variable

* Most Stata commands will also allow one or more options after a comma.
* Optional arguments are shown in brackets in the Stata help pages:

*   command variable [, options]


* Tip (2): Run all lines in sequential order
* ------------------------------------------

* You need to execute all lines of a do-file in order to avoid execution errors.
* The example below illustrates the point:

clear
set obs 100
gen test = 1
ren test x // This line will not run if you do not run the previous ones first.
           // The command intends to rename the 'test' variable, but 'test' does
           // not exist unless you create it first by running the previous line.


* Tip (3): Keyboard shortcuts for Mac / Win
* -----------------------------------------

/* Mac:

   - Cmd-L (Ctrl-L) selects a whole line
   - Shift + Up/Down arrows selects or deselects neighbouring lines
   - Cmd-Shift-D (Ctrl-D) executes the selection
   - Cmd-` (Alt-Tab) switches between application windows

   Cmd is the 'Command' key. The ` ('back accent') key might be hard to
   find on non-QWERTY keyboards, so check if you see it on your system.

   Win:

   - Ctrl-L selects a whole line
   - Shift + Up/Down arrows selects or deselects neighbouring lines
   - Ctrl-D executes the selection
   - Alt-Tab switches between application windows */
   
* Do not confuse Mac and Win keyboard shortcuts, or you might execute the whole
* do-file by mistake! If that happens, or if you get lost while replicating a 
* do-file, the safest option is to run it again from the top. To do that, make
* your life easier with keyboard shortcuts: select the line where you want to
* start again by pressing Cmd-L (Win: Ctrl-L), then press Cmd-Shift-UpArrow
* (Win: Ctrl-Shift-UpArrow), and finally press Cmd-Shift-D (Win: Ctrl-D) to run
* the code again down to your initial line.

* Yes, all this takes a bit of practice. Think of it as music: learning to read
* and write code is like learning to read and write music sheets, and learning 
* to type and run code is like learning a bit of piano.


* Tip (4): Command navigation
* ---------------------------

* You can navigate through past commands from the Command window by using the
* PageUp and PageDown keys. Try running the following command after taking out
* the asterisk at the beginning of the line:

* memory6

* You should get an error: the right command is -memory- without the final '6'.
* To quickly correct your mistake, press PageUp and Stata will print the command
* again to your Command window, allowing you to quickly correct the syntax of
* your command and try it again without the final '6'.


* Tip (5): Run multiple lines together
* ------------------------------------

* When you see '///' at the end of a line, you have to select the next line too
* and execute the lines together from the do-file: copy-pasting to the Command
* window will not work. Use Ctrl-L (Win) or Cmd-L (Mac) and Shift+DownArrow to
* select the lines, then run them with Ctrl-D (Win) or Cmd-Shift-D (Mac).

di "This is a test. Select this line, " ///
    "and this line too, " _n ///
    "and this line too. Now, execute from the keyboard. Well done :)"

* You will have to do the same for code loops, such as 'foreach {}' loops.
* You will usually be warned before in the comments. Finally, note that these
* multiple-line commands do *not* work if you copy-paste from the do-file to
* the Command window. This is why I recommend that you learn keyboard shortcuts
* quickly, so as to minimize issues with code execution and focus on the rest.


* =========
* = SETUP =
* =========


* The following steps teach you about setting up Stata on any computer. Start
* by making sure that you have nothing stored in Stata memory by wiping off
* any data in memory with the -clear- command:
clear

* The settings covered in this section of the do-file can be taken care of by
* a setup utility written for the course. Please turn to the README file of the
* SRQM folder for instructions, or follow the procedure in our first classes.


* (1) Memory
* ----------

* Skip this section if you are running Stata 12+.

* Your first step with Stata consists in allocating enough memory to it. The
* default amount of memory that Stata loads at startup is too small to open
* large datasets: if you forget to set memory, Stata will reply with an error
* message. The basic command to allocate 500MB memory follows:
set mem 500m

* You need to repeat that command every time you run Stata. The command works
* only if Stata has no data in storage: if you already have a dataset opened,
* then Stata will reply with an error message. Fortunately, if you are running
* Stata from your own computer, you can set memory permanently:
set mem 500m, perm

* There is more to learn about memory size and default settings in Stata, but
* for the purpose of this course, this will largely suffice. Furthermore, if
* you are running Stata 12, you are spared from setting memory yourself: Stata
* will do it automatically.


* (2) Screen breaks
* -----------------

* By default, Stata uses screen breaks. If you forget to disable those, the
* 'Results' window will nag you with useless 'more' prompts and you will have
* to scroll results manually. Save yourself the hassle by disabling them:
set more off

* In fact, let's try to disable them permanently on your computer:
set more off, perm


* (3) Additional commands
* -----------------------

* Stata can be extended by installing packages, just like you would install a
* plugin or an extension for another software. The packages add new commands or
* graph schemes to Stata.

* Make sure that you are connected to the Internet before continuing, so that
* Stata can connect to the SSC archive and to other online sources. If you are
* using a Sciences Po workstation, you will also need to uncomment and run the
* following command to avoid an issue with admin privileges:

* sysdir set PLUS "c:\temp"

* This course makes heavy use of the -fre- command to view frequencies. The
* course setup should have installed it for you, but let's practice installing
* additional Stata commands. Install the -fre- command (again) by uncommenting
* and running this command while online:

* ssc install fre

* Now read the package description:
ado de fre


* (4) Working directory
* ---------------------

* The working directory is where Stata will look to open and save stuff like
* datasets or logs. Use the -pwd- command to see where Stata is looking now.
pwd

* Use -ls- command to list the files where Stata is looking. The -w- option will
* cause the command to print only the filenames without system information.
ls, w

* For this course, you need to set the working directory to the SRQM folder.
* Use the 'File :: Change Working Directory...' menu item in the Stata graphical
* user interface to select the SRQM folder. The path to that folder will show in
* the Results window. It might look like this:

* cd ~/Documents/Teaching/SRQM/

* I use Mac OS X, which is why my file path takes that form. Ivaylo uses a PC,
* and his own working directory might be set like this:

* cd C:\Users\Ivo\Desktop\SRQM

* You will need to identify that file path on your own computer. Choose a simple
* location for the SRQM folder and then keep it there without renaming it or any
* of the folders that lead to it. Be careful with that, or you will get errors
* when trying to study for the course.

* The -cd- command shown above navigates through your folders. The next example
* assumes that you are now in the SRQM folder. It will select the folder that
* contains the course do-files. Note that if the path contained spaces, you
* would need to add quotes around it.

* cd code

* Uncomment and run the line above, then uncomment and run the next command to
* go back one level and return to the SRQM folder:

* cd ..

* Finally, you can list the files without moving to a directory. The following
* command shows the contents of the data/ folder:
ls data/, w


* (5) Log
* -------

* You can save the commands and results from this do-file to a log file, which
* will serve as a backup of your work. To log this session, type:
log using code/week1.log, replace

* The log command will now create a history of your work on this do-file. You
* should keep it for replication purposes. It will log all your commands and
* their results, including commands that returned an error. Refer to the Stata
* Guide for further guidance on log files, and do not forget to produce logs in
* the .log plain text format rather than in the less handy SMCL default format.
* Also make sure that you specify the -replace- option to overwite any previous
* log file that might have been created by running this do-file in the past.
* The -name- option can be omitted.

* Now run these example commands (do not worry about the comments, you can leave
* them where they are and 'execute' them too, Stata will just ignore them):

* Loading data from the U.S. National Health Interview Survey (1997-2011).
use data/nhis9711, clear

* The -clear- option gets rid of any data previously loaded into memory, since
* Stata can only open one dataset at once.

* Describe a few variables.
d year sex weight raceb

* Keep observations only for year 2009.    
keep if year == 2011

* Calculate the frequencies for each racial-ethnic group.
fre raceb

* Obtain summary statistics for the weight variable.
su weight

* List gender groups from the sex variable.
tab sex

* Crosstabulate sex and race.
tab sex raceb

* Plot average weight by sex and race. You must run both lines below together.
gr dot weight, over(raceb) over(sex) ///
	name(weight_race_sex, replace)

* To close the log file previously opened, type the following command:
cap log close

* You will not be able to run the above command if no log is opened. The -cap-
* prefix allows you to run the command and continue even if it returns an error.

* If you now go to your code/ folder and open the week1.log file with
* any plain text editor, you will find a copy of everything that was entered
* between the -log using- and -log close- commands, including comments, the
* example above and its output for each command. You can view the file in Stata:
view code/week1.log

* The dot graph will need to be saved separately: this can be done in several
* ways that are documented in the course slides and in the Stata Guide. The
* Stata help pages also cover each graph command. Have a look at them:
help graph

* Identically, there is more about logs in the Stata Guide and in several of
* the tutorials included in the course material, but we also recommend that you
* use the Stata help pages, as explained below.


* ============
* = DATASETS =
* ============


* (1) List datasets
* -----------------

* Show all datasets for this course. The asterisk in the command is an escape
* character that causes the command to return all matches (within .dta files).
* The -w- option is to make the output less verbose.
ls "data/*.dta", w

* Note: the quotes in the command above are optional. Quotes are only required
* when the path contains spaces. For example, if the data/ folder were called
* 'Course datasets', quotes would be necessary to run -ls "Course datasets"-.
* This means that, if the path to your working directory contains quotes, you
* must enclose it in quotes if you use -cd- to set your working directory.

* Typical example.
* cd "/Users/somestudent/Documents/Sciences Po/4A/Semester 1/Stats stuff/SRQM"

* Now back to the datasets.

* All datasets are in the data/ folder of the SRQM Teaching Pack. The commands
* used to load them in the course do-files will work only if you have correctly
* set your working directory to the SRQM folder first. The course setup does it
* for you, unless you move the SRQM folder, in which case it will stop working.

* The README file of the data/ folder holds links to essential documents for you
* to read if you want to use the data for your research project. You can start 
* looking for variables of interest by using the -lookfor- command after loading
* one of the course datasets.


* (2) European Social Survey Round 5, 2008
* ----------------------------------------

* Load.
use data/ess0810, clear

* Example search.
lookfor health immig


* (3) Quality of Government, 2013
* -------------------------------

* Load.
use data/qog2013, clear

* Example search.
lookfor devel orig


* (4) World Values Survey, 2000
* -----------------------------

* Load.
use data/wvs2000, clear

* Example search.
lookfor army homo


* (5) General Social Survey, 2012
* -------------------------------

* Load.
use data/gss0012, clear

* Example search.
lookfor army homo

* Note that this dataset holds more than one year of data.
tab year

* This means that you will have to reduce it to one year of observations before
* analyzing it. More on that next week. For now, back to looking for variables.


* (6) Search across datasets
* --------------------------

* Tip: an additional package can help you search for variables across datasets.
* It should have been installed by the course setup utility. If not, install it
* yourself with -ssc install lookfor_all- (requires an Internet connection).
lookfor_all health, dir(data)

* The command above, like all commands that calls datasets or do-files,
* requires that the SRQM folder has been set as the working directory.

* Because some commands like -lookfor_all- require to be installed before you
* run the course do-files, the course setup utility has installed them in our
* first session together. However, by security, I also include a small loop in
* all course do-files that automatically detect uninstalled commands and fetch
* them from online if needed. These loops look like the one below and require
* that you select all four lines together and then execute them.
foreach p in lookfor_all {
	cap which `p'
	if _rc == 111 cap noi ssc install `p'
}

* The syntax of these loops is typically more complex than anything that you
* will have to read or write for this course, so do not panic if they do not
* make sense to you. Focus on getting the rest of the code straight.


* ========
* = HELP =
* ========


* It is essential to the methods covered by this course that you learn to use
* help extensively. The course material includes a lot of help with Stata, but
* you should also learn to use internal Stata help pages, accessible with the
* -help- command. If you want to understand the following command:
*
* su weight if raceb == 1, d

* To understand what -su- means and does, type -help- followed by -su-:
help su

* The underline tells you that -su- is shorthand for -summarize-, which returns
* a few summary statistics for one or more variables. The -help- command itself
* can be abbreviated to simply -h-. The -if- component of the command is also
* documented in Stata:
h if

* Finally, the -d- option shown in the example is documented on the help page
* for -summarize-. It produces more statistics: -d- is shorthand for -detail-.
* Do not confuse it with the -d- shorthand  for the -describe- command, which
* lists the variables in the current dataset.


* =======
* = END =
* =======


* The course will teach you to write commands like the ones featured in this
* do-file. If you combine practice, documentation and a bit of intuition, you
* can learn most of the Stata syntax in a few weeks through trial-and-error.
* Get ready by practicing as soon as possible! Programming works that way.
* Oh, and congratulations for reaching this line.

* Last words: when you leave Stata, DO NOT SAVE YOUR DATASET. Keep it intact as
* originally downloaded. Instead, save the do-file that contains the commands
* you used to perform your analysis. Stata will automatically save the log file
* for you when you shut it down, so this requires no action on your side. For
* additional help, please turn again to the Stata Guide.

* Close log (if still opened, which it should not).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
