*! add working directory to setup/profile.do and copy it to application folder
*!
*! ARGUMENTS
*!
*! , f , force  : force copy
*! , o , off    : remove profile.do from application folder
*!
cap pr drop srqm_link
program srqm_link
  syntax [, Force Off]

loc pid "[LINK]"
loc default "<default>"

loc source  "$SRQM_SETUP/profile.do"
loc target  "`c(sysdir_stata)'profile.do"

cap confirm f "`target'"

if "`off'" != "" { //  must come first
  
  cap erase "`target'"

  if _rc == 601 {
  
    di as txt "`pid' no file to remove at", as inp "`target'"
  
  }
  else if _rc {
    
    di ///
      as err "`pid' ERROR:"     , ///
      as txt "failed to remove" , ///
      as inp "`target'"         , ///
      as txt "(code", _rc ")"
    
  }
  else {

    // go to application folder to avoid profile.do re-setting up on Macs
    qui cd "`c(sysdir_stata)'"
  
    di ///
      as txt "`pid' removed"                    , ///
      as inp "`target'"                        _n ///
      as txt "`pid' working directory set to"   , ///
      as inp "`c(pwd)'"                        _n ///
      as txt "`pid' You have left the course." _n ///
             "`pid' Farewell! Enjoy life and Stata."
  
  }
  
  exit 0 // quit cleanly

}
if _rc | "`force'" != "" {

  di ///
    as txt "`pid' telling Stata to find the SRQM folder at startup" _n ///
    as txt "`pid' source:"      , ///
    as inp "`c(pwd)'/`source'" _n ///
    as txt "`pid' target:"      , ///
    as inp "`target'"

	// escape all backslashes in path to working directory (required for Windows)
	loc replacement = subinstr("$SRQM_WD", "\", "\BS", .)
	
  // copy setup/profile.do to profile template, and move to application folder
  cap filefilter "`source'" "`target'", ///
  	from("\Q`default'\Q") to("\Q`replacement'\Q") ///
  	replace

  if !r(occurrences) {
  
    di ///
      as err "`pid' ERROR:"                    , ///
      as txt "no replacement string found in" , ///
      as inp "`source'"

  }

  if _rc {
    
    di ///
      as err "`pid' ERROR:"    , ///
      as txt "failed to copy (code", _rc ")"
    
  }
    
  if _rc | !r(occurrences) {
    
    exit -1 // bogus error code
  
  }
  else {
    
    noi di as txt "`pid' working directory successfully set"
    
  }
    
}
else {

  exit 0 // exit cleanly

}

end

// done
