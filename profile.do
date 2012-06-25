* What: SRQM profile
* Who: F. Briatte and I. Petev
* When: 2012-04-20

// Use this do-file to set up Stata for the duration of the course.
// Stata reads silently through this file at startup, so as long as
// you set the command below properly, the replication material for
// this course should run without producing any errors.

// Edit this command to reflect your local path to the SRQM folder:
cap cd "~/Documents/Teaching/SRQM"

// If you are running from a USB key at Sciences Po, this might detect it:
if _rc != 0 {
	di as err "Failed setting the working directory."
	di as err "Trying to load from a USB key..." _n
	
	// working directory
	cap cd "e:\SRQM"
	if _rc != 0 global wd "Failed to find the e:\SRQM folder."

	// for package installs
	cap sysdir set PLUS "c:\temp"
	if _rc != 0 di as err "Failed to allow package installs."
}

// The rest of the file will show some information when Stata starts, and will
// create the srqm program, a setup utility for the course that will install a
// few additional packages to Stata. Some of these packages are used in course
// do-files. Type in 'srqm' to get the program commands and options.

* SRQM working directory check.
if "$wd" != "" {
	di as err "$wd" _n
	di as err "Please run through the installation described in the README of your SRQM folder."
	di as err "Ask us for assistance if you need any."
	exit -1
	}
	else {
	noi di as inp _n "Welcome. You are running Stata with the SRQM profile."
	noi di as inp _n "Working directory:"
	noi pwd
	noi ls, w
}

* SRQM folders check.
foreach f in  "Datasets" "Replication" {
	noi di as inp _n "`f'" " folder:"
	cap cd "`f'"
	if _rc != 0 {
		di as err "Stata cannot find the " "`f'" " folder, which breaks paths in SRQM do-files."
		di as err "Please adjust the folder names or reinstall the original SRQM Teaching Pack."
		exit -1
	}
	noi pwd
	if "`f'" == "Datasets" noi ls *.dta, w
	if "`f'" == "Replication" noi ls *.do, w	
	cd ..
}

* SRQM
*
* Run this script when the course starts to setup Stata. You must be online to
* execute the script in full, and you must have properly installed Stata on your
* computer first.  

* To run the script, type one of the commands below:
*
* srqm setup (to make a few permanent settings and install a few packages)
* srqm check (to run some routine checks on your system and package files)
*
* Add 'verbose' after any command to produce more detailed output.
* The 'check' command also accepts 'offline' or 'online' to run all do-files.

cap pr drop srqm
program srqm

	* Cleanup.
	clear *
	cap log close _all

	local verbose = ("`2'" == "verbose")
	local updates = ("`2'" == "updates")

	if "`1'" == "setup" | "`1'" == "check" {
		* Log.
		qui log using `1'.log, name(SRQM) replace

		di as inp "Running SRQM in " `"`1'"' " mode on Stata " c(stata_version)
	}
	else {
		* Error.
		di as err "Please specify an option:"
		di as inp "  srqm setup" as txt " (to setup stuff)"
		di as inp "  srqm check" as txt " (to check stuff)" _n
		di as txt "For extra geeky results:"
		di as txt " - add " as inp "verbose" as txt " to produce tons of additional output"
		di as txt " - add " as inp "updates" as txt " to try out every single Stata update"
		di as txt _n "Bye, and see you soon!"
		exit 198
	}

	* System.
	di as inp _n "Looking at system settings..."
	if "`1'" == "setup" {
		* Memory.
		if c(version) < 12 {
			cap set mem 500m, perm
			if _rc==0 memory
			if _rc!=0 di as err "Failed to set memory to 500M."
		}
		
		* Screen breaks.
		cap set more off, perm
		
		* Maximum variables.
		cap set maxvar 5000, perm
		
		* Scroll buffer.
		cap set scrollbufsize 500000
		
		* Verbose option: add basic system information.
		if `verbose' macro dir
	}
	else if `verbose' {
		creturn li
	}
	else {
		query
	}

	* Packages
	di as inp _n "Looking at packages..."
	if "`1'" == "setup" & "`2'" != "test" {
		local variables = "lookfor_all fre revrs univar extremes"
		local graphs = "catplot ciplot spineplot tabplot"
		local exports = "log2do2 tabout"
		local regression = "estout leanout outreg outreg2 clarify"
		local i=0
		foreach t in variables graphs exports regression {
			local i=`i'+1
			di as inp "[" "`i'" "/4] Installing selected packages to handle " "`t'" "..."
			
			foreach p of local `t' {
				cap noi ssc install `p', replace
				if `verbose' ado de `p'
				}
		}
	}
	else if `verbose' {
		ado de
	}
	else {
		ado dir
	}
	
	if "`1'" == "check" {
		clear all
		
		if "`2'" == "offline" global path "Replication"
		if "`2'" == "online" global path "http://f.briatte.org/teaching/quanti/code"
		
		if "$path" != "" {
			di as inp _n "Running all do-files..."
			forvalues y=5/12 {
				do $path/week`y'.do
				graph drop _all
			}
		}
	}
	
	* Updates
	if `updates' {
		di as inp _n "Trying software updates..."

		di as inp _n "Updating packages..."
		cap noi adoupdate, update all ssconly
	
		di as inp _n "Updating Stata..."
		cap noi update query
	}
	
	* LOG
	di as inp _n "The log for this " `"`1'"' " operation is stored at:"
	qui log query SRQM
	di as res r(filename)	
	if "`1'" == "check" {
		di as err _n "Please email this log to your instructor(s) if you need"
		di as err "further assistance with your Stata installation."
	}

	* END	
	di as inp _n "Done!"
	di as inp "Have a nice day."
	
	qui log close SRQM
	// This does not work.
	if ((r(inst_exe) < r(avbl_exe)) | (r(inst_ado) < r(avbl_ado))) update all
end

* What is science?
*
* A Stata program by Rudolf Carnap, with assistance from the Vienna Circle.
* Do not send bugs to the developer, as the program has been abandoned.

cap pr drop science
program science
	di as txt _n "  Science is a system of statements"
	di as txt "  based on direct experience"
	di as txt "  and controlled by experimental verification."
	di as txt _n "  -- Rudolf Carnap" _n
end

* Permanent log.
* 
* This will create a permanent log of the current session in the Replication
* folder. Quitting Stata will automatically close it. This log is an additional
* safety that should not keep you from logging sessions to separate log files.

cap log using "Replication/perm.log", name("permalog") replace
if _rc==0 noi di as inp _n "Permanent log:" _n as res r(filename)
if _rc!=0 noi di as err _n "Permanent log returned an error."
if _rc==604 noi di as res _n "Permanent log already open. Carry on."

// All set.
