* What: Example do-file for Assignment No. 1* Who:  François Briatte and Ivaylo Petev* When: 2012-02-23* Topic:  Social Determinants of Obesity in the USA* Data:   National Health Interview Survey* Sample: N = 24,291 for the 2009 survey year* =========* = SETUP =* =========* Data.use "Datasets/nhis2009.dta", clear* Log (uncomment if needed).
* cap log using "Replication/BriattePetev_1.log", name(draft1) replace* Subsetting to data from most recent year.drop if year!=2009* Subsetting to variables used in the analysis.keep serial psu strata perweight age sex raceb educrec1 ///
	health height weight uninsured vig10fwk yrsinus
* Set NHIS individual weights (used only for illustrative purposes).
svyset psu [pw=perweight], strata(strata) vce(linearized) singleunit(missing)


* ================* = DESCRIPTIONS =
* ================* List.codebook, c* DV: Body Mass Index (BMI)* -------------------------
* Creating the BMI variable.gen bmi = weight*703/height^2la var bmi "Body Mass Index"* Recoding into simpler categories.gen bmi7 = .la var bmi7 "Body Mass Index (categories)"replace bmi7 = 1 if bmi < 16.5replace bmi7 = 2 if bmi >= 16.5 & bmi < 18.5replace bmi7 = 3 if bmi >= 18.5 & bmi < 25replace bmi7 = 4 if bmi >= 25 & bmi < 30replace bmi7 = 5 if bmi >= 30 & bmi < 35replace bmi7 = 6 if bmi >= 35 & bmi < 40replace bmi7 = 7 if bmi >= 40la def bmi7 ///
	1 "Severely underweight" 2 "Underweight" 3 "Normal" ///
	4 "Overweight" 5 "Obese" 6 "Severely obese" 7 "Morbidly obese"la val bmi7 bmi7* Breakdown of mean BMI by categories.d bmi bmi7tab bmi7, summ(bmi)* Reminder:su bmi, d   // use 'su' for a continuous measurefre bmi7    // use 'fre' for a categorical measure/recoding* Inspecting DV for normality.hist bmi, normal name(bmi_hist, replace)* Transformations (use gladder for the graphical checks).
ladder bmi
* Log-BMI transformation.gen logbmi=ln(bmi)
la var logbmi "log(BMI)"

* Inspect improvement in normality.
tabstat bmi logbmi, s(skewness kurtosis) c(s)* IV: Age
* -------
su age, d

* Recode to 4 age groups.
recode age ///
	(18/44=1 "18-44") ///
	(45/64=2 "45-64") ///
	(65/74=3 "65-74") ///
	(75/max=4 "75+"), gen(age4)
la var age4 "Age groups"

* Exploration:
tab age4, summ(bmi) // mean BMI in each age group
bys age4: ci bmi    // confidence bands

* IV: Gender* ----------

fre sex

* Recode as dummy.recode sex (1=0 "Male") (2=1 "Female"), gen(female)
la var female "Gender (1=female)"

* Exploration:
tab female, summ(bmi) // mean BMI in each gender group
bys female: ci bmi    // confidence bands

* IV: Educational attainment* --------------------------

fre educrec1

* Recode to 3 groups.recode educrec1 ///
	(13=1 "Grade 12") ///
	(14=2 "Undergrad.") ///
	(15/16=3 "Postgrad."), gen(edu3)la var edu3 "Educational attainment"* Exploration:
tab edu3, summ(bmi) // mean BMI at each education level
bys edu3: ci bmi    // confidence bands
* IV: Health status
* -----------------
fre health

* Exploration:
tab health, summ(bmi) // mean BMI at each health level
bys health: ci bmi    // confidence bands
* Plotting BMI and age for excellent vs. poor health:
sc bmi age if health==1, mc(dkgreen) || sc bmi age if health==5, mc(dkorange) ///	legend(lab(1 "Excellent health") lab(2 "Poor health")) ///
	name(health, replace)

* IV: Physical exercise* ---------------------

fre vig10fwk
* Recode.
recode vig10fwk (94/95=0 "Little to no exercise") (96/99=.), gen(phy)

tab phy, m plot // the US has a pretty sedentary population
                // also, this is a really ugly distribution with huge issues,
                // so we will add some jitter to the scatterplot to help the
                // plot look more informative (type 'h sc' for details)* Visualization.
sc bmi phy if phy > 0, jitter(3) name(bmi_phy, replace)

* Visualization as boxplots.
gr box phy, noout over(female) asyvars over(age4) medl(lc(red)) ///
	by(health, total note("")) note("") yti("Mean physical activity") ///	name(phy_box, replace) // note usage of the 'total' option, among others
* IV: Race
* --------

ren raceb racefre race* Exploration:
tab health, summ(bmi) // mean BMI at each health level
bys health: ci bmi    // confidence bands
* Plotting BMI groups:spineplot bmi7 race, scale(.7) name(bmi7, replace)* Slightly more code-consuming visualization, with stacked bars.
tab race, gen(race_)
gr bar race_*, stack over(bmi7) scale(.7) ///
	legend(row(1) lab(1 "NH White") lab(2 "NH Black") lab(3 "Hispanic") lab(4 "Asian")) ///
	name(bmi7_race, replace)

* IV: Health insurance* --------------------

fre uninsured

* Recode to dummy.recode uninsured (1=0 "Not covered") (2=1 "Covered") (else=.), gen(hins)
la var hins "Health insurance (1=covered)."

* Exploration:
tab hins, summ(bmi) // mean BMI at each health level
bys hins: ci bmi    // confidence bands
* Crosstabulations:
tab hins race          // raw frequencies
tab hins race, cell    // cell percentages
tab hins race, col nof // column percntages

