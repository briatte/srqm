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

// Check working directory.
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

// Check course folders.
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

cap pr drop srqm
program srqm
	// srqm -- setup programme for the SRQM course
	//
	//   srqm setup -- to make some permanent settings and install a few packages
	//   srqm check -- to run some routine checks on your system and packages

	// Run this script when the course starts to setup Stata. You must be online to
	// execute the script in full, and you must have properly installed Stata on your
	// computer first.  

	local variables = "extremes fre kountry lookfor_all revrs univar"
	local graphs = "catplot ciplot spineplot tab_chi tabplot" 
	local exports = "log2do2 logout mkcorr tabout"
	local regression = "estout leanout outreg outreg2"

	cap log close _all // interrupt logs

	local verbose = ("`2'" == "verbose")

	if inlist("`1'","setup","check","cleanup") {
		qui log using `1'.log, name(SRQM) replace
		di as inp "Running SRQM in " `"`1'"' " mode on Stata " c(stata_version)
	}
	else {
		di as txt _n "Setup commands:" _n
		di as inp "  srqm setup" as txt " -- setup for the SRQM course"
		di as inp "  srqm setup offline" as txt " -- skip package installs"
		di as txt _n "Debug commands:" _n
		di as inp "  srqm check" as txt " -- check and update packages" _n
		di as inp "  srqm check verbose" as txt " -- print plenty more system output"
		di as inp "  srqm check routine" as txt " -- run through all course do-files"
		// undocumented (pretty destructive):
		// srqm cleanup [packages] [workfiles] [all] -- uninstall packages and/or erase replication workfiles
		di as txt _n "You probably want to run 'srqm setup'."
		exit 198
	}

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
		
		cap net from "http://leuven.economists.nl/stata"
		cap net install schemes
		// cap set scheme bw
	}
	else if `verbose' {
		ado de
	}
	else {
		ado dir
	}
	
	if "`1'" == "check" {
	
		if "`2'" == "routine" {
			local begin_time = c(current_time)
			di as inp _n "Clean run through all do-files..."
			
			forvalues y=1/15 {
				gr drop _all
				set scheme s2color
				if `y' < 13 {
					do Replication/week`y'.do
				}
				else {
					local y2 = `y' - 12
					do Replication/draft`y2'.do
				}
			}
			
			gr drop _all
			win man close viewer _all // nifty
			clear all
			
			di as res _n "Done! Routine launched at " "`begin_time'" " and finished at " c(current_time) "."
		}
		else {
			cap noi adoupdate, update all ssconly
		}
	}

	if "`1'" == "cleanup" {
	
		if inlist("`2'","packages","all") {
			di as inp _n "Uninstalling packages..." // also sets schemes back to default
	
			foreach t in variables graphs exports regression {
				foreach p of local `t' {
					cap noi ssc uninstall `p'
					}
			}
			cap ssc uninstall clarify	
			cap ssc uninstall schemes
			set scheme s2color
		}
		
		if inlist("`2'","workfiles","all") {
			di as inp _n "Uninstalling workfiles..." // probably requires X Window System

			forvalues y=1/15 {
				if `y' < 13 {
					cap !rm Replication/week`y'.log
					if inlist(`y',5,11) cap !rm -R Replication/week`y'-files
				}
				else {
					local y2 = `y' - 12
					cap rm Replication/draft`y2'.log
					if `y2'==3 cap !rm -R Replication/BriattePetev
				}
			}
		}
	
	}
					
	di as inp _n "The log for this " `"`1'"' " operation is stored at:"
	qui log query SRQM
	di as res r(filename)	
	if "`1'" == "check" {
		di as txt _n "Please email this log to your instructor(s) if you need"
		di as txt "further assistance with your Stata installation."
	}

	di as inp _n "Done!"
	di as inp "Have a nice day."
	
	qui log close SRQM
end

cap pr drop tsst
program tsst
	// tsst -- export tabbed summary statistics tables
	// method: http://www.stata.com/meeting/uk09/uk09_jann.pdf

    syntax using/ [, SUmmarize(varlist) FRequencies(varlist) replace append verbose ] 
    tempname fh
	if "`frequencies'" == "" & "`summarize'" == "" { 
    	di as err "  ERROR: No variables provided." _n
    	local exit="yes"
    }
    else if strpos("`using'",".tsv") < 2 & strpos("`using'",".txt") < 2 {
    	di as err "ERROR: File extension should be TXT or TSV." _n
    	local exit="yes"
    }
    else {
		file open `fh' using `using', write `replace' `append'
		file write `fh' _n _n "Variable" _tab "N" _tab "Mean / %" _tab "SD" _tab "Min." _tab "Max."
		di ""
    }
	if "`exit'"=="yes" {
		di as txt "  Usage:" _n
		di "    tsst using table.txt, su(v1 v2) fr(v3) replace" _n
    	di "  su() describes continuous variables (mean, sd, min, max)"
    	di "  fr() describes categorical variables (frequencies)" _n
		di "  Example:" _n
		di "    sysuse nlsw88, clear"
		di "    su age wage"
		di "    tab1 race married"
		di "    tsst using table.txt, su(age wage) fr(race married) replace" _n
		di "  tsst saves tables to tab-separated values (.tsv or .txt)."
		di "  You should be able to open them in any spreadsheet editor." _n
		exit -1
	}

	if "`summarize'" != "" {
		foreach v of varlist `summarize' {
			qui summarize `v'
		    local l: var l `v'
	    	if "`l'"=="" {
	    		di as txt "   " "`v'" as err " (no variable label)"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "   " "`v'" " (" "`l'" ")"
	    	}
	    	file write `fh' _n "`l'" _tab (r(N)) _tab (round(r(mean),.01)) _tab (round(r(sd),.01)) _tab (round(r(min),.01)) _tab (round(r(max),.01))
			}
	}
	if "`frequencies'" != "" {
		foreach v of varlist `frequencies' {
			qui su `v'
		    local l: var l `v'
			qui cap tab `v', gen(`v'_) matcell(m)
			if _rc != 0 local d = " -- dummies existed already"
	    	if "`l'"=="" {
	    		di as txt "  " "`v'" as err " (no variable label)" "`d'"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "   " "`v'" " (" "`l'" ")" "`d'"
	    	}
			local N = r(N)
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
				file write `fh' _n " -  " "`vlbl'" _tab (r(N)) _tab (`pc')
			}
		}
	}
	file close `fh'
	di as txt _n "   summarized to " as inp "`using'" _n
	di as txt "Open the file with any spreadsheet editor to edit further."
	di as txt "Remember that every table deserves a caption. Enjoy life."
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
