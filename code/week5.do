
* Check setup.
run setup/require fre scheme-burd spineplot

* Allow Stata to scroll through the results.
set more off

* Log results.
cap log using code/week5.log, replace

/* ------------------------------------------ SRQM Session 5 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Social Determinants of Adult Obesity in the United States

 - DATA:   U.S. National Health Interview Survey (2017)

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
   Survey (NHIS). The sample used in the analysis contains = 21,770 individuals
   selected through state-level stratified probability sampling.

 - The lines above are a quick example of what you should be planning to write
   up in your first draft: a description of your data, followed by a list of
   clearly worded and substantively informed hypotheses.

 - Please make sure that your do-file is named like 'Briatte_Petev_1.do' (use
   your own family names, in alphabetical order). Name your paper the same way
   and print it to PDF format: do not circulate your work in editable formats.
 
 - To simplify your workflow, the course uses a paper template that you will
   share with your research partner(s) using Google Documents. This template  
   contains more instructions on the first draft.
   
 - Your first draft must inform the reader about simple things: What is your
   research question? Where does your data come from, how large is the sample
   and how was it designed? Include references to the data source and codebook.
   
 - Your paper also explains what choice of variables you have made, and with
   what theory to support that choice. You have to substantiate your decisions:
   providing a mere description of the measurements is insufficient.
    
 - In line with that idea, do NOT write your paper as a technical summary of
   what your code accomplishes: refer to variables not by names but by what they
   actually measure, and explain how they fit in your general reasoning.

 - Remember that you have been provided with example papers: use them to learn
   about the writing style and scientific tone to adopt in your own work. This
   requirement is covered at more length in the rest of the course material.

 - Your first do-file can imitate the course do-files in its structure. Your
   code should assess DV normality and explore differences in the DV with graphs
   and confidence intervals over categorical IVs. Analyze results in your paper.
 
 - Importantly, do NOT produce results in your do-file if you are not going to
   interpret them at a later stage: produce meaningful code that leads you to
   learn, understand and analyze the data.
  
 - Use the -stab- command at the end of this do-file to export summary stats
   to a simple table. The result will be a plain text file that you can copy
   and paste into Google Documents, or import into any other text editor.

   Last updated 2021-01-28.

----------------------------------------------------------------------------- */

* Load NHIS data for latest survey year.
use data/nhis1017, clear

* Set individual survey weights.
svyset psu [pw = perweight], strata(strata)


* Dependent variable: Body Mass Index
* -----------------------------------

gen bmi = weight * 703 / height^2 if weight < 996 & height < 96
la var bmi "Body Mass Index"

* Detailed summary statistics.
bys year: su bmi, d


* Breakdowns
* ----------

* Recoding BMI to 6 groups (best method: cutting the data to intervals).
gen bmi6:bmi6 = irecode(bmi, 0, 18.5, 25, 30, 35, 40, .)
la var bmi6 "Body Mass Index (categories)"

* Define the category labels.
la def bmi6 ///
	1 "Underweight" 2 "Normal" 3 "Overweight" ///
	4 "Obese" 5 "Severely obese" 6 "Morbidly obese", replace

* Breakdown of mean BMI by groups.
d bmi bmi6
bys year: tab bmi6, su(bmi)

* Progression of BMI groups over years.
spineplot bmi6 year, scheme(burd6) ///
    name(bmi6, replace)

* Restrict data to most recent year.
keep if year == 2017

* Breakdown of BMI to percentiles.
xtile bmi_qt = bmi, nq(100)

* Verify the BMI of, e.g. the top 10% most obese.
su bmi if bmi_qt == 90

* Compute the mean BMI for each percentile.
bys bmi_qt: egen bmi_qm = mean(bmi)

* Plot the empirical cumulative distribution function (ECDF) of BMI.
sc bmi_qm bmi_qt, m(o) c(l) xla(0(10)100) ///
	yti("Body Mass Index") xti("Percentiles") ///
	name(bmi_ecdf, replace)


* Independent variables
* ---------------------

fre age sex race earnings health uninsured, r(10)

* Recode age to four groups (slow and risky method: using manual categories).
recode age ///
	(18/44 = 1 "18-44") ///
	(45/64 = 2 "45-64") ///
	(65/74 = 3 "65-74") ///
	(75/max = 4 "75+") (else = .), gen(age4)
la var age4 "Age groups (4)"

