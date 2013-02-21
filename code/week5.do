
/* ------------------------------------------ SRQM Session 5 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Social Determinants of Adult Obesity in the United States

 - DATA:   National Health Interview Survey 2009

   We study variations in the Body Mass Index (BMI) of insured and uninsured
   American adults, in order to show how differences observed between racial
   backgrounds echo socioeconomic inequalities in education and health care.
 
 - (H1): We first expect to observe larger numbers of overweight and obese
   respondents among non-White males and among older age groups.
   
 - (H2): We then expect education to be negatively associated with obesity, as
   higher attainment indicates access to prevention and higher income.

 - (H3): We finally expect health insurance coverage to limit health consumption
   in poorer households, possibly affecting BMI across the life course.
   
   Our data come from the most recent year of the National Health Interview
   Survey (NHIS). The sample used in the analysis contains = ..,... individuals
   selected through state-level stratified probability sampling.
 
 - This is the stage where you submit your first draft. Please make sure that
   your do-file is named like 'Briatte_Petev_1.do' (use your own family names
   in alphabetical order). Name your paper the same way, and print it to PDF.
 
 - Your first do-file can imitate the course do-files in its structure. Your
   code should assess DV normality and explore differences in the DV with graphs
   and confidence intervals over categorical IVs. Analyze results in your paper.
 
 - Use the -stab- command at the end of this do-file to export summary stats
   to a simple table. The result will be a plain text file that you can copy
   and paste into Google Documents, or import into any other text editor.

 - Your first draft must inform the reader about simple things: What is your
   research question? Where does your data come from, how large is the sample
   and how was it designed? What choice of variables have you made, and with
   what theory to support it?

   Last updated 2012-11-13.

----------------------------------------------------------------------------- */


* Install required commands.
foreach p in fre spineplot {
	cap which `p'
	if _rc == 111 cap noi ssc install `p'
}

* Log results.
cap log using code/week5.log, replace


* ====================
* = DATA DESCRIPTION =
* ====================


use data/nhis2009, clear

* Individual survey weights.
svyset psu [pw = perweight], strata(strata)


* Dependent variable: Body Mass Index
* -----------------------------------

gen bmi = weight * 703 / height^2
la var bmi "Body Mass Index"

* Detailed summary statistics.
su bmi, d


* Breakdowns
* ----------

* Recoding BMI to 6 groups.
gen bmi6:bmi6 = irecode(bmi, 0, 18.5, 25, 30, 35, 40, .)
la var bmi6 "Body Mass Index (categories)"

* Define the category labels.
la def bmi6 ///
	1 "Underweight" 2 "Normal" 3 "Overweight" ///
	4 "Obese" 5 "Severely obese" 6 "Morbidly obese", replace

* Breakdown of mean BMI by groups.
d bmi bmi6
tab bmi6, summ(bmi)

* Progression of BMI groups over years.
spineplot bmi6 year, scheme(burd6) ///
    name(bmi6, replace)

* Breakdown of BMI to percentiles.
xtile bmi_qt = bmi, nq(100)

* Verify the BMI of, e.g. the top 10% most obese.
su bmi if bmi_qt == 90

* Compute the mean BMI for each percentile.
bys bmi_qt: egen bmi_qm = mean(bmi)

* Plot the empirical cumulative distribution function (ECDF) of BMI.
sc bmi_qm bmi_qt, ms(o) c(l) yti("Body Mass Index") ///
	name(bmi_ecdf, replace)


* Independent variables
* ---------------------

fre age sex raceb educrec1 earnings health uninsured ybarcare, r(10)

* Recode age to four groups (slow method, using manual categories).
recode age ///
	(18/44 = 1 "18-44") ///
	(45/64 = 2 "45-64") ///
	(65/74 = 3 "65-74") ///
	(75/max = 4 "75+") (else = .), gen(age4)
la var age4 "Age groups (4)"

* Recode age to eight groups (quick method, using decades: 10-19, 20-29, etc.).
gen age8 = 10 * floor(age / 10) if !mi(age)
la var age8 "Age groups (8)"

* Recode sex to dummy.
gen female:female = (sex == 2) if !mi(sex)
la def female 0 "Male" 1 "Female", replace

* Recode missing values of income.
replace earnings = . if inlist(earnings, 97, 99)

* Recode missing values of insurance and medical care.
mvdecode ybarcare uninsured, mv(9)


* Subsetting
* ----------

* Select observations from most recent year.
keep if year == 2009

* Patterns of missing values.
misstable pat bmi age female raceb educrec1 earnings health uninsured ybarcare

* Delete incomplete observations.
drop if mi(bmi, age, female, raceb, educrec1, earnings, uninsured, ybarcare)

* Final data, showing effective sample size.
codebook bmi age female raceb educrec1 earnings health uninsured ybarcare, c


* Normality
* ---------

hist bmi, bin(20) normal normopts(lp(dash)) ///
    kdensity kdenopts(k(biweight) bw(3) lc(black)) ///
    name(dv, replace)

* Transformations (add 'g' to make the command -gladder- for a graphical check).
ladder bmi

