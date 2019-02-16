
/* ----------------------------------------------------------------- WVS 9904 --

   Data:   World Values Survey (WVS)
   Source: WVS website; host: JD Systems Institute

   http://www.worldvaluessurvey.org/
   http://www.worldvaluessurvey.org/WVSDocumentationWV4.jsp

   - Downloads Wave 4 (1999-2004), v2018-09-12 official release
   - Downloads the codebook
   - Makes all variables lowercase

   Last modified: 2019-02-16

   NOTE -- this script currently does not work due to the WVS website requiring
   cookies to get past its main index page. See Anthony J. Damico's lodown R
   package for a workaround:
   
   https://github.com/ajdamico/lodown/blob/master/R/wvs.R#L272

----------------------------------------------------------------------------- */

* common URL / filename parts
loc w "WV4_"
loc b "http://www.worldvaluessurvey.org/wvsdc/DC00012/F00008074-`w'"
loc v "_v20180912"

// -------------------------------------------------------------- get dataset --

loc f "wv9904"
loc u "`b'Data_Stata`v'.zip"

di as inp "wvs9904:", as txt "downloading", "`u'"

* ZIP file
copy "`u'" `f'.zip, replace
unzipfile `f'.zip
rm `f'.zip

* DTA file
use `w'Data_Stata`v'.dta, clear
rm `w'Data_Stata`v'.dta

// ------------------------------------------------- make variables lowercase --

rename *, lower

// ------------------------------------------------------------- get codebook --

loc f `f'_codebook.pdf
loc u "`b'Codebook`v'.pdf"

di as inp "wvs9904:", as txt "downloading", "`u'"

copy `u' `f', replace

// ------------------------------------------------------------ label dataset --

la da "World Values Survey Wave 4 (1999-2004)"

// ---------------------------------------------------------- have a nice day --
