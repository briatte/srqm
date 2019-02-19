
/* ----------------------------------------------------------------- WVS 9904 --

   Data:   World Values Survey (WVS)
   Source: WVS website; host: JD Systems Institute

   http://www.worldvaluessurvey.org/
   http://www.worldvaluessurvey.org/WVSDocumentationWV4.jsp

   - Downloads the codebook and questionnaire
   - Downloads Wave 4 (1999-2004), v2018-09-12 official release
   - Makes all variables lowercase

   Last modified: 2019-02-19

   NOTE -- downloading from the WVS website requires setting cookies, which is
   not possible via Stata alone; to make sure that this script runs fine on 
   standard Windows, it downloads the files from my own access point instead.

----------------------------------------------------------------------------- */

loc d "data/"
loc v "_v20180912"

// -------------------------------------------------------- download codebook --

loc f "F00008074-WV4_Codebook`v'"

* grab from own remote source
noi srqm_grab "`d'`f'.pdf", nobackup

* rename
copy `f'.pdf "wvs9904_codebook.pdf", public replace
erase `f'.pdf

// --------------------------------------------------- download questionnaire --

loc f "F00001316-WVS_2000_Questionnaire_Root.pdf"

* grab from own remote source
noi srqm_grab "`d'`f'", nobackup

* rename
copy `f' "wvs9904_questionnaire.pdf", public replace
erase `f'

// --------------------------------------------------------- download dataset --

loc f "F00008070-WV4_Data_Stata`v'"

* grab from own remote source
noi srqm_grab "`d'`f'.zip", nobackup

* .zip
unzipfile `f'.zip
rm `f'.zip

loc f = subinstr("`f'", "F00008070-", "", 1)

* .dta
use `f'.dta, clear
rm `f'.dta

// ----------------------------------------------------------------- finalize --

* make all variable names lowercase
rename *, lower

// ------------------------------------------------------------ label dataset --

la da "World Values Survey Wave 4 (1999-2004)"

// ---------------------------------------------------------- have a nice day --
