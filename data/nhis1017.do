
/* ---------------------------------------------------------------- NHIS 1017 --

   Data:   U.S. National Health Interview Survey (NHIS)
   Source: U.S. Centers for Disease Control (CDC), NCHS

   URL: https://www.cdc.gov/nchs/nhis/index.htm

   - Downloads survey years 2010 and 2017
   - Selects a few variables from the sample adult and persons
   - Renames the variables according to older NHIS years
   - Recodes race/ethnicity to a simplified form

   Last modified: 2019-02-14

----------------------------------------------------------------------------- */

* selected survey years
loc x "2017 2010"

* uncomment to download all possible NHIS survey years
* (previous years use self-extracting .exe files)

* numlist "2017/2010"
* loc x "`r(numlist)'"

foreach y in `x' {
  
  cap confirm f nhis`y'.dta
  if !_rc continue

  loc u "ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/"
  loc s "/NHIS/`y'/"

  // -------------------------------- download sample adults and persons data --

  loc j = "samadult personsx"
  foreach f of local j {

    * download ZIP file
    loc z "`f'.zip"
    
    cap confirm f `z'
    if _rc {
      loc a "`u'Datasets`s'`z'"
      noi di as inp "nhis`y':", as txt "downloading", "`a'"
      copy `a' `z', replace
    }
    unzipfile `z', replace // ASCII (.dat)

    * run preparation do-file
    loc d "`f'.do"
    loc a "`u'Program_Code`s'`d'"
    noi di as inp "nhis`y':", as txt "running", "`a'"
    cap run `a', nostop

    * clean up
    cap erase `z'       // .zip
    cap erase "`f'.dat"
    cap erase "`f'.dta"
    cap erase `d'       // .do
    cap erase "`f'.log"

    * save sample adults (merged and overwritten below)
    if "`f'" == "samadult" {
      save nhis`y', replace
    }

  }

  * merge only matched adults, ensuring all of sample adults are merged
  merge 1:1 hhx fmx fpx using nhis`y', assert(1 3) keep(3)

  // -------------------- rename variables from sample adults (samadult) data --

  * - year       Survey year

  * UID constructors (see NHIS README file)
  *
  * - h_id       Household record serial number
  * - p_id       Person identifier
  * - f_id       Family identifier

  ren (hhx fmx fpx) (h_id f_id p_id)

  * survey weights and variance estimation
  *
  * - strata     Pseudo-stratum
  * - psu        Pseudo-PSU
  * - sampweight Sample (interim) weight
  * - perweight  Final person weight

  * (pseudo) strata and primary sampling units
  cap ren (strat_p psu_p) (strata psu)  // NHIS 2010
  if _rc ren (pstrat ppsu) (strata psu) // NHIS 2017

  * survey year and weights
  ren (srvy_yr wtia_sa wtfa_sa) (year sampweight perweight)

  * socio-demographics
  *
  * - age        Age
  * - sex        Sex
  *
  * (renamed but not exported later on)
  *
  * - marstat    Marital status

  ren (age_p sex r_maritl) (age sex marstat)

  * main racial background
  *
  * - race       Racial-ethnic profile
  *
  * no pre-1997 revised OMB standards in recent NHIS survey years
  * using own recode, close to the one found in hiscodi3

  * d racerpi2 mracrpi2 mracbpi2 hispan_i hiscodi3
  
  * copy White-only, Black-only, Asian-only
  gen race = racerpi2 if racerpi2 != 3 & racerpi2 < 5

  * add Hispanic ethnicity (covers all/mixed types)
  replace race = 3 if hispan_i < 12

  la def race 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian"
  la val race race
  la var race "Racial-ethnic profile"
  notes race: ///
    Assembled from racerpi2 and hispan_i. Results close to recoding of hiscodi3.

  * Body Mass Index
  *
  * - height     Height in inches without shoes
  * - weight     Weight in pounds without clothes or shoes

  ren (aheight aweightp) (height weight)

  * no disagreement with precomputed BMI when missing values are examined:

  * gen bmi_manual = weight * 703 / height^2 if weight < 996 & height < 96
  * pwcorr bmi bmi_manual, obs
  * kdensity bmi if !mi(bmi_manual), addplot(kdensity bmi_manual) ti("") ///
  *  legend(order(1 "Official measure" 2 "Public file") row(1))

  // -------------------------- rename variables from persons (personsx) data --

  * - regionbr   Global region of birth
  * - yrsinus    Number of years spent in the U.S.
  * - earnings   Person's total earnings, previous calendar year
  * - health     Health status
  * - uninsured  Health Insurance coverage status
  *
  * (included in older NHIS online data requests, not found in current data)
  *
  * - pooryn     Above or below poverty threshold

  ren (ernyr_p phstat hikindnk) (earnings health uninsured)

  // --------------------------------------------------------------- finalize --

  * remove first part ("x: y") of variable labels
  foreach i of var * {
    loc j = regexr("`: var l `i''", "(.*): ", "")
    la var `i' "`j'"
  }

  loc v "     year h_id p_id f_id strata psu sampweight perweight"
  loc v "`v'  age sex race height weight"
  loc v "`v'  regionbr yrsinus earnings health uninsured"
  keep  `v'
  order `v'
  
  save nhis`y', replace
  
}

// -------------------------------------------------------------- merge years --

tokenize `x'

* load first year listed
loc f nhis`1'

use `f', clear
cap erase `f'.dta // ... and clean up

macro shift

* cycle through other years
foreach i in `*' {

  loc f nhis`i'
 
  merge 1:1 year h_id p_id f_id using `f', ///
    assert(1 2) nogen nol nonote norep

  cap erase `f'.dta // ... and clean up
 
}

// ------------------------------------------------------------ label dataset --

la da "U.S. National Health Interview Survey 2010 and 2017"

// ---------------------------------------------------------- have a nice day --
