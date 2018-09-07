*! SRQM data preparation utility
*! (drops variables under thresholds of observations, defaults at 25%)
cap pr drop srqm_datatrim
pr srqm_datatrim

	syntax [, k(real 25)]
  
  loc pid = "[DATA-TRIM]"
	qui count
  
	local t = int(r(N) * `k'/100)
  
	// Drop empty variables.
	foreach v of varlist * {
	    qui count if !mi(`v')
		local n = r(N)
	    if `n' == 0 {
			  loc l: var l `v'
			  di as txt "`pid' dropped", as inp "`v'", as txt "(N = 0):" _n "`l'"
	    	drop `v'
	    }
	}
  
	// Drop low-N variables.
	foreach v of varlist * {
		qui count if !mi(`v')
		local n = r(N)
		if `n' < `t' {
			local l: var l `v'
			di as txt "`pid' dropped", as inp "`v'", as txt "(`n' < `t'):" _n "`l'"
	    drop `v'
	    }
	}
    
end

// ttyl
