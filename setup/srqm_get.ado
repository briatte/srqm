*! srqm_get: download SRQM course material (do-files, programs, slides)
*! type -srqm_get demo.do- for a demo
cap pr drop srqm_get
program srqm_get
	tokenize "`*'"
	
	cap cd "$srqm_wd"
  if _rc {
    di as err "Error: cannot find SRQM folder"
    exit -1
  }
	
	cap qui net
	if _rc == 631 {
	    di as err "Error: no Internet connection"
	    exit 631
	}
	
	while "`*'" != "" {
	
		// dot separator
		local bd = strpos("`1'", ".")
		// root
		local br = substr("`1'", 1, `bd' - 1)
		// extension
		local be = substr("`1'", `bd' + 1, .)
		// backup name
		local bk = subinstr(strtoname("`br' backup `c(current_date)'"), "__", "_", .)
		
		if "`be'" == "do"  local bf "code"
		if "`be'" == "pdf" local bf "course"
		// careful with that axe eugene
		if "`be'" == "ado" local bf "setup"
		
		// path to backup
		local pb "`bf'/`bk'.`be'"
		// path to file
		local pf "`bf'/`1'"
		
		if "`bf'" == "" {
		    di as err "Error: wrong filename (should end with .ado, .do or .pdf)"
		    exit 198
		}
		else {
			di as txt _n "Downloading `1' to the `bf' folder..."
		    cap qui copy "`pf'" "`pb'", public replace
		
		    cap qui erase "`pf'" // instead of rm for Windows compatibility
		    cap qui copy "http://briatte.org/srqm/`1'" "`pf'", public replace
		
		    if !_rc {
		    	di as txt "Successfully downloaded."
		    		
		    	if "`be'" == "pdf" di as inp _n "{stata !open `pf':open `pf'}"
		    	if "`be'" == "do" di as inp _n "{stata doedit `pf':doedit `pf'}"
		    }
		    else {
		    	di as err "Error:", _rc, " (no file updated)" _n ///
		    		"Check your syntax and connection."
		    	cap qui copy "`pb'" "`pf'", public replace
		    	if !_rc {
		    		cap rm "`pb'"
		    		di as txt "- `bk'.`be' restored to `1'"
		    	}
		    	else {
		    		di as err "Error:", _rc, "(no backup restored)" 
		    	}
		    }
		}
		macro shift
	}

end

// bye
