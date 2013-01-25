// deprecated

cap pr drop tsst
program tsst
	syntax [using/] [if] [in] [aweight fweight pweight/] [, SUmmarize(varlist) FRequencies(varlist) replace verbose f(int 1)] 
	di as err "deprecated, sending to -stab- command instead"
	stab using `using' `if' `in' [`aweight' `fweight'], su(`summarize') fr(`frequencies') `replace' f(`f')
end
