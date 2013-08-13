*! SRQM utilities: rewrites of built-in Stata commands, for speed and profit
*! version 1.2 F. Briatte 2jun2013

*! find: a more useful -lookfor- command
cap pr drop find
program find, rclass
	qui lookfor `*'
	loc q `r(varlist)'
	if "`q'" != "" codebook `q', c
	return local varlist = "`q'"
end

*! load: a more useful -use- command
cap pr drop load
program load
	syntax anything(everything) [if] [in]
	loc p data/
	noi di as err "`*'"
	// open from working directory
	cap use `*', clear
	// if fails, open from data/ folder
	if _rc cap use `p'`*', clear
	if _rc exit _rc
	// show info (obs. and notes)
	loc d : data l
	if "`d'" == "" loc d "`c(filename)'"
	loc n = _N
	di as txt "`d'", "(N = `n')"
	notes _dta
end

// enjoy
