*! a shortcut to residuals-versus-fitted plots
*! type rvf_demo1 for an example with NHANES data
*! type rvf_demo2 for an example with World Bank data
*! version 0.0.2 F. Briatte 1jun2013

cap pr drop rvf
program rvf
	syntax [, RSTA Mlabel(varname)]
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
	sc rvf_`r' rvf_yhat `mlabel'
end

cap pr drop rvf_demo1
program rvf_demo1

	gr drop _all

	cap which scheme-burd.scheme
	if _rc ssc install scheme-burd
	set scheme burd
	
	webuse nhanes2, clear
	gen bmi_g:bmi_g = irecode(bmi, 18.5, 25, 30)
	la def bmi_g 0 "Underweight" 1 "Normal" 2 "Overweight" 3 "Obese"
	
	reg bmi age female i.race

	rvf
end

cap pr drop rvf_demo2
program rvf_demo2

	gr drop _all

	cap which scheme-burd.scheme
	if _rc ssc install scheme-burd
	set scheme burd
	
	webuse lifeexp, clear
	reg lexp safewater

	rvf, m(country)
end

// work in progress