* Log-BMI transformation.
gen logbmi = ln(bmi)
la var logbmi "log(BMI)"

* Inspect improvement in normality.
tabstat bmi logbmi, s(skewness kurtosis) c(s)


* ========================
* = CONFIDENCE INTERVALS =
* ========================


* IV: Age
* -------

* Plot BMI groups for each age decade.
spineplot bmi6 age8, scheme(burd6) ///
     name(age, replace)

* 95% CI estimates:
tab age4, summ(bmi) // mean BMI in each age group
bys age4: ci bmi    // confidence bands


* IV: Gender
* ----------

* Plot mean BMI groups for each gender group, for each age decade.
gr bar bmi, over(female) asyvars over(age8) yline(27) ///
    note("Horizontal line at sample mean.") ///
    name(sex_age, replace)

* 95% CI estimates:
tab female, summ(bmi) // mean BMI in each gender group
bys female: ci bmi    // confidence bands


* IV: Race
* --------

* Plot BMI groups for each racial background:
spineplot bmi6 raceb, scheme(burd6) ///
    name(race, replace)

* Histogram by race and gender groups.
hist bmi, bin(10) xline(27) ///
	by(raceb female, cols(2) note("Vertical lines at sample mean.") legend(off)) ///
	name(race_sex, replace)

* 95% CI estimates:
tab raceb, summ(bmi) // mean BMI at each health level
bys raceb: ci bmi    // confidence bands


* IV: Education
* -------------

* Shorter labels for graph.
la def edu 13 "Grade 12" 14 "Coll 1-3 yrs" 15 "Coll 4" 16 "Coll 5+"
la val educrec1 edu

* Plot BMI groups for each educational level.
spineplot bmi6 educrec1, scheme(burd6) ///
    name(edu, replace)

* Plot racial backgrounds for each educational level.
spineplot raceb educrec1, ///
	name(edu_race, replace)

* 95% CI estimates:
tab educrec1, summ(bmi) // mean BMI at each education level
bys educrec1: ci bmi    // confidence bands


* IV: Income
* ----------

* Generate variable defined by the income ceiling of each category.
gen inc = 5000 * earnings + 5000 * (earnings - 5) * (earnings > 5)
la var inc "Total earnings ($)"

* Plot racial backgrounds for each income band.
spineplot raceb inc if inc > 0, xla(,alt axis(2)) ///
	name(inc_race, replace)

* Plot educational levels for each income band.
spineplot educrec1 inc if inc > 0, scheme(burd4) xla(, alt axis(2)) ///
	name(inc_edu, replace)

* Plot income quartiles for each BMI group.
gr box inc if inc > 0, over(bmi6) ///
	name(inc, replace)

* Plot BMI quartiles for each income band (excluding outliers).
gr box bmi if inc > 0, over(inc) noout ///
	name(bmi_inc, replace)

* 95% CI estimates:
tab inc, summ(bmi) // mean BMI at each education level
bys inc: ci bmi    // confidence bands


* IV: Health insurance
* --------------------

* Plot BMI distribution for groups who have or do not have health coverage.
kdensity bmi if uninsured == 1, addplot(kdensity bmi if uninsured == 2) ///
	legend(order(1 "Not covered" 2 "Covered") row(1)) ///
	name(uninsured, replace)

* Exploration:
tab uninsured, summ(bmi) // mean BMI at each health level
bys uninsured: ci bmi    // confidence bands


* IV: Health affordability
* ------------------------

* Plot BMI distribution for groups who could or coult not afford medical care.
kdensity bmi if ybarcare == 1, addplot(kdensity bmi if ybarcare == 2) ///
	legend(order(1 "Could afford medical care" 2 "Could not") row(1)) ///
	name(ybarcare, replace)

* Exploration:
tab ybarcare, summ(bmi) // mean BMI at each health level
bys ybarcare: ci bmi    // confidence bands


* ==================
* = EXPORT RESULTS =
* ==================


* The next command is part of the SRQM folder. If Stata returns an error when
* you run it, set the folder as your working directory and type -run profile-
* to run the course setup, then try the command again. If you still experience
* problems with the -stab- command, please send a detailed email on the issue.

stab using week5, replace ///
	su(bmi age) ///
	fr(female raceb educrec1 earnings uninsured ybarcare)

/* Basic syntax of -stab- command:

- argument: -using NAME-  adds the NAME prefix to the exported file(s)
- argument: -su()-        summarizes a list of continuous variables (mean, sd, min-max)
- argument: -fre()-       summarizes a list of categorical variables (frequencies)

- option:   -by-          produces several tables over a given categorical variable
- option:   -replace-     overwrite any previously existing tables
- option:   [aw, fw]      use survey weights (use only if you know how they work)

  In the example above, the -stab- command will export a single file to the
  working directory (week5_stats.txt) containing summary statistics for the
  final sample. To get one table per racial group, the syntax would be:
  
  stab using week5, replace ///
	su(bmi age) ///
	fr(female educrec1 earnings uninsured ybarcare) ///
	by(raceb)
  
  We will later see how to use -stab- to also export correlation tables. */


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Thanks for following!
* exit, clear
