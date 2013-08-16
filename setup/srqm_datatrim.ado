*! SRQM data preparation utility
*! (drops variables under thresholds of observations, defaults at 25%)
cap pr drop srqm_datatrim
pr srqm_datatrim
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

// ttyl
