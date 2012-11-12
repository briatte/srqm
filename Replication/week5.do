* What: SRQM Session 5
* Who:  François Briatte and Ivaylo Petev
* When: 2012-11-04


/* Introductory notes:

 - This is the stage where you submit your first draft. Please make sure that
   your do-file is named like 'Briatte_Petev_1.do' (use your own family names
   in alphabetical order). Name your paper the same way, and print it to PDF.
 
 - Your first do-file must imitate the course do-files: start with a header,
   then open the data, rename variables to legible names, recode when needed,
   assess DV normality and try out a few interactions with graphs and confidence
   intervals over categories. Describe interesting results in your paper.
 
 - Use the -stab- command at the end of this do-file to export summary stats
   to a simple table. The result will be a plain text file that you can copy
   and paste into Google Documents, or import into any other text editor.

 - Your first draft must inform the reader about simple things: What is your
   research question? Where does your data come from, how large is the sample
   and how was it designed? What choice of variables have you made, and with
   what theory to support it? Here's an example:
   
 * TOPIC:  Social Determinants of Adult Obesity in the United States

    * DV: Body Mass Index (BMI)
    * IV: age, sex, education, health status, physical exercise, race, exercise

 * DATA:   National Health Interview Survey 2009

    * Sample size:   N = 24,291 observations
    * Sample design: state-level stratified random sample

*/



* =========
* = SETUP =
* =========


* Required commands.
foreach p in fre spineplot {
	cap which `p'
	if _rc==111 cap noi ssc install `p' // install from online if missing
}

* Log results.
cap log using "week5.log", replace



* ========
* = DATA =
* ========


* Data.
use "Datasets/nhis2009.dta", clear

* Subsetting to data from most recent year.
drop if year!=2009

* Subsetting to variables used in the analysis.
keep serial psu strata perweight age sex raceb educrec1 ///
	health height weight uninsured vig10fwk yrsinus

* Patterns of missing data.
misstable pat *

* Set NHIS individual weights (used only for illustrative purposes).
svyset psu [pw=perweight], strata(strata) vce(linearized) singleunit(missing)


* ================
* = DESCRIPTIONS =
* ================


* List.
codebook, c


* DV: Body Mass Index (BMI)
* -------------------------

* Creating the BMI variable.
gen bmi = weight*703/height^2
la var bmi "Body Mass Index"

* Recoding into simpler categories.
gen bmi7 = .
la var bmi7 "Body Mass Index (categories)"
replace bmi7 = 1 if bmi < 16.5
replace bmi7 = 2 if bmi >= 16.5 & bmi < 18.5
replace bmi7 = 3 if bmi >= 18.5 & bmi < 25
replace bmi7 = 4 if bmi >= 25 & bmi < 30
replace bmi7 = 5 if bmi >= 30 & bmi < 35
replace bmi7 = 6 if bmi >= 35 & bmi < 40
replace bmi7 = 7 if bmi >= 40
la def bmi7 ///
	1 "Severely underweight" 2 "Underweight" 3 "Normal" ///
	4 "Overweight" 5 "Obese" 6 "Severely obese" 7 "Morbidly obese"
la val bmi7 bmi7

* Breakdown of mean BMI by categories.
d bmi bmi7
tab bmi7, summ(bmi)

* Inspecting DV for normality.
hist bmi, normal name(bmi_hist, replace)

* Transformations (use gladder for the graphical checks).
ladder bmi

* Log-BMI transformation.
gen logbmi=ln(bmi)
la var logbmi "log(BMI)"

* Inspect improvement in normality.
tabstat bmi logbmi, s(skewness kurtosis) c(s)


* IV: Age
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


* IV: Gender
* ----------

fre sex

* Recode as dummy.
recode sex (1=0 "Male") (2=1 "Female"), gen(female)
la var female "Gender (1=female)"

* Exploration:
tab female, summ(bmi) // mean BMI in each gender group
bys female: ci bmi    // confidence bands


