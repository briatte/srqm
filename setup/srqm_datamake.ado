*! SRQM data preparation utility
*! (labels, zips and lists variables of courses datasets)
cap pr drop srqm_datamake
pr srqm_datamake
	syntax, label(string asis) filename(name)

	// Teaching annotation.
	notes drop _dta
	la data "`label'"
	note _dta: `label'
	note _dta: Teaching dataset. Please do not redistribute.
	note _dta: This version: TS

	qui cd data
	local fn `filename'

	// Export variables.
	cap log close `fn'_variables
	log using `fn'_variables.txt, text name(`fn'_variables) replace
	d
	log close `fn'_variables

	// Compress and uncompress.
	saveold `fn', replace
	cap rm `fn'.zip
	zipfile `fn'*, saving(`fn'.zip, replace)
	unzipfile `fn'.zip, replace

	ls `fn'*
	qui cd ..
end

// ttyl
