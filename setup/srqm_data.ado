*! srqm_data : download and prepare course datasets
*!
*! USAGE
*!
*! srqm_data [NAME]  : run data preparation do-file for dataset [NAME]
*! srqm_data all     : run all data preparation do-files
*!
cap pr drop srqm_data
pr srqm_data

  syntax anything

  loc pid "[DATA]"
  loc d "data"

  // -------------------------------------------------------- work from data/ --

  cap qui cd "$SRQM_WD/`d'"
  
  if _rc {

    di ///
      as err "`pid' ERROR:"   , ///
      as txt "could not find" , ///
      as inp "`d'"            , ///
      as txt "folder"

    exit -1 // bogus error code

  }

  // -------------------------------------------------------- parse arguments --

  tokenize `anything'
  
  * if required, cycle through all teaching datasets
  if "`1'" == "all" tokenize $SRQM_DATASETS

  // -------------------------------------------- cycle through dataset names --

  while "`*'" != "" {

    // ------------------------------------------- match course dataset names --

    loc f ""
    foreach i in $SRQM_DATASETS {

      if "`1'" == "`i'" loc f "`i'"

    }
    
    if "`f'" == "" {
    
      // ---------------------------- if no match, list allowed dataset names --

	    di ///
        as err "`pid' ERROR:"            , ///
        as txt "invalid dataset name"    , ///
        as inp "`1'"                    _n ///
        as txt "`pid' supported names:"  , ///
        as inp "$SRQM_DATASETS"

      exit 198
      
    }
    else {
    
      // ---------------------------------- run download / preparation script --

      loc s "`1'.do"
      
      di as txt "[DATA] updating" , ///
        as inp "`d'/`1'.dta"      , ///
        as txt "using"            , ///
        as inp "`d'/`s'"          , ///
        as txt "(might take a while)"
      
      cap noi run `s'
  
      if _rc {
    
        di ///
          as err "`pid' ERROR:"  ,  ///
          as txt "failed to run" , ///
          as inp "`s'"           , ///
          as txt "(code", _rc ")"

        qui cd "$SRQM_WD"
        exit -1 // bogus error code
    
      }
  
      // ----------------------------------------------- drop empty variables --
  
      foreach v of varlist * {

        qui count if !mi(`v')
        loc n = r(N)

        if `n' == 0 {

          loc l: var l `v'
          di as txt "`pid' dropping", as inp "`v'", as txt "(N = 0):" _n "`l'"
          drop `v'

        }

      }

      // ------------------------------------------ label as teaching dataset --

    	note _dta: Teaching dataset: please do not redistribute.
    	note _dta: Production date: TS

      // --------------------------------------- list variables, zip and save --

      di ///
        as txt "`pid' saving data files to", ///
        as inp "`d'"

    	* export variables to *_variables.txt log file
      loc l `1'_variables
    	cap log close `l'
    	log using `l'.txt, text name(`l') replace
    	noi d
    	log close `l'
  
      * save dataset in Stata 12 format
      *
      * - if run using Stata 12,
      *   saveold saves in Stata 8/9 format
      *   (.dta-format 113 from Stata 8 or 9)
      *
      * - if run using Stata 13,
      *   saveold saves in Stata (11?/)12 format
      *   (.dta-format 115 from Stata 12)
      *
      * - if run using Stata 14 or 15,
      *   saveold saves in Stata 12 (dta_???)
      *
      loc v = cond(c(version) >= 14, "version(12)", "")
    	qui saveold `1', `v' replace
  
    	* compress and uncompress
    	cap erase `1'.zip
    	qui zipfile `1'*, saving(`1'.zip, replace)
    	qui unzipfile `1'.zip, replace

    	noi ls `1'*
      
    }
  
    macro shift

  }

	qui cd "$SRQM_WD"

end

// --------------------------------------------------------------------- ttyl --
