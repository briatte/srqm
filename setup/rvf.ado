*! a regression shortcut
*! version 1.0.0 F. Briatte 27mar2013
cap pr drop rvf
program rvf
	syntax [, RSTA Mlabel(varname) *]
	loc r "r"
	if "`rsta'" != "" loc r "rsta"
	if "`mlabel'" != "" loc mlabel ", ms(i) mlabp(0) mlab(`mlabel')"
	cap qui reg
	matrix R = r(table)
	loc Rnames: colnames R
	di as inp "Predictors:" _n as txt "`Rnames'"
	cap drop rvf_r
	cap predict rvf_r, r
	if !_rc di "Residuals stored in rvf_r"
	cap predict rvf_rsta, rsta
	if !_rc di "Standardized residuals stored in rvf_r"
	cap predict rvf_yhat, xb
	if !_rc di "Fitted values stored in rvf_yhat"
	di as inp "Plot:" _n as txt "sc rvf_`r' rvf_yhat `mlabel'"
	sc rvf_`r' rvf_yhat `mlabel' "`*'"
end
