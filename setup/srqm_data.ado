*! SRQM data preparation script
*! last upgrades: QOG 2013, GSS 2012
cap pr drop srqm_data
pr srqm_data
  syntax anything [using/] [, data(string)]

tokenize `anything'

if "`1'" == "" {
    di as err "Error: provide a dataset handle (", "$srqm_datasets", ") or 'all'"
    exit 198
}

if "`using'" != "" {
  cap log close srqm_data
  log using "$srqm_wd/setup/srqm_data.log", name(srqm_data) replace
}

if "`data'" == "" {
  local src = "~/Documents/Data"
  di as txt "Using personal default for local raw files:", "`src'"
}

di as inp _n "Updating `1' teaching dataset(s)..." _n

// -------------------------------------------------------------- ESS 2008 -----

if inlist("`1'", "all", "ess2008") {
	// Get the data (downloaded from the website).
	use "`src'/ESS/ESS4e04.1/ESS4e04.1_F1.dta", clear

	// Trim (very low threshold to cut at approx. 500).
	srqm_datatrim, k(1)
	
	// Get codebook.
	copy "`src'/ESS/ESS4e04.1/ESS4e04.1.pdf" data/ess2008_codebook.pdf, replace
	
	srqm_datamake, label(European Social Survey 2008) filename(ess2008)
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
	srqm_datatrim, k(5)

	// Get the codebook.
	local file data/gss0012_codebook.pdf
	local link "http://publicdata.norc.org/GSS/DOCUMENTS/BOOK/GSS_Codebook.pdf"
	cap conf f `file'
	if _rc==601 copy `link' `file', replace

	srqm_datamake, label(U.S. General Social Survey 2000-2012) filename(gss0012)
}

// ------------------------------------------------------------- NHIS 2009 -----

if inlist("`1'", "all", "nhis2009") {
	// Get the data (downloaded from the website).
	use "`src'/NHIS 2009/NHIS_2009.dta", clear

	// Trim.
	srqm_datatrim

	srqm_datamake, label(U.S. National Health Interview Survey 2009) filename(nhis2009)
}

// -------------------------------------------------------------- QOG 2013 -----

if inlist("`1'", "all", "qog2013") {
	// Get the data.
	cap use "`src'/QOG/QOG Standard 2013/QoG_std_cs_15May13.dta", clear

	// Download if needed.
	if _rc==601 use "http://www.qogdata.pol.gu.se/data/qog_std_cs.dta", clear

	// Trim (lower threshold).
	srqm_datatrim, k(12.5)
	
	// Get the codebook.
	local file data/qog2013_codebook.pdf
	local link "http://www.qogdata.pol.gu.se/data/Codebook_QoG_Std15May13.pdf"
	cap conf f `file'
	if _rc==601 copy `link' `file', replace

	srqm_datamake, label(Quality of Government 2013) filename(qog2013)
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
	local link "http://www.worldvaluessurvey.org/wvs/articles/folder_published/survey_2000/files/root_q_2000.pdf"
	cap conf f `file'
	if _rc==601 copy `link' `file', replace

	srqm_datamake, label(World Values Survey 2000) filename(wvs2000)
}

cap log close srqm_data

end

// ttyl
