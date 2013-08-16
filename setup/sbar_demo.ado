*! a demo of the -sbar- command
cap pr drop sbar_demo
program sbar_demo

	gr drop _all

	cap which scheme-burd.scheme
	if _rc ssc install scheme-burd
	set scheme burd
	
	webuse nhanes2, clear
	gen bmi_g:bmi_g = irecode(bmi, 18.5, 25, 30)
	la def bmi_g 0 "Underweight" 1 "Normal" 2 "Overweight" 3 "Obese"

	* unstacked
	
	sbar bmi_g    ,  ymax(50)          name(sbar1           , replace)
	sbar bmi_g sex,  ymax(50)          name(sbar2           , replace)
	sbar bmi_g sex,  ymax(50) asc red  name(sbar2_gradient  , replace)
	sbar bmi_g race, asc red stack     name(sbar2_stacked   , replace)
	
end

// work in progress
