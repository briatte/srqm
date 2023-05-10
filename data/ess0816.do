
/* ----------------------------------------------------------------- ESS 0816 --

   Data:   European Social Survey (ESS)
   Source: ESS website

   https://www.europeansocialsurvey.org/
   https://www.europeansocialsurvey.org/data/round-index.html

   - Downloads the codebook and questionnaire
   - Downloads Round 4 (2008-2010)

   Last modified: 2021-01-31

   NOTE -- downloading from the ESS website requires email registration and
   login, which is not possible via Stata alone; to make sure that this script
   runs fine, it downloads the files from my own access point instead.

----------------------------------------------------------------------------- */

loc n "ess0816"
loc d "data/"

// ----------------------------------------------- download codebook, Round 4 --

loc f "ESS4_data_documentation_report_e05_5.pdf"

* grab from own remote source
noi srqm_grab "`d'`f'", nobackup

* rename
copy `f' "`n'_codebook_r4.pdf", public replace
erase `f'

// ----------------------------------------------- download codebook, Round 8 --

loc f "ESS8_data_documentation_report_e02_1.pdf"

* grab from own remote source
noi srqm_grab "`d'`f'", nobackup

* rename
copy `f' "`n'_codebook_r8.pdf", public replace
erase `f'

// ------------------------------------------------- download weighting guide --

loc f "ESS_weighting_data_1.pdf"

* grab from own remote source
noi srqm_grab "`d'`f'", nobackup

* rename
copy `f' "`n'_weighting_guide.pdf", public replace
erase `f'

// ----------------------------------------- download dataset, Rounds 4 and 8 --

loc d "data/"
loc j "ESS4e04_5 ESS8e02_1"
foreach f of loc j {

  loc f "`f'.stata.zip"

  * grab from own remote source
  noi srqm_grab "`d'`f'", nobackup

  * .zip
  unzipfile `f', replace
  rm `f'

  loc f = subinstr("`f'", ".stata.zip", "", 1)

  * .dta
  if "`f'" == "ESS4e04_5" {
    use `f'.dta, clear
  }
  else {
    merge 1:1 essround cntry idno using `f'.dta, nogen assert(1 2)
  }
  rm `f'.dta

  * extra file
  rm "Stata_README.txt"

  // ------------------------------------------------ convert Unicode strings --
  // WARNING: won't look nice in Stata 13-

  loc f "`f'_formats_unicode"

  * .do
  do `f'.do
  rm `f'.do

}

// ------------------------------------------------------------ label dataset --

la da "European Social Survey Rounds 4 (2008-9) and 8 (2016-7)"

note _dta: European Social Survey
note _dta: URL: {bf:https://www.europeansocialsurvey.org/}

// ---------------------------------------------------------- have a nice day --
