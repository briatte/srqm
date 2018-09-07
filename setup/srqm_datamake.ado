*! SRQM data preparation utility
*! (labels, zips and lists variables of courses datasets)
cap pr drop srqm_datamake
pr srqm_datamake

	syntax, label(string asis) filename(name)
  
  loc pid = "[DATA-MAKE]"
  
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
  
	// Teaching annotation.
	notes drop _dta
	la data "`label'"
	note _dta: `label'
	note _dta: Teaching dataset. Please do not redistribute.
	note _dta: Teaching version production date: TS

	qui cd data
	local fn `filename'

	// Export variables.
	cap log close `fn'_variables
	log using `fn'_variables.txt, text name(`fn'_variables) replace
	noi d
	log close `fn'_variables

	// Compress and uncompress.
  di as txt "`pid' saving data files to", as inp "`c(pwd)'"
	qui saveold `fn', replace
	cap erase `fn'.zip
	qui zipfile `fn'*, saving(`fn'.zip, replace)
	qui unzipfile `fn'.zip, replace

	ls `fn'*
  
  di as txt "`pid' returning to", as inp "$srqm_wd"
	qui cd ..
  
end

// ttyl
