cap pr drop tsst
program tsst
	// export tabbed summary statistics tables

    syntax [using/] [if] [in] [aweight fweight pweight/] [, SUmmarize(varlist) FRequencies(varlist) replace verbose f(int 1)] 
    tempname fh
	local fl = 10^(-`f')

	if "`using'"=="" {
		di as txt "The 'srqm table' command is part of the SRQM Teaching Pack."
		di "It is meant to help you export a summary statistics table." _n
		di "Syntax:" _n
		di "    tsst using table.txt, su(v1 v2) fr(v3) replace" _n
    	di "su() describes continuous variables (mean, sd, min, max)."
    	di "fr() describes categorical variables by their frequencies." _n
		di "The table is saved as tab-separated values (.tsv or .txt)."
		di "You should be able to open it in any spreadsheet editor." _n
		di "Run {stata tsst using example} to view a simple example."
		di "Run {stata tsst using options} to get a list of options."
    	exit 0
    }
    
	if "`using'"=="example" {
		di as txt "Example:" _n
		di "    sysuse nlsw88, clear"
		di "    su age wage"
		di "    tab1 race married"
		di "    tsst using table.txt, su(age wage) fr(race married) replace"
    	exit 0
    }
    else if "`using'"=="options" {
		di as txt "Options:" _n
		di "    - add " as inp "f(n)" as txt " at the end of the command to display n decimals of precision"
		di "    - add " as inp "replace" as txt " at the end of the command to overwrite the export file"
		di "    - add " as inp "verbose" as txt " at the end of the command to print its output" _n
		di "Survey weights [aw,fw,pw] are also supported."
		exit 0
    }
    else if strpos("`using'",".tsv") < 2 & strpos("`using'",".txt") < 2 {
    	di as txt "This command requires that you specify a .txt or .tsv file for export." _n
    	local exit="yes"
    }
    else if "`frequencies'" == "" & "`summarize'" == "" { 
    	di as txt "This command requires that you provide some variables to summarize." _n
    	local exit="yes"
    }
    else {
		file open `fh' using `using', write `replace' `append'
		file write `fh' _n _n "Variable" _tab "N" _tab "Mean / %" _tab "SD" _tab "Min." _tab "Max."
    }
    
	if "`exit'"=="yes" {
		di as txt "Run {stata tsst} with no options for documentation on the command syntax."
		exit -1
	}
    else {
		di as txt "Summarizing:" _n
	}
	
	if "`summarize'" != "" {
		foreach v of varlist `summarize' {
			if "`weight'" == "" {
				qui su `v' `if' `in'
			}
			else {
				qui su `v' `if' `in' [`weight'=`exp']
			}
		    local l: var l `v'
	    	if "`l'"=="" {
	    		di as txt "   " "`v'" as err " (no variable label)"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "   " "`v'" " (" "`l'" ")"
	    	}
	    	file write `fh' _n "`l'" _tab (r(N)) _tab (round(r(mean),`fl')) _tab (round(r(sd),`fl')) _tab (round(r(min),`fl')) _tab (round(r(max),`fl'))
			}
	}

	if "`frequencies'" != "" {
		foreach v of varlist `frequencies' {
			if "`weight'" == "" {
				qui cap tab `v' `if' `in', gen(`v'_) matcell(m)
			}
			else {
				qui cap tab `v' `if' `in' [`weight'=`exp'], gen(`v'_) matcell(m)
				mat li m
			}
			if _rc != 0 local d = "-- dummies existed already"
		    local l: var l `v'
	    	if "`l'"=="" {
	    		di as txt "  " "`v'" as err " (no variable label)" "`d'"
	    		local l="("+"`v'"+")"
	    	}
	    	else {
	    		di as txt "   " "`v'" " (" "`l'" ") " "`d'"
	    	}
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
				if `i'==1 file write `fh' _n "`l'" ":"
				file write `fh' _n " -  " "`vlbl'" _tab (round(`n')) _tab (round(`pc'),`fl')
			}
		}
	}
	qui misstable pat `summarize' `frequencies' `if' `in'
	file write `fh' _n "Complete observations: " _tab "`r(N_complete)'"
	if "`weight'" != "" file write `fh' _n "Survey weights: " "`exp'" "."
	file close `fh'
	local pwd = c(pwd)
	di as txt _n "The table " as inp "`using'" as txt " was saved to your working directory:"
	di as res "{browse `pwd'}" _n
	di as txt "Open the file with any spreadsheet editor to edit further."
	di as txt "Remember that every table deserves a caption. Enjoy life."
	if "`verbose'" != "" type `using'
end
