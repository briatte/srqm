* What: SRQM profile
* Who:  F. Briatte and I. Petev
* When: 2012-08-13

// Use this do-file to set up Stata for the duration of the course.
// Stata reads silently through this file at startup, so as long as
// you set the command below properly, the replication material for
// this course should run without producing any errors.

// Edit this command to reflect your local path to the SRQM folder:
cap cd "~/Documents/Teaching/SRQM"

// The rest of the file will show some information when Stata starts and will
// create the srqm program, a setup utility for the course that will install a
// few additional packages to Stata. Some of these packages are used in course
// do-files. Type in 'srqm' to get the program commands and options.

* SRQM folder checks.
if _rc != 0 {
	di as err "Failed setting the working directory."
	
	// Trying out the most common USB port in the Sciences Po microlabs.
	cap cd "e:\SRQM"
	if _rc == 0 {
		di as inp "Loading from a USB key..."
		sysdir set PLUS "c:\temp"
	}
	else {
		di as err _n "Stata cannot find the working directory, which breaks paths in SRQM do-files."
		di as err "Please edit the profile.do file in the SRQM folder, as explained in the README."
		exit -1
	}
}

noi di as inp _n "Working directory:"
noi pwd
noi ls, w

foreach f in  "Datasets" "Replication" {
	cap cd "`f'"
	if _rc != 0 {
		di as err _n "Stata cannot find the " "`f'" " folder, which breaks paths in SRQM do-files."
		di as err "Please adjust the folder names or reinstall the original SRQM Teaching Pack."
		exit -1
	}
	noi di as inp _n "`f'" " folder:"
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

	local variables = "lookfor_all fre revrs univar extremes" // req: fre
	local graphs = "catplot ciplot spineplot tabplot" // req: catplot, spineplot
	local exports = "log2do2 mkcorr tabout" // req: mkcorr, tabout
	local regression = "estout leanout outreg outreg2" // req: estout

	* Cleanup.
	cap log close _all

	local verbose = ("`2'" == "verbose")

	if "`1'" == "setup" | "`1'" == "check" {
		* Log.
		qui log using `1'.log, name(SRQM) replace

		di as inp "Running SRQM in " `"`1'"' " mode on Stata " c(stata_version)
	}
	else {
		* Error.
		di as txt _n "Setup commands:" _n
		di as inp "  srqm setup" as txt " -- setup for the SRQM course"
		di as inp "  srqm setup offline" as txt " -- skip package installs"
		di as txt _n "Debug commands:" _n
		di as inp "  srqm check" as txt " -- check and update packages" _n
		di as inp "  srqm check verbose" as txt " -- plenty more output"
		di as inp "  srqm check routine" as txt " -- run through all do-files"
		di as inp "  srqm check cleanup" as txt " -- remove course packages"
		di as txt _n "You probably want to run 'srqm setup'."
		exit 198
	}

	* SETUP: SYSTEM
	
	di as inp _n "Looking at system settings..."
	if "`1'" == "setup" {
		* Memory.
		if c(version) < 12 {
			cap set mem 500m, perm
			if _rc==0 di as txt "Memory set to 500MB (should be enough)."
			if _rc!=0 di as err "Failed to set memory to 500M." ///
			"Things might work, or not, depending on the size of your data. Sorry."
		}
		
		* Screen breaks.
		cap set more off, perm
		if _rc==0 di as txt "Screen breaks set off (cool)."
		
		* Maximum variables.
		cap set maxvar 5000, perm
		if _rc==0 di as txt "Maximum variables set to 5000 (yay)."
		
		* Scroll buffer.
		cap set scrollbufsize 500000
		if _rc==0 di as txt "Screen breaks set to 500000 (wow)."
	}
	else if `verbose' {
		creturn li
	}
	else {
		query
	}

	* SETUP: PACKAGES
	
	di as inp _n "Looking at packages..."
	if "`1'" == "setup" & "`2'" != "offline" {
		local i=0
		foreach t in variables graphs exports regression {
			local i=`i'+1
			di as inp "[" "`i'" "/4] Installing selected packages to handle " "`t'" "..."
			
			foreach p of local `t' {
				cap noi ssc install `p', replace
				}
		}
		cap net from "http://gking.harvard.edu/clarify"
		cap net install clarify
	}
	else if `verbose' {
		ado de
	}
	else {
		ado dir
	}
	
	* CHECK
	if "`1'" == "check" {
	
		if "`2'" == "routine" {
			di as inp _n "Clean run through all do-files..."
			forvalues y=1/12 {
				do Replication/week`y'.do
				gr drop _all
				rm Replication/week`y'.log
			}
	
			rm week5_fig1.pdf
			rm week5_fig2.pdf
			rm week5_stats.txt
			rm week5_stats1.csv
			rm week5_stats2.csv
			rm Replication/week8.log // week8.do runs again at start of week9.do
			rm week11_stats.txt
			rm week11_stats1.csv
			rm week11_stats2.csv
			rm week11_corr.csv
			rm week11_reg.csv
			
			rm Replication/perma.log
			
			di as res "Done."
		}
		else if "`2'" == "cleanup" {
			di as inp _n "Uninstalling packages..."
	
			foreach t in variables graphs exports regression {
				di as inp "Uninstalling selected packages to handle " "`t'" "..."				
				foreach p of local `t' {
					cap noi ssc uninstall `p'
					}
			}
			cap ssc uninstall clarify		
		}
		else {
			cap noi adoupdate, update all ssconly
		}
	}
					
	* LOG
	di as inp _n "The log for this " `"`1'"' " operation is stored at:"
	qui log query SRQM
	di as res r(filename)	
	if "`1'" == "check" {
		di as txt _n "Please email this log to your instructor(s) if you need"
		di as txt "further assistance with your Stata installation."
	}

	* END	
	di as inp _n "Done!"
	di as inp "Have a nice day."
	
	qui log close SRQM
