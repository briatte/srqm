*! stab: simple tables of summary statistics
*! type stab_demo for an example with NHANES data
*! 0.1 F. Briatte 3jun2013

cap pr drop stab
pr stab
	syntax [using/] [if] [in] [, Mean(varlist) Prop(varlist) replace]

	// stab is a wrapper for the -estout- package by Ben Jann

	qui which estout
	if _rc == 111 ssc inst estout, replace
	
	

	// it saves simple summary statistics tables in plain text

	loc fmt "noobs nonum nomti noli lab"
	loc dsu c("mean(fmt(1)) sd(fmt(1)) min(fmt(0)) max(fmt(0))")
	loc dfr c("pct(fmt(0))")
	loc out `using'
	
	tempname fh
	file open `fh' using `out', write `replace'
	file write `fh' "Descriptive statistics" _n
	file close `fh'

	// continuous variables passed to summarize() get a mean, sd and min-max
	
	qui estpost summarize `mean' `if' `in'
	esttab, `dsu' `fmt' collabels(, lhs("Variable"))
	qui esttab using `out', tab append `dsu' `fmt' collabels(, lhs("Variable"))

	// categorical variables passed to frequencies() get percentages
	
	if "`prop'" != "" {
		foreach v of varlist `prop' {
			local l: var l `v'
			qui estpost tabulate `v' `if' `in', nototal
			esttab, `dfr' `fmt' collabels("%", lhs("`l'"))
			qui esttab using `out', tab append `dfr' `fmt' collabels("%", lhs("`l'"))
		}
	}

	qui misstable pat `mean' `prop' `if' `in'
	loc n `r(N_complete)'
	loc m `r(N_incomplete)'
	if `m' > 0 loc m " (excluding `r(N_incomplete)' incomplete observations)"
	
	file open `fh' using `out', write append
	file write `fh' "N = `n'`m'"
	file close `fh'

	di as txt _n "N = `n'`m'" _n "File: {browse `out'}"
end

cap pr drop stab_demo
pr stab_demo

	webuse nhanes2, clear
	la var sex "Gender"
	la var race "Race"
	stab using stab_demo.txt, m(age height weight bmi) p(sex race) replace
end

// enjoy
