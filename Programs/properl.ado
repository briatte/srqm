cap pr drop properl
program properl
	syntax varlist, [Verbose]
	local verbose = ("`verbose'" != "")
	
	foreach v of varlist `varlist' {
	
		local sLabelName: value label `v'
		di as txt "Editing variable " as res "`v'" ///
			as txt " (label " as res "`sLabelName'" as txt ")"

		qui levelsof `v', local(xValues)

		foreach x of local xValues {
		    local sLabel: label (`v') `x', strict
		    local sLabelNew = proper("`sLabel'")
		    
		    if "`sLabelNew'" != "" {
		    	if `verbose' di "  `x': `sLabel' ==> `sLabelNew'"
				la de `sLabelName' `x' "`sLabelNew'", modify
			}
		}

	}
	di as txt "Variable labels are now properly capitalized. "
	if `verbose' di _n "Thanks to William Huber for the code." _n ///
		"http://stackoverflow.com/questions/12591056/capitalizing-value-labels-in-stata"	
end