* Recode age to eight groups (nifty method: using decades, 10-19, 20-29, etc.).
gen age8 = 10 * floor(age / 10) if !mi(age)
la var age8 "Age groups (8)"

* Recode sex to dummy.
gen female:female = (sex == 2) if !mi(sex)
la def female 0 "Male" 1 "Female", replace

* Recode missing values of income.
replace earnings = . if !earnings | earnings > 96

* Recode missing values of health insurance.
mvdecode uninsured, mv(9)

* Recode insurance status to dummy.
replace uninsured = (uninsured == 2) if !mi(uninsured)
la def uninsured 0 "Insured" 1 "Uninsured", replace


* Subsetting
* ----------

* Patterns of missing values.
misstable pat bmi age female race earnings health uninsured

* Delete incomplete observations.
drop if mi(bmi, age, female, race, earnings, uninsured)

* Final data, showing final sample size.
codebook bmi age female race earnings health uninsured, c


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
tab age4, su(bmi) // mean BMI in each age group
bys age4: ci mean bmi  // confidence bands


* IV: Gender
* ----------

* Plot mean BMI groups for each gender group, for each age decade.
gr bar bmi, over(female) asyvars over(age8) yline(27) ///
    note("Horizontal line at sample mean.") ///
    name(sex_age, replace)

* 95% CI estimates:
tab female, su(bmi) // mean BMI in each gender group
bys female: ci mean bmi  // confidence bands


* IV: Race
* --------

* Plot BMI groups for each racial background:
spineplot bmi6 race, scheme(burd6) ///
    name(race, replace)

* Histogram by race and gender groups.
hist bmi, bin(10) xline(27) ///
	by(race female, cols(2) ///
	note("Vertical line at sample mean.") legend(off)) ///
	name(race_sex, replace)

* 95% CI estimates:
tab race, su(bmi) // mean BMI at each health level
bys race: ci mean bmi  // confidence bands


* IV: Income
* ----------

* Generate variable defined by the income ceiling of each category.
gen inc = 5000 * earnings + 5000 * (earnings - 5) * (earnings > 5)
la var inc "Total earnings ($)"

* Plot racial backgrounds for each income band.
spineplot race inc if inc > 0, xla(,alt axis(2)) ///
	name(inc_race, replace)

* Plot income quartiles for each BMI group.
gr box inc if inc > 0, over(bmi6) ///
	name(inc, replace)

* Plot BMI quartiles for each income band (excluding outliers).
gr box bmi if inc > 0, over(inc) noout ///
	name(bmi_inc, replace)

* 95% CI estimates:
tab inc, su(bmi) // mean BMI in each income band
bys inc: ci mean bmi  // confidence bands


* IV: Health insurance
* --------------------

* Plot BMI distribution for groups who have or do not have health coverage.
kdensity bmi if uninsured, addplot(kdensity bmi if !uninsured) ///
	legend(order(1 "Not covered" 2 "Covered") row(1)) ///
	name(uninsured, replace)

* Exploration:
tab uninsured, su(bmi) // mean BMI for each group
bys uninsured: ci mean bmi  // confidence bands


* =============================
* = EXPORT SUMMARY STATISTICS =
* =============================


* The reader of your research does not know your data. A solution at that stage
* is therefore to produce a table that holds descriptive (summary) statistics
* for the variables that you have selected for analysis. This requires using a
* command that was written especially for the course, to make it very easy.

* The next command is part of the SRQM folder. If Stata returns an error when
* you run it, set the folder as your working directory and type -run profile-
* to run the course setup, then try the command again. If you still experience
* problems with the -stab- command, please send a detailed email on the issue.

stab using week5_stats.txt, replace ///
	mean(bmi age) ///
	prop(female race earnings uninsured)

/* Syntax of the -stab- command:

 - using FILE  - name of the exported file; plain text (.txt) recommended
 - replace     - overwrite any previously existing file
 - mean()      - summarizes a list of continuous variables (mean, sd, min, max)
 - prop()      - summarizes a list of categorical variables (frequencies)

  In the example above, the -stab- command will export a single file to the
  working directory (week5_stats.txt) containing summary statistics for the
  final sample, as a plain text file of tab-separated values. */

* Last reminder: your code is the technical document, whereas your paper is the 
* substantive document. Make sure that the paper is not a descriptive write-up
* of what happens in your code: you need to produce analytical value-added by
* explaining what you are hypothesizing about the relationships in the data.


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Thanks for following!
* exit, clear
