*! a regression shortcut
*! version 1.0.0 F. Briatte 27mar2013
cap pr drop rvf
program rvf
	syntax [, Mlabel(varname)]
	if "`mlabel'" != "" loc mlabel ", ms(i) mlabp(0) mlab(`mlabel')"
	di "`mlabel'"
	cap qui reg
	matrix R = r(table)
	loc Rnames: colnames R
	di as txt "Predictors: `Rnames'"
	cap drop rvf_r
	cap predict rvf_r, r
	if !_rc di "Residuals stored in rvf_r"
	cap predict rvf_rsta, rsta
	if !_rc di "Standardized residuals stored in rvf_r"
	cap predict rvf_yhat, xb
	if !_rc di "Fitted values stored in rvf_yhat"
	sc rvf_r rvf_yhat `mlabel'
end

rvf
