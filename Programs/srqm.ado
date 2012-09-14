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
		qui log using Programs/srqm-`1'.log, name(SRQM) replace
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

	di as inp _n "Going over system settings..."

	if "`1'" == "setup" {

		* Memory.
		if c(version) < 12 {
			cap set mem 500m, perm
			if _rc==0 di as txt "- Memory.............. set to (500MB)"
			if _rc!=0 di as err "Failed to set memory to 500M." _n ///
			"Things might work, or not, depending on the size of your data. Sorry."
		}
		
		* Screen breaks.
		cap set more off, perm
		if _rc==0 di as txt "- Screen breaks....... set to (off)"
		
		* Maximum variables.
		cap set maxvar 5000, perm
		if _rc==0 di as txt "- Maximum variables... set to (5000)"
		
		* Scroll buffer.
		cap set scrollbufsize 500000
		if _rc==0 di as txt "- Screen breaks....... set to (500000)"
	}
	else if `verbose' {
		creturn li
	}
	else {
		query
	}

	di as inp _n "Going over packages..."
	if "`1'" == "setup" & "`2'" != "offline" {
		local i=0
		foreach t of local packages {
			local i=`i'+1
			di as txt "- Installing package " "`i'" "/" wordcount("`packages'") " (" "`t'" ") ..."
			cap qui ssc install `t', replace
		}

		di as txt "- Installing a couple more things..."
		
		cap net from "http://gking.harvard.edu/clarify"
		cap qui net install clarify
		
		cap net from "http://leuven.economists.nl/stata"
		cap qui net install schemes

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
				cap noi ssc uninstall `t'
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
