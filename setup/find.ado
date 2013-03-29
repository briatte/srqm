*! a more useful -lookfor- command
*! version 1.0.0 F. Briatte 27mar2013
cap pr drop find
program find, rclass
	qui lookfor `*'
	if "`r(varlist)'" != "" codebook `r(varlist)', c
end
