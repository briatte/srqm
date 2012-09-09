cap pr drop tsst
program tsst
	// tsst -- export tabbed summary statistics tables
	// method: http://www.stata.com/meeting/uk09/uk09_jann.pdf

    syntax using/ [, SUmmarize(varlist) FRequencies(varlist) replace append verbose ] 
    tempname fh
	if "`frequencies'" == "" & "`summarize'" == "" { 
    	di as err "  ERROR: No variables provided." _n
    	local exit="yes"
    }
    else if strpos("`using'",".tsv") < 2 & strpos("`using'",".txt") < 2 {
    	di as err "ERROR: File extension should be TXT or TSV." _n
    	local exit="yes"
    }
    else {
		file open `fh' using `using', write `replace' `append'
		file write `fh' _n _n "Variable" _tab "N" _tab "Mean / %" _tab "SD" _tab "Min." _tab "Max."
		di ""
    }
	if "`exit'"=="yes" {
		di as txt "  Usage:" _n
		di "    tsst using table.txt, su(v1 v2) fr(v3) replace" _n
    	di "  su() describes continuous variables (mean, sd, min, max)"
    	di "  fr() describes categorical variables (frequencies)" _n
		di "  Example:" _n
		di "    sysuse nlsw88, clear"
		di "    su age wage"
		di "    tab1 race married"
		di "    tsst using table.txt, su(age wage) fr(race married) replace" _n
		di "  tsst saves tables to tab-separated values (.tsv or .txt)."
		di "  You should be able to open them in any spreadsheet editor." _n
		exit -1
	}

	if "`summarize'" != "" {
		foreach v of varlist `summarize' {
			qui summarize `v'
		    local l: var l `v'
	    	if "`l'"=="" {
	    		di as txt "   " "`v'" as err " (no variable label)"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "   " "`v'" " (" "`l'" ")"
	    	}
	    	file write `fh' _n "`l'" _tab (r(N)) _tab (round(r(mean),.01)) _tab (round(r(sd),.01)) _tab (round(r(min),.01)) _tab (round(r(max),.01))
			}
	}
	if "`frequencies'" != "" {
		foreach v of varlist `frequencies' {
			qui su `v'
		    local l: var l `v'
			qui cap tab `v', gen(`v'_) matcell(m)
			if _rc != 0 local d = " -- dummies existed already"
	    	if "`l'"=="" {
	    		di as txt "  " "`v'" as err " (no variable label)" "`d'"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "   " "`v'" " (" "`l'" ")" "`d'"
	    	}
			local N = r(N)
			qui levelsof `v', local(lvls)
			local i = 0
			foreach val of local lvls {
				local i=`i'+1
				local pc = 100*round(m[`i',1]/`N',.001)
				qui su `v' if `v'==`val'
				local lbl: var l `v'_`i'
				local pos = strpos("`lbl'","==")
				local vlbl = substr("`lbl'",`pos'+2,.)
				if `i'==1 file write `fh' _n "`l'" ":"
				file write `fh' _n " -  " "`vlbl'" _tab (r(N)) _tab (`pc')
			}
		}
	}
	file close `fh'
	di as txt _n "   summarized to " as inp "`using'" _n
	di as txt "Open the file with any spreadsheet editor to edit further."
	di as txt "Remember that every table deserves a caption. Enjoy life."
	if "`verbose'" != "" type `using'
end
