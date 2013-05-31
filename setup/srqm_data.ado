/* --- SRQM data preparation script --------------------------------------------

* This do-file produces the teaching datasets distributed as part of the course.
* Run it only to repair your Teaching Pack if you accidentally damage the files.
* Note that the code requires running Stata with admin privileges.

   Last revised 2013-05-31.

*! version 1.2: updated to GSS 2000-2012 (Cumulative Release 1)
*! version 1.1: updated to QOG 2013 15May13
*! version 1.0: first release

----------------------------------------------------------------------------- */

cap pr drop srqm_prep
pr srqm_prep
	syntax, label(string asis) filename(name)
	// Teaching annotation.
	notes drop _dta
	la data "`label'"
	note _dta: `label'
	note _dta: Teaching dataset slightly altered from source.
	note _dta: Please do not redistribute and check original.
	note _dta: This version: TS
	// Compress and uncompress.
	qui cd data
	local fn `filename'
	saveold `fn', replace
	cap rm `fn'.zip
	zipfile `fn'*, saving(`fn'.zip, replace)
	unzipfile `fn'.zip, replace
	ls `fn'*
	// Export variables.
	cap log close `fn'_variables
	log using `fn'_variables.txt, text name(`fn'_variables) replace
	d
	log close `fn'_variables
	qui cd ..
end

cap pr drop srqm_trim
pr srqm_trim
	// Arbitrary threshold at 25% of observations
	syntax [, k(real 25)]
	qui count
	local t = int(r(N) * `k'/100)
	// Drop empty variables.
	foreach v of varlist * {
	    qui count if !mi(`v')
		local n = r(N)
	    if `n' == 0 {
			local l: var l `v'
			di as txt "Dropping","`v' (N = 0):","`l'"
	    	drop `v'
	    }
	}
	// Drop low-N variables.
	foreach v of varlist * {
		qui count if !mi(`v')
		local n = r(N)
		if `n' < `t' {
			local l: var l `v'
			di as txt "Dropping","`v' (`n' < `t'):","`l'"
	    	drop `v'
	    }
	}
	// Get ready for export.
	qui cd "$srqm_wd"
end

// let's go

cap pr drop srqm_data
pr srqm_data

if "`1'" == "" {
    di as err "No dataset argument provided."
    exit 198
}

cap log close srqm_data
log using "$srqm_wd/setup/srqm_data.log", name(srqm_data) replace
local src "~/Documents/Research/Data"

di as inp _n "Updating the `1' teaching dataset." _n

// -------------------------------------------------------------- ESS 2008 -----

if inlist("`1'", "all", "ess2008") {
	// Get the data (downloaded from the website).
	use "`src'/ESS/ESS4e04.1/ESS4e04.1_F1.dta", clear

	// Trim (very low threshold to cut at approx. 500).
	srqm_trim, k(1)
	
	// Get codebook.
	copy "`src'/ESS/ESS4e04.1/ESS4e04.1.pdf" data/ess2008_codebook.pdf, replace
	
	srqm_prep, label(European Social Survey 2008) filename(ess2008)
}

// -------------------------------------------------------------- GSS 2012 -----

if inlist("`1'", "all", "gss0012") {
	// Get the data.
	cap use "`src'/GSS/gss7212_r1.dta", clear

	// Download the 1972-2012 cumulative file if needed (large, > 300 MB).
	if _rc==601 {
		local link "http://publicdata.norc.org/GSS/DOCUMENTS/OTHR/GSS_stata.zip"
		copy `link' temp.zip, replace
		unzipfile temp.zip
		use gss7212_r1.dta, clear
		rm temp.zip
		rm gss7212_r1.dta // comment that out to keep the full cumulative file
	}

	// Subset years.
	drop if year < 2000

	// Trim (very low threshold to accommodate single-year questions)
	srqm_trim, k(5)

	// Get the codebook.
	local file data/gss0012_codebook.pdf
	local link "http://publicdata.norc.org/GSS/DOCUMENTS/BOOK/GSS_Codebook.pdf"
	cap conf f `file'
	if _rc==601 copy `link' `file', replace

	srqm_prep, label(U.S. General Social Survey 2000-2012) filename(gss0012)
}

// ------------------------------------------------------------- NHIS 2009 -----

if inlist("`1'", "all", "nhis2009") {
	// Get the data (downloaded from the website).
	use "`src'/NHIS 2009/NHIS_2009.dta", clear

	// Trim.
	srqm_trim

	srqm_prep, label(U.S. National Health Interview Survey 2009) filename(nhis2009)
}

// -------------------------------------------------------------- QOG 2013 -----

if inlist("`1'", "all", "qog2013") {
	// Get the data.
	cap use "`src'/QOG/QOG Standard 2013/QoG_std_cs_15May13.dta", clear

	// Download if needed.
	if _rc==601 use "http://www.qogdata.pol.gu.se/data/qog_std_cs.dta", clear

	// Trim (lower threshold).
	srqm_trim, k(12.5)
	
	// Get the codebook.
	local file data/qog2013_codebook.pdf
	local link "http://www.qogdata.pol.gu.se/data/Codebook_QoG_Std15May13.pdf"
	cap conf f `file'
	if _rc==601 copy `link' `file', replace

	srqm_prep, label(Quality of Government 2013) filename(qog2013)
}

* Note: the -qoguse- command downloads the most recent version of the data, but
* as of today (May 2013), the -qogbook- command downloads the old 2011 codebook.

// ------------------------------------------------------------ TRUST 2012 -----

if inlist("`1'", "all", "trust2012") {
	// Get the data.
	cap use "`src'/trust2012/trust2012.dta"
}

// -------------------------------------------------------------- WVS 2000 -----

if inlist("`1'", "all", "wvs2000") {
	// Get the data.
	cap use "`src'/WVS 2008/wvs1981_2008_official_files/wvs2000.dta", clear

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

	// Capitalize country names.
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
	local link "http://www.worldvaluessurvey.org/wvs/articles/folder_published/survey_2000/files/root_q_2000.pdf"
	cap conf f `file'
	if _rc==601 copy `link' `file', replace

	srqm_prep, label(World Values Survey 2000) filename(wvs2000)
}

log close srqm_data

end

// ttyl
