*! SRQM utilities: rewrites of built-in Stata commands, for speed and profit

*! find: a more useful -lookfor- command
*! version 1.2 F. Briatte 2jun2013
cap pr drop find
program find, rclass
	qui lookfor `*'
	loc q `r(varlist)'
	if "`q'" != "" codebook `q', c
	return local varlist = "`q'"
end

*! load: a more useful -use- command
*! version 1.2 F. Briatte 2jun2013
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

*! science: a Stata program by Rudolf Carnap, with assistance from the Vienna Circle
*! this program has been abandoned

cap pr drop science
program science
	di as txt _n "  Science is a system of statements"
	di as txt "  based on direct experience"
	di as txt "  and controlled by experimental verification."
	di as txt _n "  -- Rudolf Carnap" _n
end

// enjoy
