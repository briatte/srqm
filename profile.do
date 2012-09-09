* What: SRQM profile
* Who:  F. Briatte
* When: 2012-09-09

// Use this do-file to set up Stata for the duration of the course: set your
// working directory to the SRQM folder, then type 'do profile' to configure
// your computer for the rest of the course. More advanced setup options are
// covered in the README file of the SRQM folder.

cap copy profile.do "`c(sysdir_stata)'"
if _rc == 0 {
	di as err "Setting up your computer for the SRQM course…"
	if !regexm(c(pwd),"Users") & !regexm(c(pwd),"c:") {
		di as err "Note: you are running in temporary mode, probably from a USB key."
		di as err "Packages will be installed at `c(pwd)'/Packages."
		cap mkdir "`c(pwd)'/Packages"
		sysdir set PLUS "`c(pwd)'/Packages"
	}
	tempname fh
	file open fh using "`c(sysdir_stata)'profile.do", write replace
	file write fh "// SRQM setup" _n
	file write fh "cd " _char(34) "`c(pwd)'" _char(34) _n
	file write fh "noi run profile.do" _n
	file close fh
	local run 1
}
else { 
	local run 0
		
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

	local packages = "estout leanout outreg outreg2 log2do2 logout mkcorr tabout catplot ciplot spineplot tabplot extremes fre kountry lookfor_all revrs tab_chi univar"
	
	cap log close _all // interrupt logs

	local verbose = ("`2'" == "verbose")

	if inlist("`1'","setup","check","cleanup","leave") {
		qui log using `1'.log, name(SRQM) replace
		di as inp "Running SRQM in " `"`1'"' " mode on Stata " c(stata_version)
	}
	else {
		di as txt _n "Setup commands:" _n
		di as inp "  srqm setup" as txt " -- setup for the SRQM course"
		di as inp "  srqm setup offline" as txt " -- skip package installs"
		di as inp "  srqm leave" as txt " -- leave the SRQM course"
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
		foreach t of local packages {
			local i=`i'+1
			di as inp "[Installing package " "`i'" "/" wordcount("`packages'") "…]"
			cap noi ssc install `t', replace
		}

		di as inp "Installing a few more things..."
		
		cap net from "http://gking.harvard.edu/clarify"
		cap net install clarify
		
		cap net from "http://leuven.economists.nl/stata"
		cap net install schemes

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
			di as inp _n "Uninstalling packages..."
	
			foreach t of local packages {
				cap noi ssc uninstall `p'
			}
			
			di as inp _n "Also uninstalling clarify and some schemes..."
			cap ssc uninstall clarify	
			cap ssc uninstall schemes
			set scheme s2color // also sets schemes back to default
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
	
	if "`1'" == "leave" {
		cap rm "`c(sysdir_stata)'profile.do"
		if _rc ==0 di _n "`c(sysdir_stata)'profile.do removed. Farewell!"
		if _rc !=0 di as err _n "Nothing to remove at `c(sysdir_stata)'profile.do."
	}

	di as inp _n "Done! The log for this " `"`1'"' " operation is stored at:"
	qui log query SRQM
	noi di as res r(filename)	
	if "`1'" == "check" {
		di as txt _n "Please email this log to your instructor(s) if you need"
		di as txt "further assistance with your Stata installation."
	}		
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

// Permanent log.
cap log using "Replication/perma.log", name("permalog") replace
if _rc==0 {
	noi di as inp _n "Permanent log:" _n as res r(filename)
}
else if _rc==604 {
	noi di as err _n "The permanent log is apparent already open."
}
else {
	noi di as err _n "Permanent log returned an error."
}

// Finish line.
if `run'==1 noi srqm setup
noi di as inp _n "Welcome! You are running Stata with the SRQM profile."

// All set.