* Note: we will cover crosstabulations, a.k.a contingency tables, in more depth
* next week. Simply note, for now, that the 'tab' command can also be used to 
* crosstabulate two variables. The variables should be categorical, i.e. low-dimensional, otherwise your crosstab
* will have far too many rows or columns or both.

* Plotting:
spineplot hins race, scale(.7) name(hins, replace)


* ======================
* = SUMMARY STATISTICS =
* ======================


* Reminder about building summary statistics tables:
*
* - Remember to discriminate between continuous and categorical variables.
*
*   It rarely makes sense to summarize the mean of a variable that has a low
*   number of values. Use five-number summaries (n, mean, sd, min, max) only
*   to describe continuous variables, and use frequencies to describe variables
*   that hold a low number of categories or groups.
*
* - Remember to report sensible values that can be interpreted.
*
*   In the example below, BMI is reported untransformed for legibility purposes.
*   We will use the log-transformed version of the variable for linear modelling
*   later on, but in the summary stats table, we want the reader to understand
*   what s/he reads in the mean, sd, min and max columns.
*
* - Pick your favourite export method: tabout or tsst.
*
*   This course offers a built-in command, tsst, that produces a simple summary
*   stats table in just one command. An alternative is to use the tabout package
*   after installing it from the SSC servers. Please refer to the course and
*   package documentation to see examples of both commands in use.


* Method (1): tabout
* ------------------

* Install package (uncomment if needed).
* ssc install tabout, replace

* Continuous variables:
tabstatout bmi age, tf(a1_stats1) ///
	s(n mean sd min max) c(s) f(%9.2fc) replace

* Categorical variables:
tabout female edu3 health phy race hins using a1_stats2.csv, ///
	replace c(freq col) oneway ptot(none) f(2) style(tab)* Note: CSV files often require that you import them rather than just open them.
* In Microsoft Excel, use 'File > Import' and follow the Excel import procedure.

* Method (2): tsst
* ----------------

tsst using a1_stats.txt, su(bmi age) fre(female edu3 health phy race hins) replace

* Note: the tsst command is part of the course setup and will not run outside
* of the SRQM folder. Make sure that you set it as the working directory.


* =======* = END =* =======


* Clean all graphs from memory.
* gr drop _all

* Wipe the modified data.
* clear

* Close log (if opened).
cap log close draft1

* We are done. Have a nice day :)* exit
* ==========
* = BONUS! =
* ==========


* A few things about confidence intervals
* ---------------------------------------

* Remember that your analysis is based on the assumption that the data follow a
* somewhat normal distribution. This constraint applies to continuous variables,
* for which it is relevant to calculate the mean. The confidence interval echoes
* the standard error of the mean (SEM), itself a reflection of sample size.

* Average BMI in full sample with a 95% CI.
ci bmi

* Average BMI in full sample with a 99% CI (more confidence, less precision).
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


* Example
* -------

* Confidence bands can become useful to detect spurious relationships. See how 
* the number of years spent in the U.S. seems to affect the BMI of respondents:
fre yrsinus
replace yrsinus=. if yrsinus==0

* We know from previous analysis that BMI varies by gender and ethnicity.
* We now look for the effect of the number of years spent in the U.S. within
* each gender and ethnic categories.
gr dot bmi, over(female) over(yrsinus) over(race) ///
	yti("Mean BMI") asyvars scale(.7) name(yrsinus, replace)

* The average BMI of Blacks who spent less than one year in the U.S. shows
* an outstanding difference for males and females, but this category holds
* too few observations (if any) to consider the difference.
bys female: ci bmi if race==2 & yrsinus==1

* Identically, the seemingly clean pattern among male and female Asians is
* calculated on a low number of observations and requires verification of
* the confidence intervals. The pattern appears to be rather robust.
bys yrsinus: ci bmi if race==4


* A few things about confidence intervals with proportions
* --------------------------------------------------------

* Confidence bands for proportions follow a different method of calculation.
* Basically, categorical data are just dummies for a bunch of categories, so the
* distribution of binary data can hardly follow a normal distribution. Instead,
* you have to use the binomial distribution to compute CIs on dummy variables.
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


* Visualizing confidence bands
* ----------------------------

* The following creates a dataset based on the summary statistics for the BMI
* variable. The advantage of showing this is that it shows the mathematical
* elements at play in the calculation of confidence intervals.
collapse (mean) mbmi=bmi (sd) sdbmi=bmi (count) nbmi=bmi, by(race edu3)

* The "invttail(nbmi,0.025)" function calculates the z-score required in the
* calculation of a 95% CI, based on the t distribution. The value of 0.025
* applies to each tail of the distribution and hence leads to a 0.05 = 95%
* confidence interval. The z value approaches 1.96 for that confidence level.
gen bmi_hi = mbmi + invttail(nbmi,0.025)*sdbmi/sqrt(nbmi)
gen bmi_lo = mbmi - invttail(nbmi,0.025)*sdbmi/sqrt(nbmi)

* Dirty graphic hack here, taken from the relevant UCLA Stata FAQ entry.
* The 5 and 10 values leave a gap of 1 between each of the four categories
* of raceb, which allows racex to hold both race and exercise values.
gen racex = race if edu3 == 1
replace racex = race+5 if edu3 == 2
replace racex = race+10 if edu3 == 3
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
	row(1)) xlabel( 2.5 "Grade 12" 7.5 "Undergrad." 12.5 "Postgrad.", noticks) ///
	xtitle("Educational attainment") ytitle("Mean BMI (95% CI)") ///
	name(bmi_edu3, replace)

// END OF FILE (for real this time, thanks for following)
