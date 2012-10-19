cap pr drop srqm
program srqm
	syntax anything [, noLOG]

	// ========
	// = LOAD =
	// ========
	
	// strip option comma
	if strpos("`1'",",") != 0 local 1 = substr("`1'",1,length("`1'")-1)
	if strpos("`2'",",") != 0 local 2 = substr("`2'",1,length("`2'")-1)

	// parse syntax
	local log = ("`log'"=="")
	local setup = (strpos("`1'","setup") > 0)
	local check = (strpos("`1'","check") > 0)
	local clean = (strpos("`1'","clean") > 0)
	local folder = ("`2'"=="folder")
	local packages = ("`2'"=="packages")
	local course = ("`2'"=="course")
	
	// package list
	local install = "catplot ciplot estout fre kountry leanout log2do2 lookfor_all mkcorr revrs spineplot tab_chi tabout"

	// dataset list
	local datasets = "ebm2009 ess2008 gss2010 lobbying2010 nhis2009 qog2011 trust2012 wvs2000"

	// interrupt logs
	if `log' cap log close _all

	// check syntax
	if `setup' | `check' | `clean' {
		if `log' {
			if "`2'"!="" local x = "-`2'"
			cap qui log using Programs/`1'`x'.log, name(SRQM) replace
			if _rc==0 local logged 1

			di as txt "Running SRQM utilities..."

			di as inp _n "User profile:"
			di as txt "  Date:" as res c(current_date), c(current_time)
			di as txt "  Software: Stata " as res c(stata_version)
			di as txt "  System: " as res c(os), c(osdtl)
			di as txt "  Computer: " as res c(machine_type)
			di as txt "  Command: " as res "srqm " "`1' `2'"

			di as inp _n "Working directory: " _n as res "  " c(pwd) _n

			di as inp "Log path:"
	 		cap qui log query SRQM
	 		if _rc==0 di as res "  " r(filename) _n	
			if _rc!=0 di as txt "  `c(pwd)'" "/Programs/`1'`x'.log" _n as err "  WARNING: Log creation failed." _n
		
			di as inp "System directories:"
			adopath
		}
	}
	else {
		di as txt "Unrecognized option. You probably want to run {stata srqm setup}." _n ///
			"See the {browse Programs/README.pdf:README} file of your Programs folder for options."
		exit 0
	}

	// =========
	// = SETUP =
	// =========

	if `setup' {

		if `folder' {
			//
			// SRQM LINK
			//
			di _n as inp "Folder settings:"

			//
			// PROFILE SYMLINK
			//
			tempname fh
			di as txt "  Writing to the Stata application folder:"
			di as txt "  `c(sysdir_stata)'profile.do"
			cap file open fh using "`c(sysdir_stata)'profile.do", write replace
			if _rc == 0 {
				file write fh "// SRQM course settings:" _n
				file write fh "global srqm_wd " _char(34) "`c(pwd)'" _char(34) _n
				file write fh "cap noi run " _char(34) _char(36) "srqm_wd`c(dirsep)'profile.do" _char(34) _n
				file write fh "if _rc!=0 di as err _n ///" _n
				file write fh _char(34) "  The SRQM folder is no more available at its former location:" _char(34) " _n ///" _n
				file write fh _tab _char(34) "  `c(pwd)'" _char(34) " _n _n ///" _n
				file write fh _tab _char(34) "  You need to manually set the working directory to the SRQM folder" _char(34) "_n ///" _n
				file write fh _tab _char(34) "  and then use the {stata run profile} command to update the link." _char(34) " _n _n ///" _n
				file write fh _tab _char(34) "  This usually happens when you move or rename some of your folders." _char(34) "_n ///" _n
				file write fh _tab _char(34) "  The README file of your SRQM folder contains further instructions." _char(34) _n
				file close fh
				di as txt _n "  Setting the redirect link to the current working directory:" _n "  " c(pwd)
				di as inp ///
					_n "  WARNING: Note this folder path and do not move or rename its parts." ///
					_n "  If you modify the elements of this path during the course, you will" ///
				 	_n "  have to manually set the working directory to the SRQM folder, and" /// 
				 	_n "  then use the {stata run profile} command to update the link."
			}
			else {
				//
				// Windows Vista and 7 machines require the user to right-click
				// the application and run it as admin for this bit to work.
				//
				di as err ///
					_n "  Warning: The Stata application folder is not writable on your system." ///
					_n "  Try running Stata with admin privileges. If the problem persists, you" ///
					_n "  will have to manually set the working directory to the SRQM folder at" /// 
					_n "  the beginning of every course session."
				exit 0
			}
		}	
		else if `packages' {
			//
			// INSTALL PACKAGES
			//
			di _n as inp "Installing packages:"

			local i=0
			foreach t of local install {
				local i=`i'+1
				cap which `t'
				if _rc==111 | "`3'" == "forced" {
					cap qui ssc install `t', replace
					if _rc!=0 {
						if _rc==699 {
							// issue: admin privileges required to modify stata.trk
							// workaround: install to personal folder (create if necessary)
							// on Sciences Po computers, path will be c:\ado\personal\
							// iterative (do that for every package that does not work)
							// so probably slow and desperate
							local here = c(pwd)
							cd "`c(sysdir_plus)'"
							cap cd ..
							cap mkdir personal
							cap cd personal
							sysdir set PERSONAL "`c(pwd)'"
							cd "`here'"
							// shoot again
							cap qui ssc install `t', replace
							if _rc!=0 local msg = "(installation failed)"
						}
						else if _rc==631 { // Internet error
							di as err "You do not seem to be online."
							exit -1
						}
					}
				}
				else {
					local msg = "(already installed)"
				}
				di as txt "  [" "`i'" "/" wordcount("`install'") "]: " as inp "`t'" as err " `msg'"
			}
	
			di as txt "  Installing a couple more things..."
			
			cap net from "http://gking.harvard.edu/clarify"
			cap qui net install clarify
			
			cap net from "http://leuven.economists.nl/stata"
			cap qui net install schemes
		}
		else {
			//
			// SYSTEM OPTIONS
			//
			di _n as inp "System options:"

			* Memory.
			if c(version) < 12 {
				cap set mem 500m, perm
				if _rc==0 di as txt "  Memory set to (500MB)."
			}
			
			* Screen breaks.
			cap set more off, perm
			if _rc==0 di as txt "  Screen breaks set to (off)."
			
			* Maximum variables.
			clear all
			cap set maxvar 5000, perm
			if _rc==0 di as txt "  Maximum variables set to (5000)."
			
			* Scrollback buffer size.
			cap set scrollbufsize 500000
			if _rc==0 di as txt "  Scrollback buffer size set to (500000)."
	
			* Software updates.
			cap set update_query off
	        if _rc==0 di as txt "  Software updates set to (off)."
			
			if _rc!=0 di as err "  WARNING: Some settings failed to apply."
		}
				
	}

	// =========
	// = CHECK =
	// =========

	if `check' {

		if `folder' {
			// 
			// FOLDER INTEGRITY
			//
			di as inp _n "Working directory:" as txt _n "{browse `c(pwd)'}"
			ls, w

			foreach f in  "Datasets" "Replication" {
				cap cd "`f'"
				if _rc != 0 {
					di as err _n "There is no " "`f'" " folder in your current working directory."
					exit -1
				}
				di as txt _n "{browse `f'}" " folder:" _n c(pwd)
				if "`f'" == "Datasets" {
					cap noi ls *.dta, w
					// exhaustive check if no dta (assuming not yet unzipped)
					foreach d in `datasets' {
						cap confirm file `d'.dta
						if _rc==601 {
							di as txt "Unzipping " as inp "`d'.dta"
							cap unzipfile "`d'", replace
						}
						if _rc==601 {
							di as err _n "  WARNING: The `d'.zip file is missing."
							qui cd ..
							exit -1
						}
					}
				}
				if "`f'" == "Replication" cap noi ls *.do, w	
				qui cd ..
			}
		}
		else if `packages' {
			//
			// PACKAGE UPDATES
			//
			di _n as inp "Package updates:"
			
			cap qui ssc hot
			if _rc==0 cap noi adoupdate, update all
			if _rc!=0 di as err "  WARNING: Could not connect to SSC archive."
		}
		else if `course' {
			//
			// FULL MONTY
			//
			di as inp _n "Course demo:"
			
			local start = c(current_time)

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
			di as txt _n "  Done! Routine launched at " "`start'" " and finished at " c(current_time) "."

		}
		else {
			//
			// PLAIN CHECK
			//
			query
			ado dir
		}
		
	}

	// =========
	// = CLEAN =
	// =========

	if `clean' {

		if `folder' {
			//
			// UNLINK COURSE
			//
			di as inp _n "Remove SRQM link:"

			cap rm "`c(sysdir_stata)'profile.do"
			if _rc ==0 di as txt _n "  Successfully `c(sysdir_stata)'profile.do removed." _n "  Farewell!"
			if _rc !=0 di as err _n "  Nothing to remove at `c(sysdir_stata)'profile.do."
		}
		else if `packages' {
			//
			// PACKAGE ANNIHILATION
			//
			di as inp _n "Uninstalling packages..."
	
			foreach t of local install {
				cap noi ssc uninstall `t'
			}
			
			di as txt _n "  Uninstalling a few more things..."
			cap ssc uninstall clarify	
			cap ssc uninstall schemes
			set scheme s2color // set scheme back to default
		}
		else {
			//
			// CLEANUP WORKFILES
			//
			di as inp _n "Cleaning work files..." // requires X Window System

			local expr = "Programs/*.log"
			cap !rm `expr'

			local expr = "Replication/*[^backup].log"
			cap !rm `expr'

			local expr = "Replication/*-files"
			cap !rm -R `expr'

			local expr = "Replication/BriattePetev"
			cap !rm -R `expr'
		}

	}

	// ========
	// = EXIT =
	// ========

	if `log' {
		di _n as inp "Done!" as txt _n "  Have a nice day."
		qui cap log close SRQM
	}

end
