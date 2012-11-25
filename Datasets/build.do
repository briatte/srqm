* This do-file produces the teaching datasets distributed as part of the course.
* Use only to repair your Teaching Pack if you accidentally overwrite the files.
* Note that the code requires running Stata with admin privileges.

// -------------------------------------------------------------- ESS 2008 -----

// Get the data (downloaded from the website).

use datasets/ess2008.dta, clear

// Initial subset from cumulative dataset.

drop if essround != 4

foreach v of varlist * {
    qui count if !mi(`v')
    if r(N)==0 {
        di "Dropping: " "`v'"
        drop `v'
    }
}

// Teaching annotation.

notes drop _dta
local N = _N
la data "European Social Survey 2008"
note _dta: European Social Survey 2008
note _dta: Full sample size: N = `N'
note _dta: Teaching dataset, please do not redistribute.
note _dta: This version: TS

// Compress and uncompress.

cd datasets
save ess2008, replace

cap rm ess2008.zip
zipfile ess2008*, saving(ess2008.zip, replace)

unzipfile ess2008.zip, replace
ls ess2008*

cd ..

// -------------------------------------------------------------- GSS 2010 -----

// Get the data.

copy http://publicdata.norc.org/GSS/DOCUMENTS/OTHR/2010_stata.zip temp.zip, replace

unzipfile temp.zip
use 2010.dta, clear

// Teaching annotation.

notes drop _dta
local N = _N
la data "General Social Survey 2010"
note _dta: General Social Survey 2010
note _dta: Full sample size: N = `N'
note _dta: Teaching dataset, please do not redistribute.
note _dta: This version: TS

// Remove empty variables.

foreach v of varlist * {
qui su `v'
if r(N)==0 {
	local l: var l `v'
    di as txt "Removing","`v':","`l'"
    drop `v'
    }
}

// Export mock codebook.

log using datasets/gss2010_codebook.log, name(gss2010) replace
d
codebook
log close gss2010

// Compress and uncompress.

rm temp.zip
rm 2010.dta

cd datasets
save gss2010, replace

cap rm gss2010.zip
zipfile gss2010*, saving(gss2010.zip)

unzipfile gss2010.zip, replace
ls gss2010*

cd ..

// ------------------------------------------------------------- NHIS 2009 -----

// Get the data (downloaded from the website).

use datasets/nhis2009.dta, clear

// Teaching annotation.

notes drop _dta
local N = _N
la data "National Health Interview Survey 2009"
note _dta: National Health Interview Survey 2009
note _dta: Full sample size: N = `N'
note _dta: Teaching dataset, please do not redistribute.
note _dta: This version: TS

// Export mock codebook.

log using datasets/nhis2009_codebook.log, name(nhis2009) replace
d
codebook
log close nhis2009

// Compress and uncompress.

cd datasets
save nhis2009, replace

cap rm nhis2009.zip
zipfile nhis2009*, saving(nhis2009.zip, replace)

unzipfile nhis2009.zip, replace
ls nhis2009*

cd ..

// -------------------------------------------------------------- QOG 2011 -----

// Get the data.

use http://www.qog.pol.gu.se/digitalAssets/1358/1358065_qog_csd_stata9_v6apr11.dta, clear

// Teaching annotation.

notes drop _dta
local N = _N
la data "Quality of Government 2011"
note _dta: Quality of Government 2011
note _dta: Full sample size: N = `N'
note _dta: Teaching dataset, please do not redistribute.
note _dta: This version: TS

// Get the codebook.

copy http://www.qog.pol.gu.se/digitalAssets/1390/1390246_the-qog-codebook--c-.pdf datasets/qog2011_codebook.pdf, replace

// Compress and uncompress.

cd datasets
save qog2011, replace

cap rm qog2011.zip
zipfile qog2011*, saving(qog2011.zip)

unzipfile qog2011.zip, replace
ls qog2011*

cd ..

// -------------------------------------------------------------- WVS 2000 -----

// Get the data.

copy http://www.asep-sa.org/wvs/wvs2000/wvs2000_v20090914_stata.zip temp.zip, replace

unzipfile temp.zip
use wvs2000_v20090914.dta, clear

// Teaching annotation.

notes drop _dta
local N = _N
la data "World Values Survey 2000"
note _dta: World Values Survey 2000
note _dta: Full sample size: N = `N'
note _dta: Teaching dataset, please do not redistribute.
note _dta: This version: TS

// Capitalize country names (code kindly provided by William A. Huber).

local sLabelName: value l v2
di "`sLabelName'"

levelsof v2, local(xValues)
foreach x of local xValues {
    local sLabel: label (v2) `x', strict
    local sLabelNew =proper("`sLabel'")
    di as txt "`x': `sLabel' ==> `sLabelNew'"
    label define `sLabelName' `x' "`sLabelNew'", modify
}

// Export mock codebook.

log using datasets/wvs2000_codebook.log, name(wvs2000) replace
fre v2
d
codebook
log close wvs2000

// Compress and uncompress.

rm temp.zip
rm wvs2000_v20090914.dta

cd datasets
save wvs2000, replace

cap rm wvs2000.zip
zipfile wvs2000*, saving(wvs2000.zip)

unzipfile wvs2000.zip, replace
ls wvs2000*

cd ..

// ttyl
