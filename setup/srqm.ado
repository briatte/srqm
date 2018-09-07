*! check integrity of the course utilities
*! returns error -1 if anything is missing
*!
*! ARGUMENTS
*!
*! , i , info    : print system information
*! , v , verbose : print ado-file descriptions
*!
cap pr drop srqm
program srqm
  syntax, [Info] [Verbose]
  
  loc pid "[SRQM]"
  
  di as txt "`pid' Date:", as res c(current_date), c(current_time)
  di as txt "`pid' Software: Stata", as res c(stata_version)
  di as txt "`pid' OS:", as res c(os), c(osdtl)
  di as txt "`pid' Computer:", as res c(machine_type) _n

  di as txt "`pid' Stata directories:"
  adopath

  di as txt _n "`pid' Working directory:", as res c(pwd)
  di as txt "`pid' Course folders: ", as res "$SRQM_FOLDERS"
  di as txt "`pid' Course datasets:", as res "$SRQM_DATASETS"
  qui tokenize "$SRQM_PACKAGES"
  di as txt "`pid' Installed packages:", ///
    as res "`1',", "`2',", "...", "(`:word count `*'' packages)"
  
  foreach x in $SRQM_ADOFILES $SRQM_DOFILES {
    
    loc f = "$SRQM_SETUP/`x'"
    if !regexm("`x'", ".do") loc f = "`f'.ado"

    cap confirm f "`f'"
    
    if _rc {
      
      di ///
        as err "`pid' ERROR:" , ///
        as txt "missing"      , ///
        as inp "`f'"
        
      exit -999 // quit with bogus error code
      
    }
    else if "`verbose'" != ""  {
      
      noi di as txt _n "`pid' `f'"
      cap noi type "`f'", star
      
    }
        
  }
  
end
