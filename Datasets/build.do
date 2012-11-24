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

save datasets/ess2008, replace

cap rm datasets/ess2008.zip
zipfile datasets/ess2008*, saving(datasets/ess2008.zip, replace)

unzipfile datasets/ess2008.zip, replace
ls datasets/ess2008*

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

save datasets/gss2010, replace

rm temp.zip
rm 2010.dta

cap rm datasets/gss2010.zip
zipfile datasets/gss2010*, saving(datasets/gss2010.zip)

unzipfile datasets/gss2010.zip, replace
ls datasets/gss2010*

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

save datasets/nhis2009, replace

cap rm datasets/nhis2009.zip
zipfile datasets/nhis2009*, saving(datasets/nhis2009.zip, replace)

unzipfile datasets/nhis2009.zip, replace
ls datasets/nhis2009*

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

save datasets/qog2011, replace

cap rm datasets/qog2011.zip
zipfile datasets/qog2011*, saving(datasets/qog2011.zip)

unzipfile datasets/qog2011.zip, replace
ls datasets/qog2011*

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

save datasets/wvs2000, replace

rm temp.zip
rm wvs2000_v20090914.dta

cap rm datasets/wvs2000.zip
zipfile datasets/wvs2000*, saving(datasets/wvs2000.zip)

unzipfile datasets/wvs2000.zip, replace
ls datasets/wvs2000*