end

* TSST

* tsst produces tabbed summary statistics tables.
* 
* This command produces summary statistics as tab-separated values.
* Your spreadsheet editor should read its output without any issue.
*
* Syntax:
*
*    tsst using file.tsv, summarize(v1 v2) frequencies(v3 v4) replace"
*
* You can abbreviate the variable groups to su() and fr().
*
* Example:
*
*    tsst using myfile.txt, su(height weight age) fr(sex uninsured) replace
*
* -- inspired by http://repec.org/usug2009/jann.tutorial.pdf

cap pr drop tsst
program tsst
    syntax using/ [, SUmmarize(varlist) FRequencies(varlist) replace append verbose ] 
    tempname fh
	if "`frequencies'" == "" & "`summarize'" == "" { 
    	di as err "ERROR: " as txt "No variables."
    	local exit="yes"
    }
    else if strpos("`using'",".tsv") < 2 & strpos("`using'",".txt") < 2 {
    	di as err "ERROR: " as txt "File extension should be TXT or TSV."
    	local exit="yes"
    }
    else {
    	di as txt "Building the table " "`using'" _n "..."
    }
	if "`exit'"=="yes" {
		di as txt "The tsst command uses the following syntax:" _n
		di "    tsst using myfile.txt, sum(v1 v2) fre(v3) replace" _n
    	di "Use the sum() option to summarize continuous variables."
    	di "Use the fre() option to list frequencies of categorical variables." _n
		di "Your file will use tab-separated values."
		di "You'll be able to open this file in pretty much any spreadsheet editor." _n
		di "Please retry your command with these parameters."
		exit -1
	}
	file open `fh' using `using', write `replace' `append'
	file write `fh' _n _n "Variable" _tab "N" _tab "Mean / %" _tab "SD" _tab "Min." _tab "Max."

	if "`summarize'" != "" {
		//di as inp "Summarizing..."
		foreach v of varlist `summarize' {
			qui summarize `v'
		    local l: var l `v'
	    	if "`l'"=="" {
	    		di as txt "+ " "`v'" as err " (empty variable label)"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "+ " "`v'" " (" "`l'" ")"
	    	}
	    	file write `fh' _n "`l'" _tab (r(N)) _tab (round(r(mean),.01)) _tab (round(r(sd),.01)) _tab (round(r(min),.01)) _tab (round(r(max),.01))
			}
	}
	if "`frequencies'" != "" {
		//di as inp "Frequencies..."
		foreach v of varlist `frequencies' {
			qui su `v'
		    local l: var l `v'
	    	if "`l'"=="" {
	    		di as txt "+ " "`v'" as err " (empty variable label)"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "+ " "`v'" " (" "`l'" ")"
	    	}
			local N = r(N)
			qui cap tab `v', gen(`v'_) matcell(m)
			if _rc != 0 di as err "! (dummies existed already)"
			qui levelsof `v', local(lvls)
			local i = 0
			foreach val of local lvls {
				local i=`i'+1
				local pc = 100*round(m[`i',1]/`N',.001)
				qui su `v' if `v'==`val'
				local lbl: var l `v'_`i'
				local pos = strpos("`lbl'","==")
				local vlbl = substr("`lbl'",`pos'+2,.)
				if `i'==1 file write `fh' _n "`l'" ":"
				file write `fh' _n " -  " "`vlbl'" _tab (r(N)) _tab (`pc') "%"
			}
		}
	}
	file close `fh'
	di as txt "..." _n "Done. Open the file " as inp "`using'" as txt " with a spreadsheet editor."
	di "Remember that every table deserves a caption! Enjoy life."
	if "`verbose'" != "" type `using'
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

cap log using "Replication/perma.log", name("permalog") replace
if _rc==0 noi di as inp _n "Permanent log:" _n as res r(filename)
if _rc!=0 noi di as err _n "Permanent log returned an error."
if _rc==604 noi di as res _n "Permanent log already open. Carry on."

noi di as inp _n "Welcome. You are running Stata with the SRQM profile."

* Last check.
if c(scrollbufsize) != 500000 | c(maxvar) != 5000 | c(more) != "off" ///
	noi di as err "It seems you have not yet run the SRQM setup program." _n ///
	"Please run it by typing 'srqm setup' while connected to the Internet."
	
// All set.
