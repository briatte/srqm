
/* --- SRQM setup utilities ----------------------------------------------------

*! This file creates the utilities called at startup by the profile.do file of
*! the SRQM folder. See the README file of the setup folder for details on how
*! to operate it. If you are a student, just follow the instructions in class.

   Last revised 2013-03-10.

*! version 3.6: setup bugfix
*! version 3.5: added spmap
*! version 3.4: data command
*! version 3.3: demo updated
*! version 3.2: fetch updated
*! version 3.1: fetch command
*! version 3.0: major rewrite

----------------------------------------------------------------------------- */

cap pr drop srqm
program srqm
    syntax anything [, LOGged forced demo(numlist > 0 < 13 ascending integer)]

    // parse syntax
        
    tokenize `anything'
    local setup    = ("`1'"=="setup")
    local check    = ("`1'"=="check")
    local fetch    = ("`1'"=="fetch")
    local clean    = ("`1'"=="clean")
    local folder   = ("`2'"=="folder")
    local packages = ("`2'"=="packages")
	local data     = ("`2'"=="data")  // new: data preparation utility
    local logged   = ("`logged'"!="")
    local forced   = ("`forced'"!="")

    // package list

    local cmdlist = "lookfor_all fre spineplot tab_chi mkcorr tabout estout leanout plotbeta kountry qog wbopendata spmap scheme-burd schemes _gstd01 clarify"

        * catplot ciplot distplot log2do2 outreg2 revrs
        * tufte lean2

    // dataset list

    local datalist = "ess2008 gss2010 nhis2009 qog2011 wvs2000"

    // interrupt backup log if any

    if `logged' cap log off backlog

    // check syntax

    if `setup' | `check' | `clean' | `fetch' {
        if `logged' {
            if "`2'"!="" local x = "-`2'"
            cap qui log using setup/`1'`x'.log, name(SRQM) replace
            if !_rc local logged 1

            di as txt "Running SRQM utilities..."

            di as inp _n "User profile:"
            di as txt "Date:", as res c(current_date), c(current_time)
            di as txt "Software: Stata", as res c(stata_version)
            di as txt "System:", as res c(os), c(osdtl)
            di as txt "Computer:", as res c(machine_type)
            di as txt "Command:", as res "srqm `1' `2'"

            di as txt "Working directory:", as res c(pwd)

             cap qui log query SRQM
             if !_rc di as inp "Log path:", as res r(filename) _n
            if _rc di as err "Log creation failed." _n

            di as inp "System directories:"
            adopath
        }
    }
    else {
        di as txt "Unrecognized subcommand. See the {browse setup/README.pdf:README} file for syntax help."
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
            // PROFILE LINK
            //
            tempname fh
            di as txt "Writing SRQM link to the Stata application folder:" _n as res "`c(sysdir_stata)'profile.do"
            cap file open fh using "`c(sysdir_stata)'profile.do", write replace
            if _rc == 0 {
                file write fh _n "*! This do-file automatically sets the working directory to the SRQM folder:" _n
                file write fh "*! `c(pwd)'" _n _n
                file write fh "global srqm_wd " _char(34) "`c(pwd)'" _char(34) _n
                file write fh "cap confirm file " _char(34) _char(36) "srqm_wd`c(dirsep)'setup`c(dirsep)'srqm.ado" _char(34) _n _n
                file write fh "if _rc { // cannot load utilities" _n _tab "noi di as err _n ///" _n
                file write fh _tab _tab _char(34) "ERROR: The SRQM folder is no longer available at its former location:" _char(34) " as txt _n ///" _n
                file write fh _tab _tab _char(34) _char(36) "srqm_wd" _char(34) " _n(2) ///" _n
                file write fh _tab _tab _char(34) "This error occurs when you rename or relocate the SRQM folder." _char(34) " _n ///" _n
                file write fh _tab _tab _char(34) "Use the 'File : Change Working Directory...' menu to manually" _char(34) " _n ///" _n
                file write fh _tab _tab _char(34) "select the SRQM folder, then execute the {stata run profile} command." _char(34) " _n ///" _n
                file write fh _tab _tab _char(34) "For more help, see the README file of the SRQM folder." _char(34) _n
                file write fh _tab "exit -1" _n "}" _n "else {" _n
                file write fh _tab "cap cd " _char(34) _char(36) "srqm_wd" _char(34) _n _n
                file write fh _tab "cap noi run profile" _n
                file write fh _tab "if !_rc noi type profile.do, starbang" _n _n
                file write fh _tab "if _rc | " _char(34) _char(36) "srqm_wd" _char(34) "==" _char(34) _char(34) " { // folder check failed" _n
                file write fh _tab _tab "noi di as txt ///" _n
                file write fh _tab _tab _tab _char(34) "Some essential course material is not available in your working directory." _char(34) " _n(2) ///" _n
                file write fh _tab _tab _tab _char(34) "This error occurs when you modify the folders or files of the SRQM folder." _char(34) " _n ///" _n
                file write fh _tab _tab _tab _char(34) "Restore the SRQM folder from a backup copy or from http://f.briatte.org/srqm" _char(34) " _n ///" _n
                file write fh _tab _tab _tab _char(34) "Then set it as the working directory and execute the {stata run profile} command." _char(34) " _n ///" _n
                file write fh _tab _tab _tab _char(34) "For further help, see the README file of the SRQM folder." _char(34) _n
                file write fh _tab _tab "exit -1" _n
                file write fh _tab "}" _n
                file write fh "}" _n
                file close fh
                di as txt _n "Setting the redirect link to the current working directory:" _n as res c(pwd)
                di as inp ///
                    _n "IMPORTANT: do not modify this folder path!", as txt "If you move or rename its elements," ///
                    _n "Stata will not find the course material when you open it, and you will have to" ///
                    _n "setup your computer again (see the README file of the SRQM folder for help)."
            }
            else {
                //
                // Windows Vista and 7 machines require the user to right-click
                // the application and run it as admin for this bit to work.
                //
                di as err ///
                    _n "ERROR: The Stata application folder is not writable on your system." as txt _n(2) ///
                    _n "Try again while running Stata with admin privileges. If the problem persists," ///
                    _n "you will have to manually select the SRQM folder from the 'File : Change" ///
                    _n "Working Directory...' menu and then execute the {stata run profile} command."
                    _n "at the beginning of every course session. All apologies to Windows users."
                exit 0
            }
        }
        else if `packages' {
            //
            // INSTALL PACKAGES
            //
            local i=0
            foreach t of local cmdlist {
                local i=`i'+1

                cap which `t'

                // tab_chi and tabchi
                if "`t'"=="tab_chi" cap which tabchi

                // qog and qoguse
                if "`t'"=="qog" cap which qoguse
                
                // scheme-burd
                if "`t'"=="scheme-burd" cap which scheme-burd.scheme

                if _rc==111 | `forced' {

                    // note: keep special cases at end of local list for the 699 hack to work with them

                    if "`t'"=="spmap" {
						local maps "world-c.dta world-d.dta"
						foreach y of local maps {
							cap ssc cp `y'
							cap copy `y' data/`y'
							cap rm `y'
						}
                    }
                    else if "`t'"=="clarify" {
                        cap which simqi
                        if (_rc==111 | `forced') cap noi net install clarify, from("http://gking.harvard.edu/clarify")
                    }
                    else if "`t'"=="_gstd01" {
                        cap which _gstd01
                        if (_rc==111 | `forced') cap noi net install _gstd01, from("http://web.missouri.edu/~kolenikovs/stata")
                    }
                    else if "`t'"=="schemes" {
                        cap which scheme-bw.scheme
                        if (_rc==111 | `forced') cap noi net install schemes, from("http://leuven.economists.nl/stata/")
                    }
                    else {
                        cap noi ssc install `t', replace
						if _rc==631 di as err "Could not connect to the SSC archive to look for package " as inp "`1'"
						if _rc==601 di as err "Could not find package " as inp "`1'" as err " at the SSC archive"
                    }
                    if _rc==699 {

                        /* issue: admin privileges required to modify stata.trk
                           workaround: install to personal folder (create if necessary)
                           
                           on Sciences Po computers, path will be c:\ado\personal

                           blindly iterative so probably slow and desperate
                           but actually works and gets everything installed */

                        local here = c(pwd)
                        qui cd "`c(sysdir_plus)'"
                        qui cd ..
                        cap mkdir personal
                        if !_rc noi di as txt "Could not install to the PLUS folder:" ///
                            _n "`c(sysdir_plus)'" _n ///
                            "Installing to the PERSONAL folder instead:" _n ///
                            "`c(pwd)'/personal"
                        cap cd personal
                        cap sysdir set PLUS "`c(pwd)'" // shouldn't ever fail
                        qui cd "`here'"

                        // shoot again at SSC server; should now install fine

                        cap qui ssc install `t', replace
                    }
                }
                else {
                 if `logged' di "SETUP:", as inp "`t'", as txt "is already installed"
                }
                if _rc di as err "ERROR: installation of `t' failed with error code", _rc
            }
        }
		// ... might not work for Windows users running without admin privileges
		else if `data' {
			//
			// DATA PREPARATION
			//
	        if strpos("all `datalist'", "`2'") {
		        cap cd "$srqm_wd"
				noi do setup/srqm_data.ado "`2'"
			}
	        else {
	            di as err "Use one of the subcommand options: all `datalist'"
	            exit 198
		    }
	    }
        else {
            //
            // SYSTEM OPTIONS
            //
            di _n as inp "System options:"

            * Memory.
            if c(version) < 12 {
                cap set mem 500m, perm
                if !_rc di as txt "Memory set to 500MB (running older Stata)."
            }

            * Screen breaks.
            cap set more off, perm
            if !_rc di as txt "Screen breaks set to", c(more)

            * Maximum variables.
            clear all
            cap set maxvar 7500, perm
            if !_rc di as txt "Maximum variables set to", c(maxvar)

            * Scrollback buffer size.
            cap set scrollbufsize 500000
            if !_rc di as txt "Scrollback buffer size set to", c(scrollbufsize)

            * Software updates.
            cap set update_query off
            if !_rc di as txt "Software updates set to", c(update_query)

            * Variable abbreviations.
            set varabbrev off, perm
            if !_rc di as txt "Variable abbreviations set to", c(varabbrev)

            * Course themes.
            cap set scheme burd, perm
            if !_rc di as txt "Graphics scheme set to", c(scheme)
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

            foreach f in  "data" "code" {
                cap cd "`f'"
                if _rc {
                    di as err _n "ERROR: missing `f' folder"
                    exit -1
                }
                di as txt _n "{browse `f'}" " folder:" _n c(pwd)
                if "`f'" == "data" {
                    // exhaustive check
                    foreach d in `datalist' {
                        cap confirm file `d'.dta
                        if _rc {
                            di as txt "SETUP: unzipping " as inp "`d'.dta", as txt "..."
                            cap unzipfile "`d'", replace
                        }
                        if _rc==601 {
                            di as err _n "ERROR: neither `d'.dta or `d'.zip", ///
                                "could be located" _n "in the `f' folder"
                            qui cd ..
                            exit -1
                        }
                    }
                    cap noi ls *.dta, w
                }
                if "`f'" == "code" cap noi ls *.do, w
                qui cd ..
            }
        }
        else if `packages' {
            //
            // PACKAGE UPDATES
            //
            di _n as inp "Package updates:"

            cap qui ssc hot
            if !_rc cap noi adoupdate, update all
            if _rc di as err "Could not go online to check for updates."
        }
        else if "`demo'" != "" {
            //
            // CHECK COURSE
            //
            di as inp _n "Course demo:"

            gr drop _all
            win man close viewer _all
            clear all

            local start = c(current_time)

            foreach y of numlist `demo' {

                gr drop _all
                win man close viewer _all
                clear all

                // to test the package installation loops
                // and/or get plots in s2color default scheme,
				// uncomment these:
                // srqm clean packages
                // set scheme s2color

                do code/week`y'.do
                // repl week`y'

            gr drop _all
            win man close viewer _all
            clear all

            di as txt _n "Done! Routine launched at `start' and finished at", c(current_time) "."
            }
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
            if _rc ==0 di as txt _n "Successfully removed", "`c(sysdir_stata)'profile.do." _n "Farewell, enjoy life and Stata!"
            if _rc !=0 di as err _n "Nothing to remove at", "`c(sysdir_stata)'profile.do." _n "You have already left. Be well!"
            cd "`c(sysdir_stata)'" // to avoid profile.do re-setting up on Macs
        }
        else if `packages' {
            //
            // PACKAGE ANNIHILATION
            //
            di as inp _n "Uninstalling packages..."

            foreach t of local install {
                cap noi ssc uninstall `t'
            }

            di as txt _n "Uninstalling a few more things..."
            cap ssc uninstall clarify
            cap ssc uninstall _gstd01

            set scheme s2color // set scheme back to default
        }
        else {
            //
            // CLEANUP WORKFILES
            //
            di as inp _n "Cleaning work files..." // requires X Window System

            local expr = "week*.log" // pretty destructive
            cap !rm `expr'

            local expr = "setup/*.log"
            cap !rm `expr'

            local expr = "code/*.log"
            cap !rm `expr'

			// really destructive
			cap !rm week*.txt

            forval i=1/12 {
                // erase folders created by repl
                local expr = "code/week`i'"
                cap !rm -R `expr'
            }
        }
    }

    // =========
    // = FETCH =
    // =========

	// ... might not work for Windows users running without admin privileges
	
    if `fetch' {

        cap cd "$srqm_wd"
		
        //cap qui net
        if _rc == 631 {
            di as err "You do not seem to be online." _n ///
            	"Please fix your Internet connection to fetch course material."
            exit 631
        }

		// dot separator
		local bd = strpos("`2'", ".")
		// root
		local br = substr("`2'", 1, `bd' - 1)
		// extension
		local be = substr("`2'", `bd' + 1, .)
		// backup name
        local bk = subinstr(strtoname("`br' backup `c(current_date)'"), "__", "_", .)
		
        if "`be'" == "do"  local bf "code"
        if "`be'" == "pdf" local bf "course"
		// careful with that axe eugene
        if "`be'" == "ado" local bf "setup"

        // path to backup
        local pb "`bf'/`bk'.`be'"
        // path to file
        local pf "`bf'/`2'"
        
        if "`bf'" == "" {
            di as err "Please check the syntax of your filename."
            exit 198
        }
        else {
        	di as txt _n "Downloading `2' to the `bf' folder..."
	        cap qui copy "`pf'" "`pb'", public replace

	        cap qui erase "`pf'" // instead of rm for Windows compatibility
	        cap qui copy "http://briatte.org/srqm-updates/`2'" "`pf'", public replace

	        if !_rc {
	        	di as txt "Successfully downloaded."
	        		
	        	if "`be'" == "pdf" di as inp _n "{stata !open `pf':open `pf'}"
	        	if "`be'" == "do" di as inp _n "{stata doedit `pf':doedit `pf'}"
	        }
	        else {
	        	di as err "No file updated: error", _rc "." _n ///
	        		"Check your syntax and connection."
	        	cap qui copy "`pb'" "`pf'", public replace
	        	if !_rc {
	        		cap rm "`pb'"
	        		di as txt "- `bk'.`be' restored to `2'.`be'"
	        	}
	        	else {
	        		di as err "No backup restored: error", _rc "." 
	        	}
	        }
		}

    }

    if `logged' {
        di _n as inp "Done.", as txt "Have a nice day."
        cap log close SRQM
        cap log on backlog
    }

end
