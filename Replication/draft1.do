* What: Example do-file for Assignment No. 1* Who:  François Briatte and Ivaylo Petev* When: 2012-02-23* DATASET* Topic: Social Determinants of Obesity in the USA* Survey: National Health Interview Series (2009)* Sample: N = 24,291 for the 2009 survey year* COMMANDS

* Install first if not done so yet:
* ssc install fre
* ssc install spineplot
* ssc install tabout
* SETUPuse "Datasets/nhis2009.dta", clear//cap log using "Replication/BriattePetev_1.log", name(draft1) replace* Subsetting to data from most recent year.drop if year!=2009* Subsetting to variables used in the analysis.keep serial psu strata perweight age sex raceb educrec1 ///
	health height weight uninsured vig10fwk yrsinus
* Set NHIS individual weights (used only for illustrative purposes).
svyset psu [pw=perweight], strata(strata) vce(linearized) singleunit(missing)
* DESCRIPTIONS* (a) DV: BMI* Creating the BMI variablegen bmi = weight*703/height^2la var bmi "Body Mass Index"* Recoding into simpler categories.gen bmi7 = .la var bmi7 "Body Mass Index (categories)"replace bmi7 = 1 if bmi < 16.5replace bmi7 = 2 if bmi >= 16.5 & bmi < 18.5replace bmi7 = 3 if bmi >= 18.5 & bmi < 25replace bmi7 = 4 if bmi >= 25 & bmi < 30replace bmi7 = 5 if bmi >= 30 & bmi < 35replace bmi7 = 6 if bmi >= 35 & bmi < 40replace bmi7 = 7 if bmi >= 40la def bmi7 ///
	1 "Severely underweight" 2 "Underweight" 3 "Normal" ///
	4 "Overweight" 5 "Obese" 6 "Severely obese" 7 "Morbidly obese"la val bmi7 bmi7d bmi bmi7* Summary statistics.su bmi, d // use "su" for a continuous measurefre bmi7 // use "fre" for a categorical measure/recoding* Inspecting DV for normality.hist bmi, normal name(bmi_hist, replace)* Transformations.
ladder bmi // ... or use gladder for a graphical checkgen logbmi=ln(bmi)
la var logbmi "log(BMI)"

* Inspect improvement in normality.
tabstat bmi logbmi, s(skewness kurtosis) c(s)* (b) IVs* Renaming some IVsren vig10fwk exerciseren raceb raceren educrec1 educd bmi logbmi sex age educ health exercise race uninsured

* Summary statistics.
* Note: CSV files often require that you import them rather than just open them.
* In Microsoft Excel, for example, use "File : Import" and follow the guide.

tabstatout bmi age, tf(a1_stats1) ///
	s(n mean sd min max) c(s) f(%9.2fc) replace // continuous data

tabout sex educ health exercise race uninsured using a2_stats2.csv, ///
	replace c(freq col) oneway ptot(none) f(2) style(tab) // categorical data* (i) Agesu age, d
* (ii) Genderfre sex

* Recode as dummy.recode sex (1=0 "Male") (2=1 "Female"), gen(female)

* Confidence bands for each gender group.
bysort female: ci bmi
* (iii) Educational attainmentfre educrecode educ (1=1 "None") (2/12=2 "High school, below grade 12") ///
	(13=3 "High school, grade 12") (14=4 "College, undergraduate") ///
	(15/16=5 "College, postgraduate") (97/99=.), gen(educ2)la var educ2 "Education (recoded)"fre educ2* (iv) health statusfre health

* Summarize BMI by health status.
tab health, summ(bmi)
* Plotting BMI and age for excellent vs. poor health:
sc bmi age if health==1, mc(dkgreen) || sc bmi age if health==5, mc(dkorange) ///	legend(lab(1 "Excellent health") lab(2 "Poor health")) name(health, replace)
* (v) physical exercisefre exerciserecode exercise ///
	(1 94 95=0 "Little to none") ///
	(2/21=1 "Less than 30 minutes/week") ///
	(22/28=2 "More than 30 minutes/week") ///
	(96/99=.), ///
	gen(exercise3)
la var exercise3 "Physical exercise"

spineplot bmi7 exercise3, scale(.7) // this is a very sedentary population* (vi) racefre race* Plotting BMI groups:spineplot bmi7 race, scale(.7)* (vii) Insurancefre uninsuredreplace uninsured=. if uninsured==9
* Crosstabulation of race and coverage.
* (covered in depth next week)
tab uninsured race // raw frequencies
tab uninsured race, cell // cell percentages
tab uninsured race, col nof // column percntages

* Plotting:
gr hbox age, over(race) asyvars over(uninsured)
spineplot uninsured race, scale(.7) // more informative in my opinion

* Confidence bands for each health insurance coverage.
bysort uninsured: ci bmi
* END* We are done. Have a nice day.cap log close draft1

* BONUS!

