
*! stab: simple tables (summary stats, correlation matrix)

cap pr drop stab
program stab
	// exports a tab-separated summary statistics and frequencies table
	// default 1 digit precision for mean and sd, 0 elsewhere

    syntax using/ [if] [in] [aweight fweight/] ///
    	[, SUmmarize(varlist) FRequencies(varlist) ///
    	CORRelate ttest Float(int 0) by(varname) replace] 
    tempname fh

	tokenize `summarize'
	local dv = "`1'"
	
	local fl0 = 10^(-`float')  // precision of min max and freqs
    local fl1 = .1*`fl0'       // one more digit for mean, sd and correlations
	local corr = ("`correlate'" != "")

	if "`summarize'"=="" & "`frequencies'"=="" {
		di as txt "You need to specify variables to describe. Example:" _n
		di "    sysuse nlsw88, clear"
		di "    su age wage"
		di "    tab1 race married"
		di "    tsst using table.txt, su(age wage) fr(race married) replace"
    	exit 0
    }
    else if strpos("`using'",".") > 0 {
    	// plain text format advocacy
	   	local using = substr("`using'",1,strpos("`using'",".")-1)
    }
    else {
		// go on		
    }

	if "`by'" != "" {
		if "`weight'" == "" {
			qui cap tab `by' `if' `in', gen(_`by'_) matcell(m)
		}
		else {
			qui cap tab `by' `if' `in' [`weight'=`exp'], gen(_`by'_)
			// mat li m
		}
		cap qui levelsof `by' `if' `in', local(by_lvls)
	}
	else {
		cap gen _by_fullsample_1 = 1
		local by = "by_fullsample"
		local by_lvls 1
	}
	
	// this monstrosity actually works
	
	local by_i = 0

	foreach by_val of local by_lvls {

		local by_i=`by_i'+1
		local by_lbl: var l _`by'_`by_i'
		local by_pos = strpos("`by_lbl'","==")
		local by_vlbl = substr("`by_lbl'",`by_pos'+2,.)
		
		local by_text = "for `by_vlbl'"
		if "`by'" == "by_fullsample" {
			local by_text = ""
			file open `fh' using `using'_stats.txt, write `replace'
			noi di as txt _n "Exporting summary statistics to", as inp ///
				"{browse `using'_stats.txt}" _n
		}
		else {
			if "`if'" == "" local iff = "if _`by'_`by_i'" 
			if "`if'" != "" local iff = "`if' & _`by'_`by_i'"
			local by_name = strtoname("`by_vlbl'")
			file open `fh' using `using'_stats_`by_name'.txt, write `replace'
			noi di as txt _n "Exporting summary statistics to", ///
				"{browse `using'_stats_`by_name'.txt}" _n "for category" ///
				, as inp "`by_vlbl':"
		}
		
		file write `fh' _n "Table 1. Summary statistics `by_text'"
		
	//--------------------------------- SUMMARY STATS
    	
	if "`summarize'" != "" {
	
		// watered down version of tabstatout

		file write `fh' _n "Variable" _tab "N" _tab "Mean" _tab "SD" _tab "Min" _tab "Max"

		di as res, ///
			_col(40) "N" ///
			_col(46) "Mean" ///
			_col(52) "SD"   ///
			_col(58) "Min"  ///
			_col(64) "Max"

		foreach v of varlist `summarize' {
				
			if "`weight'" == "" {
				qui su `v' `iff' `in'
			}
			else {
				qui su `v' `iff' `in' [`weight'=`exp']
			}
		    local l: var l `v'

	    	if "`l'"=="" local l = "UNLABELED `v'"
    		local dots = (length("`l'") > 32)*3

    		di as res, ///
    			substr("`l'",1,32) _dup(`dots') "." ///
    			_col(40) r(N) ///
    			_col(46) (round(r(mean),`fl1')) ///
    			_col(52) (round(r(sd),`fl1'))   ///
    			_col(58) (round(r(min),`fl0'))  ///
    			_col(64) (round(r(max),`fl0'))

	    	file write `fh' _n "`l'" ///
	    		_tab (r(N)) ///
	    		_tab (round(r(mean),`fl1')) ///
	    		_tab (round(r(sd),`fl1')) ///
	    		_tab (round(r(min),`fl0')) ///
	    		_tab (round(r(max),`fl0'))
			}
	}

	//--------------------------------- FREQUENCIES

	if "`frequencies'" != "" {
	
		// watered down version of tabout
		
		foreach v of varlist `frequencies' {
			if "`weight'" == "" {
				qui cap tab `v' `iff' `in', gen(`v'_) matcell(m)
			}
			else {
				qui cap tab `v' `iff' `in' [`weight'=`exp'], gen(`v'_) matcell(m)
				// mat li m
			}
		    local l: var l `v'
		    
	    	if "`l'"=="" local l = "UNLABELED `v'"
	    	local dots = (length("`l'") > 32)*3
	    	
	    	local diff ""
	    	if "`ttest'" != "" local diff "diff"
 	
	    	di as res, ///
    			substr("`l'",1,32) _dup(`dots') "." ///
    			_col(40) "N" ///
    			_col(46) "%" ///
				_col(52) "`diff'"

			file write `fh' _n "`l'" _tab "N" _tab "%"
			if "`ttest'" != "" file write `fh' _tab "diff"
			
			local N = r(N)
			qui levelsof `v' `if' `in', local(lvls)
			local i = 0
			foreach val of local lvls {
				local i=`i'+1
				local n = m[`i',1]
				local pc = 100*`n'/`N'
				local lbl: var l `v'_`i'
				local pos = strpos("`lbl'","==")
				local vlbl = substr("`lbl'",`pos'+2,.)
	
				if "`vlbl'"=="" local l = "UNLABELED `val'"	
				local dots = (length("`vlbl'") > 28)*3
	    			
				file write `fh' _n _skip(4) "`vlbl'" ///
					_tab (round(`n')) ///
					_tab (round(`pc'),`fl0')

				local diff ""
				
				if "`ttest'" != "" {
					cap qui ttest `dv' `iff' `in', by(`v'_`i')
					if r(p) < .05  local stars = "*"
					if r(p) < .01  local stars = "**"
					if r(p) < .001 local stars = "***"
					local diff = r(mu_2) - r(mu_1)
					local diff = round(`diff',`fl1')
					if _rc != 0 local diff = "NA"
					if _rc != 0 local stars = ""
					file write `fh' _tab "`diff'" "`stars'" 
				}
				
		    	di as res, _skip(4) ///
					substr("`vlbl'",1,28) _dup(`dots') "." ///
					_col(40) (round(`n')) ///
					_col(46) (round(`pc'),`fl0') ///
					_col(52) "`diff'" "`stars'"
			}
		}
	}
	
	// footer
	
	qui misstable pat `summarize' `frequencies' `iff' `in'
	noi di as res _n "N =", `r(N_complete)'
	file write `fh' _n _n "Complete observations N = `r(N_complete)'"
	if "`ttest'" != "" file write `fh' ". Two-tailed significance of t-tests: * p < .05 ** p < .01 *** p < .001"
	if "`weight'" != "" file write `fh' ". Survey weights: " "`exp'."
	file close `fh'

	} // end of by
	
	//--------------------------------- CORRELATION MATRIX

	if "`summarize'" != "" & `corr' {
	
		// watered down version of mkcorr
		
		marksample touse

		if "`if'" != "" {
			local if="`if'" + " & \`touse'"
		}
		else {
			local if "if \`touse'"
		}

		noi di as txt _n "Exporting correlation matrix to", as inp ///
			"{browse `using'_correlations.txt}" _n

		file open `fh' using `using'_correlations.txt, write `replace'
		file write `fh' _n "Table 2. Correlation matrix" _n
		file write `fh' _tab

		local n: word count `summarize'

		forvalues i=1/`n' {
			file write `fh' "(" (`i') ")" _tab
		}
		
		file write `fh' _n
		
		forvalues row=1/`n' {
			// variable number
			file write `fh' (`row') "." _skip(1)
			
			// variable label
			local v: word `row' of `summarize'
			local l: var l `v'
			
			if "`l'"=="" local l = "UNLABELED `v'"
			file write `fh' "`l'" _tab
			
			forvalues col=1/`row' {     

				local var1: word `row' of `summarize'
				local var2: word `col' of `summarize'
				
				if "`weight'" == "" | "`weight'" == "pweight" {
					qui corr(`var1' `var2') `if' `in'
					}
					else {
					qui corr(`var1' `var2') `if' `in' [`weight'=`exp']
				}
				
				if (r(rho) < 1 & `row' != `col') & (r(rho) != .) {
					local p=min(2*ttail(r(N)-2, abs(r(rho))*sqrt(r(N)-2)/sqrt(1-r(rho)^2)),1)
					local stars = ""
					if `p' < .05  local stars = "*"
					if `p' < .01  local stars = "**"
					if `p' < .001 local stars = "***"
					file write `fh' (round(r(rho),`fl1')) "`stars'" _tab 
				}
				else if (r(rho) >= 1 | `row'==`col') & (r(rho) != .) {
					file write `fh' "1" _tab
                }
				else file write `fh' "NA" _tab

			}	

			file write `fh' _n
						
		}

	// footer
	
	file write `fh' _n "Pearson pairwise correlations." ///
		"Two-tailed significance: * p < .05 ** p < .01 *** p < .001"

	if "`weight'" != "" & "`weight'" != "pweight" {
		file write `fh' ". Survey weights: " "`exp'."
	}

	file close `fh'
	
	}
	
	di as txt _n "Now look for the exported file(s) in {browse `c(pwd)'}" _n ///
		"Remember to describe all variables properly! Enjoy life."
end
