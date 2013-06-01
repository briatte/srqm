*! SRQM utilities: rewrites of built-in Stata commands, for speed and profit
*! version 1.1 F. Briatte 1jun2013

*! find: a more useful -lookfor- command
cap pr drop find
program find, rclass
	qui lookfor `*'
	if "`r(varlist)'" != "" codebook `r(varlist)', c
end

*! load: a more useful -use- command
cap pr drop load
program load, rclass
	loc p data/
	// open from working directory
	cap use `*', clear
	// if fails, open from data/ folder
	if _rc cap use `p'`*', clear
	if _rc {
		di as err "File not found."
		exit 601
	}
	// show info (obs. and notes)
	loc d : data l
	if "`d'" == "" loc d "`c(filename)'"
	loc n = _N
	di as txt "`d'", "(N = `n')"
	notes _dta
	// save
	//if substr("`c(filename)'", 1, length("`p'")) != "`p'" saveold `p'`c(filename)'
end

// enjoy
