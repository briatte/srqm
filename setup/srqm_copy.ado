*! srqm_copy  : grab SRQM course material from remote source
*!              requires an active Internet connection
*!
*! USAGE
*!
*! srqm_copy *.do         : download a Stata do-file to the code/ folder
*! srqm_copy *.dta        : download a Stata dataset to the data/ folder
*! srqm_copy *.ado        : download a Stata program to the setup/ folder
*! srqm_copy *.pdf        : download a PDF file to the course/ folder
*! srqm_copy *.txt        : download a plain text file to the course/ folder
*!
*! Multi-file calls are allowed: srqm_copy foo.dta bar.pdf ...
*!
*! OPTIONS
*!
*! , using  : set remote source; defaults to own remote HTTP source, which is
*!            mirrored from its GitHub repo (https://github.com/briatte/srqm)
*!
*! , backup : save a backup file (on by default)
*!
cap pr drop srqm_copy
program srqm_copy

  syntax anything [using/] [, nobackup]

	tokenize "`*'"

  if "`using'" == "" {
    loc using "http://f.briatte.org/stata"
  }

  loc pid "[COPY]"
  loc url "`using'"
  
  * ----------------------------------------------------------------------------
  * run from the SRQM folder
  * ----------------------------------------------------------------------------

  cap qui cd "$SRQM_WD"
  //noi di as txt "`pid' running from", as inp "$srqm_wd"
    	
  if _rc {
  
    di ///
      as err "`pid' ERROR:", ///
      as txt "SRQM folder is not set"

    exit -1 // bogus error code
  
  }
  
	cap qui net
	if _rc == 631 {
    
	    di ///
        as err "`pid' ERROR:", ///
        as txt "no active Internet connection"

	    exit 631

	}
	
	while "`*'" != "" {
	
		// dot separator
		local bd = strpos("`1'", ".")
		// filename
		local br = substr("`1'", 1, `bd' - 1)
		// extension
		local be = substr("`1'", `bd' + 1, .)
		// backup name
		local bk = subinstr(strtoname("`br' backup `c(current_date)'"), "__", "_", .)
		
		if "`be'" == "do"  local bf "code"
		if "`be'" == "pdf" | "`be'" == "txt" local bf "course"
		if "`be'" == "zip" | "`be'" == "dta" local bf "data"
		// careful with that axe eugene
		if "`be'" == "ado" local bf "setup"
		
		// path to backup
		local pb "`bf'/`bk'.`be'"
		// path to file
		local pf "`bf'/`1'"
		
		if "`bf'" == "" {
      
		    di ///
          as err "`pid' ERROR:"                 , ///
          as txt "invalid file extension"       , ///
          as inp "`be'"                        _n ///
          as txt "`pid' supported extensions:"  , ///
          as inp ".ado .do .dta .pdf .zip"
          
		    exit 198
        
		}
		else {
			di as txt "`pid' source:", as inp "`url'/`1'"
			di as txt "`pid' target:", as inp "`c(pwd)'/`bf'/`1'"

      // save backup version
	    cap qui copy "`pf'" "`pb'", public replace
      
      // erase current version
		  cap qui erase "`pf'" 
      
      // copy remote version
	    cap qui copy "`url'/`1'" "`pf'", public replace
		
		    if !_rc {
		    	di as txt "`pid' successfully downloaded"
		    		
		    	//if "`be'" == "pdf" di as inp _n "{stata !open `pf':open `pf'}"
		    	//if "`be'" == "do" di as inp _n "{stata doedit `pf':doedit `pf'}"
		    }
		    else {
          
		    	di ///
            as err "`pid' ERROR:" , ///
            as txt "failed to copy remote source file (code", _rc ")"
          
          // restore backup file
		    	cap qui copy "`pb'" "`pf'", public replace
          
		    	if !_rc {
            
		    		cap erase "`pb'"
		    		di as txt "(`1' restored from backup `bk'.`be')"
            
		    	}
		    	else if "`nobackup" == "" {
            
		    		di as txt "`pid' (no backup could be restored)"
            
		    	}
          
		    }
		}
		macro shift
	}

end

// bye
