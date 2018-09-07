*! tell Stata to set the working directory to the SRQM folder at startup
*! IMPORTANT: do not modify the path below by hand

gl SRQM_WD "<default>"

cap cd "$SRQM_WD"

* ------------------------------------------------------------------------------
* if the SRQM folder does not exist, explain error and quit
* ------------------------------------------------------------------------------

if _rc {

  noi di as err _n ///
    "[SRQM] ERROR:"                   , ///
    as txt "missing SRQM folder at"   , ///
    as inp "$SRQM_WD"             _n(2) ///
    as txt ///
      _col(8) ///
      "The SRQM folder was not found at its former location."  _n(2) ///
      _col(8) ///
      "This error occurs if the SRQM folder has been renamed or moved." _n ///
      _col(8) ///
      "Use the", as inp "File > Change Working Directory...", as txt ///
      "menu to manually select"  _n ///
      _col(8) ///
      "the SRQM folder, and re-execute the {stata run profile} command." _n
    
  exit 601 // missing

}
else {

  * ----------------------------------------------------------------------------
  * try running SRQM/profile.do
  * ----------------------------------------------------------------------------
  
	cap noi run profile
  
  * ----------------------------------------------------------------------------
  * if not, explain error and quit
  * ----------------------------------------------------------------------------

	if _rc { // folder check failed
    
		noi di ///
      as err "[SRQM] ERROR:", ///
			as txt "failed to run course setup" _n(2) ///
      as txt ///
        _col(8) ///
        "The SRQM folder is incomplete or damaged."  _n(2) ///
        _col(8) ///
        "Replace the folder with a backup copy,", ///
        "set it as the working directory," _n ///
        _col(8) ///
        "and re-execute the {stata run profile} command." _n

      exit _rc
    
	}
  else {
    
    // show version number
  	noi type profile.do, starbang
    
  }

}