* A few things about confidence intervals. Remember that all this is based on
* the assumption that the data follow something like a normal distribution. It
* applies to continuous variables, for which it is relevant to calculate the 
* mean. The confidence interval reflects the standard error of the mean (SEM),
* itself a reflection of sample size.

* Average BMI for the full sample with a 95% CI.
ci bmi

* Average BMI for the full sample with a 99% CI (more confidence, less precision).
ci bmi, level(99)

* The confidence intervals for the full sample show a high precision,
* both at the 95% (alpha = 0.05) and 99% (alpha = 0.01) levels. This
* is due to the high number of observations provided for the BMI variable.

* If we start computing the average BMI for subsamples of the population,
* i.e. for restricted categories of the population, the total number of
* observations will drop and the confidence interval will widen.

* Average BMI for N=10, 100, 1000 and 10,000 with a 95% CI.
ci bmi in 1/10
ci bmi in 1/100
ci bmi in 1/1000
ci bmi in 1/10000

* Confidence bands can become useful to detect spurious relationships. See, for
* instance, how the number of years spent in the U.S. seems to affect the BMI
* of respondents:
fre yrsinus
replace yrsinus=. if yrsinus==0

* We know from previous analysis that BMI varies by gender and ethnicity.
* We now look for the effect of the number of years spent in the U.S. within
* each gender and ethnic categories.
graph dot bmi, over(female) over(yrsinus) over(race) asyvars scale(.7)

* The average BMI of Blacks who spent less than one year in the U.S. shows
* an outstanding difference for males and females, but this category holds
* so little observations that the difference should not be considered.
bysort female: ci bmi if race==2 & yrsinus==1

* Identically, the seemingly clean pattern among male and female Asians is
* calculated on a low number of observations and requires verification of
* the confidence intervals. The pattern appears to be rather robust.
bysort yrsinus: ci bmi if race==4

* EXTRA BONUS!

* A few things about confidence intervals with proportions, for which confidence
* bands follow a different method of calculation. Basically, categorical data is
* just dummies for a bunch of categories, and the distribution of binary data
* can hardly be normal. The binomial distributions applies instead.
ci female, binomial

* Categorical variables, which can be described through proportions, also
* come with confidence intervals that reflect the range of values that each
* category might take in the true population. The proportions of ethnic groups
* in the U.S., for instance, are somehwere in these intervals:
prop race

* Actually, if you want to be completely correct, you need to weight the data
* with the svy: prefix to use the weight settings specified earlier. This will
* have a tremendous effect on your data in this case, shifting the proportion
* of White respondents from roughly 60% to roughly 70% of all U.S. adults, the
* reason being that other racial-ethnic groups are oversampled in NHIS data.
svy: prop race

* Identically to continuous variables, confidence intervals for categorical
* data will increase when the total number of observations decreases. The
* 95% CI for ethnicity on morbidly obese respondents illustrates that issue.
prop race if bmi > 40

* EXTRA BONUS!

* More complex code to draw confidence bands.

* The following creates a dataset based on the summary statistics for the BMI
* variable. The advantage of showing this is that it shows the mathematical
* elements at play in the calculation of confidence intervals.
collapse (mean) mbmi=bmi (sd) sdbmi=bmi (count) nbmi=bmi, by(race exercise3)

* The "invttail(nbmi,0.025)" function calculates the z-score required in the
* calculation of a 95% CI, based on the t distribution. The value of 0.025
* applies to each tail of the distribution and hence leads to a 0.05 = 95%
* confidence interval. The z value approaches 1.96 for that confidence level.
gen bmi_hi = mbmi + invttail(nbmi,0.025)*sdbmi/sqrt(nbmi)
gen bmi_lo = mbmi - invttail(nbmi,0.025)*sdbmi/sqrt(nbmi)

* Dirty graphic hack here, taken from the relevant UCLA Stata FAQ entry.
* The 5 and 10 values leave a gap of 1 between each of the four categories
* of raceb, which allows racex to hold both race and exercise values.
gen racex = race if exercise3 == 0
replace racex = race+5 if exercise3 == 1
replace racex = race+10 if exercise3 == 2
sort racex

* The graph, finally. The labelling of the x-axis is also hacked by using
* the geometric distance for each cluster of racex bars. The reading of the
* graph shows the confidence issue that exists with the Asian subsample.
graph twoway ///
	(bar mbmi racex if race==1) ///
	(bar mbmi racex if race==2) ///
	(bar mbmi racex if race==3) ///
	(bar mbmi racex if race==4) ///
	(rcap bmi_hi bmi_lo racex), ///
	legend(order(1 "White" 2 "Black" 3 "Hispanic" 4 "Asian") ///
	row(1)) xlabel( 2.5 "Low" 7.5 "Middle" 12.5 "High", noticks) ///
	xtitle("Physical exercise") ytitle("Average Body Mass Index") ///
	name(bmi_exercise95ci, replace)

// end of file (for real this time)
