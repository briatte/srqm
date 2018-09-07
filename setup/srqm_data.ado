*! srqm_data  : run data preparation do-files
*!              returns an error if source files are missing
*!
*! USAGE
*!
*! srqm_data `name`       : run data preparation do-file for dataset `name`
*! srqm_data all          : run all data preparation do-files
*!
*! OPTIONS
*!
*! using()  : set the source file folder (defaults to data/ folder)
*! , log    : create a log of each data preparation do-file executed (default)
*!            the log will be located in the source file folder
*! , nolog  : do not log data preparation
*!
*! HISTORY
*!
*! 2017-06-05  : Added ESS Rounds 6 and 7
*! 2016-09-01  : Updated ESS Round 5 documentation, other ESS files unchanged
*! 2016-09-01  : Updated QOG data and codebook to 2016 edition
*! 2016-09-01  : Updated GSS to years 1972-2014, using new NORC website
*!
cap pr drop srqm_data
pr srqm_data

  syntax anything [using/] [, log]

  tokenize `anything'

  if "`using'" == "" {
    loc using "data"
  }
  
  loc pid "[DATA]"
  loc d "`using'"

  * ----------------------------------------------------------------------------
  * run from the SRQM folder
  * ----------------------------------------------------------------------------

  cap qui cd "$srqm_wd"
  //noi di as txt "`pid' running from", as inp "$srqm_wd"
  
  if _rc {

    di ///
      as err "`pid' ERROR:", ///
      as txt "SRQM folder is not set"

    exit -1 // bogus error code

  }
  else {
  
    di as txt "[DATA] looking for restorable source files in", ///
      as inp "`d'", ///
      as txt "folder"
  
  }

  * ----------------------------------------------------------------------------
  * if required, cycle through all teaching datasets
  * ----------------------------------------------------------------------------

  if "`1'" == "all" {
  
    tokenize $SRQM_DATASETS
  
  }
  
  * --------------------------------------------------------------------------
  * run from data folder
  * --------------------------------------------------------------------------

  cap cd "`d'"

  while "`*'" != "" {

    di as txt "[DATA] updating" , ///
      as inp "`d'/`1'.dta"      , ///
      as txt "using"            , ///
      as inp "`d'/`1'.do"       , ///
      as txt "(might take a while)"
  
    * --------------------------------------------------------------------------
    * cycle across teaching dataset names
    * --------------------------------------------------------------------------

    loc found = ""
    foreach i in $SRQM_DATASETS {

      if "`1'" == "`i'" loc found = "`i'"

    }
    if "`found'" == "" {
    
      * ------------------------------------------------------------------------
      * show list of possible datasets in case of error
      * ------------------------------------------------------------------------

	    di ///
        as err "`pid' ERROR:"            , ///
        as txt "invalid dataset name"    , ///
        as inp "`i'"                    _n ///
        as txt "`pid' supported names:"  , ///
        as inp "$SRQM_DATASETS"

      exit 198
      
    }
    else {
    
      * ------------------------------------------------------------------------
      * make dataset: (1) open log (2) run do-file (3) close log
      * ------------------------------------------------------------------------

      if "`log'" != "" {
  
        di as txt "[DATA] logging to", ///
          as inp "`d'/`found'.log"
        
        cap log close `found'
        cap qui log using "`found'.log", name(`found') replace
  
      }

      run "`found'.do"
      cap qui log close `found'
      
    }
  
    macro shift

  }

  exit 0

  // --------------------------------------------------------- ESS 2008-2010 -----

  * URL: http://www.europeansocialsurvey.org/

  if inlist("`1'", "all", "ess0810") {
    // Get the data (downloaded from the website).
    use "`src'/ESS/ESS4e04_3.stata/ESS4e04_3.dta", clear

    // Zero-match merge (non-longitudinal survey).
    merge 1:1 idno cntry edition using "`src'/ESS/ESS5e03_2.stata/ESS5e03_2.dta", nogen

    // Encode missing values (same code for both ESS rounds).
    run "`src'/ESS/ESS4e04_3.stata/ESS_miss.do"

    // Trim (this threshold drops nation-specific questions).
    srqm_datatrim, k(9)

    // Get codebook.
    copy "`src'/ESS/ESS4_data_documentation_report_e05_3.pdf" ///
        data/ess0810r4_codebook.pdf, replace
    copy "`src'/ESS/ESS5_data_documentation_report_e04_0.pdf" ///
        data/ess0810r5_codebook.pdf, replace

    srqm_datamake, label(European Social Survey 2008-2010) filename(ess0810)
  }

  // --------------------------------------------------------- GSS 2000-2014 -----

  * URL: http://gss.norc.org/

  if inlist("`1'", "all", "gss0014") {
  	// Get the data.
    	loc gss GSS7214_R6b
  	cap use "`src'/GSS/GSS_stata/`gss'.dta", clear

  	// Download the 1972-2014 cumulative file if needed (large, > 350 MB).
  	if _rc==601 {
  		local link "http://gss.norc.org/documents/stata/GSS_stata.zip"
  		copy `link' gss.zip, replace
  		unzipfile gss.zip
  		use `gss'.dta, clear
  		erase gss.zip // comment out to keep the cumulative data zip
  		erase `gss'.dta // comment out to keep the cumulative data file
      erase "Release Notes 7214.pdf" // comment out to keep the release notes
  	}

  	// Subset years.
  	drop if year < 2000

  	// Trim (low threshold to accommodate single-year questions)
  	// Note: be careful to maintain a threshold that is sufficiently high to
  	// keep less than 2047 variables in order for the course to run under old
  	// or limited of versions of Stata (at Sciences Po, Stata 11 IC). The value
  	// below leaves 2,015 variables.
  	srqm_datatrim, k(5.5)

  	// Get the codebook.
  	local file data/gss0014_codebook.pdf
  	local link "http://gss.norc.org/documents/codebook/GSS_Codebook.pdf"
  	cap conf f `file'
  	if _rc==601 copy `link' `file', replace

  	srqm_datamake, label(U.S. General Social Survey 2000-2014) filename(gss0014)
  }

  // -------------------------------------------------------- NHIS 1997-2011 -----

  * URL: http://www.cdc.gov/nchs/nhis.htm

  if inlist("`1'", "all", "nhis9711") {
  	// Get the data (downloaded from the website).
    loc data "ihis_00001"
  	copy "`src'/NHIS/9711/`data'.zip" "`data'.zip"
    unzipfile "`data'.zip"
    do "`src'/NHIS/9711/`data'.do"
    erase "`data'.dat"
    erase "`data'.zip"

    // keep sample children and adults for year 1997-2011
    qui keep if year > 1997 & astatflg == 1
    drop cstatflg astatflg

    // simplify race variable
    qui gen raceb = racea
    qui replace raceb = 1 if raceb == 100
    qui replace raceb = 2 if raceb == 200
    qui replace raceb = 3 if hispeth != 10
    qui replace raceb = 4 if raceb > 310 & raceb < 570
    // 310 American Indian, 570 other, 580 unreleasable, 600 multiple
    qui replace raceb = . if raceb > 4
    la de raceb_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian"
    la val raceb raceb_lbl
    la var raceb "Racial-ethnic profile"
    notes raceb: ///
    	Assembled from hispeth and racea, excluding American Indians and unclassifiable cases.

    // correlate class estimates and official figures of Body Mass Index
    qui gen bmi2 = weight * 703 / height^2 if weight < 996 & height < 96
    fre bmi if abs(bmi - bmi2) > 1, r(5)
    mean bmi bmi2 if bmi < 99.8 [pw = sampweight]
    kdensity bmi, addplot(kdensity bmi2) ti("") ///
      legend(order(1 "Official measure" 2 "Public file"))
    drop bmi bmi2

    // drop 10-pt health status (available only for year 1988)
    drop health10pt
    // drop household weights (unused)
    drop hhweight
    // drop supp. weights flags (unavailable after 1997)
    drop supp2wt

  	// Trim.
  	srqm_datatrim

  	srqm_datamake, label(U.S. National Health Interview Survey 1997-2011) filename(nhis9711)
  }

  // -------------------------------------------------------------- QOG 2016 -----

  * URL: http://qog.pol.gu.se/
  * URL: http://www.qogdata.pol.gu.se/data/

  if inlist("`1'", "all", "qog2016") {
  	// Get the data.
  	cap use "`src'/QOG/qog_std_cs_jan16.dta", clear

  	// Download if needed.
  	if _rc==601 use "http://www.qogdata.pol.gu.se/data/qog_std_cs_jan16.dta", clear

  	// Trim (higher threshold than in 2013 - 12.5).
  	srqm_datatrim, k(20)
	
  	// Get the codebook.
  	local file data/qog2016_codebook.pdf
  	local link "`src'/QOG/qog_std_jan16.pdf"
  	cap conf f `file'
  	if _rc==601 cap copy "`link'" "`file'", replace

  	// Download if needed.
    cap conf f `file'
  	if _rc==601 use "http://www.qogdata.pol.gu.se/data/qog_std_jan16.pdf", clear

  	srqm_datamake, label(Quality of Government 2016) filename(qog2016)
  }

  * Note: the -qog- and -qogbook- packages available from SSC have been outdated
  * for over a year. They can still be installed by using the -srqm_pkgs- command
  * with the -extra- option, but are not likely to work properly.

  // -------------------------------------------------------------- WVS 2000 -----

  * URL: http://www.worldvaluessurvey.org/

  if inlist("`1'", "all", "wvs2000") {
  	// Get the data.
  	cap use "`src'/WVS/wvs2000_v20090914.dta", clear

  	// Download if needed.
  	if _rc==601 {
  		local link "http://www.asep-sa.org/wvs/wvs2000/wvs2000_v20090914_stata.zip"
  		copy `link' temp.zip, replace
  		unzipfile temp.zip
  		use wvs2000_v20090914.dta, clear
  		rm temp.zip
  		rm wvs2000_v20090914.dta
  	}

  	// No trim: missing values are not properly encoded.
  	// Also, some items are asked only in a few countries (e.g. Islam, neighbours).

  	// Capitalize country names
    	// Thanks to William A. Huber: http://stackoverflow.com/q/12591056/635806
  	local sLabelName: value l v2
  	di "`sLabelName'"
  	qui levelsof v2, local(xValues)
  	foreach x of local xValues {
  	    local sLabel: label (v2) `x', strict
  	    local sLabelNew = proper("`sLabel'")
  	    di as txt "`x': `sLabel' ==> `sLabelNew'"
  	    label define `sLabelName' `x' "`sLabelNew'", modify
  	}

  	// Get the codebook.
  	local file data/wvs2000_codebook.pdf
  	local link "`src'/WVS/wvs2000_codebook.pdf"
  	cap conf f `file'
  	if _rc==601 copy `link' `file', replace

  	srqm_datamake, label(World Values Survey 2000) filename(wvs2000)
  }

  cap log close srqm_data

end

// ttyl