* IV: Educational attainment
* --------------------------

fre educrec1

* Recode to 3 groups.
recode educrec1 ///
	(13=1 "Grade 12") ///
	(14=2 "Undergrad.") ///
	(15/16=3 "Postgrad."), gen(edu3)
la var edu3 "Educational attainment"

* Exploration:
tab edu3, summ(bmi) // mean BMI at each education level
bys edu3: ci bmi    // confidence bands


* IV: Health status
* -----------------

fre health

* Exploration:
tab health, summ(bmi) // mean BMI at each health level
bys health: ci bmi    // confidence bands

* Plotting BMI and age for excellent vs. poor health:
sc bmi age if health==1 || sc bmi age if health==5, ///
	legend(lab(1 "Excellent health") lab(2 "Poor health")) ///
	name(health, replace)


* IV: Physical exercise
* ---------------------

fre vig10fwk

* Recode.
recode vig10fwk (94/95=0 "Little to no exercise") (96/99=.), gen(phy)

tab phy, m plot // the US has a pretty sedentary population
                // also, this is a really ugly distribution with huge issues,
                // so we will add some jitter to the scatterplot to help the
                // plot look more informative (type 'h sc' for details)

* Simpler recode.
recode vig10fwk ///
	(94/95=0 "None") ///
	(1/3=1 "1-3 times/week") ///
	(4/7=2 "4-7 times/week") ///
	(8/28=3 "8+ times/week") ///
	(else=.), gen(phy4)
la var phy4 "Vigorous activity (10+ minutes, times/week)"

* Visualization.
sc bmi phy if phy > 0, jitter(3) name(bmi_phy, replace)

* Visualization as boxplots.
gr box phy, noout over(female) asyvars over(age4) medl(lc(red)) ///
	by(health, total note("")) note("") yti("Mean physical activity") ///
	name(phy_box, replace) // note usage of the 'total' option, among others


* IV: Race
* --------

ren raceb race
fre race

* Exploration:
tab health, summ(bmi) // mean BMI at each health level
bys health: ci bmi    // confidence bands

* Plotting BMI groups:
spineplot bmi7 race, scale(.7) name(bmi7, replace) scheme(burd7)

* Simplified classification.
gen bmi4:bmi7 = bmi7
replace bmi4 = 2 if bmi7==1
replace bmi4 = 5 if bmi7==6 | bmi7==7

* Create dummies from the categories (creates new numbers for the 4 groups).
tab bmi4, gen(bmi4_)

* Stacked bar plot:
gr bar bmi4_*, stack over(race) scale(.7) ///
	legend(row(1) lab(1 "Underweight") lab(2 "Normal") ///
	lab(3 "Overweight") lab(4 "Obese")) ///
	name(bmi4_race, replace) scheme(burd4)

* Histogram by race and gender groups.
hist bmi, bin(10) xline(27) ///
	by(race female, cols(2) note("Vertical line at sample mean.") legend(off)) ///
	name(bmi_race_sex, replace)


* IV: Health insurance
* --------------------

fre uninsured

* Recode to dummy.
recode uninsured (1=0 "Not covered") (2=1 "Covered") (else=.), gen(hins)
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
* crosstabulate two categorical variables into rows and columns.

* Plotting:
spineplot hins race, scale(.7) name(hins, replace)


* ======================
* = SUMMARY STATISTICS =
* ======================


* Export using stab. This command is part of the course itself. The su() option
* summarizes a list of continuous variables, and the fre() option displays the
* frequencies of categorical variables. The by() option also allows to produce
* several tables for comparative purposes (see draft 1 template). Finally, stab
* accepts survey weights, so specify whatever weighting scheme is relevant to
* your sample and research design.
stab using week5 [aw=perweight], ///
	su(bmi age) ///
	fr(female edu3 health phy4 race hins) ///
	replace


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Thanks for following!
* exit, clear
