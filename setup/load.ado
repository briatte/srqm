*! a quicker -use- command
*! version 1.0.0 F. Briatte 20apr2013
cap pr drop load
program load, rclass
	loc p data/
	// open
	cap use `*', clear
	if _rc cap use `p'`*', clear
	if _rc {
		di as err "File not found."
		exit 601
	}
	// info
	loc d : data l
	if "`d'" == "" loc d "`c(filename)'"
	loc n = _N
	di as txt "`d'", "(N = `n')"
	notes _dta
	// save
	//if substr("`c(filename)'", 1, length("`p'")) != "`p'" saveold `p'`c(filename)'
end
