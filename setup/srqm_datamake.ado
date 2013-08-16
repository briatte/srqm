*! SRQM data preparation utility
*! (labels, zips and lists variables of courses datasets)
cap pr drop srqm_datamake
pr srqm_datamake
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

// ttyl
