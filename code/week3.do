
* Check setup.
run setup/require fre scheme-burd

* Allow Stata to scroll through the results.
set more off

* Log results.
cap log using code/week3.log, replace

/* ------------------------------------------ SRQM Session 3 -------------------

   F. Briatte

 - TOPIC:  Support for Sharia Law in Nine Countries

 - DATA:   World Values Survey Wave 4 (c. 2000)

 - Welcome again to Stata. This do-file contains the commands used in our third
   session. For coursework, practice with Stata code by running the code again,
   and read the full comments on the way.
   
 - This do-file explores the World Values Survey (WVS) dataset and focuses on
   support for sharia law among respondents in Arab-speaking countries, several
   of which have been in political turmoil over the past few years.

  - The dependent variable (DV) is a 5-point agreement scale with the statement:
   "[The government] should implement only the laws of the sharia". The variable
   was measured during WVS Wave 4 (1999-2004).

 - Make sure that you understand how to distinguish continuous and categorical
   types of variables by the end of this training session. Also make sure that
   you know how to encode variables and missing values for analysis in Stata.

 - Select a dataset for analysis. Use the -lookfor- and -lookfor_all- commands
   to identify which dataset has variables that match your interests, and use
   the -d-, -fre- and -su- commands to describe and inspect the variables.

 - Start writing a draft do-file in which you prepare your dataset for analysis.
   Use the course do-files for inspiration: start with a short header, then load
   the data and describe the variables, recoding them if needed.

 - When selecting variables, make sure that the dependent variable is continuous
   or pseudo-continuous. The dependent variable (DV) is the one that you want to
   explain using your selection of independent variables (IVs).
   
 - Write a draft paragraph that describes the dependent variable in sufficient
   detail, and another draft paragraph that lists your independent variables and
   offers a general theory on the articulation between your variables.

   Last updated 2019-02-15.

----------------------------------------------------------------------------- */

* Load WVS dataset.
use data/wvs2000, clear

* Survey weights (see WVS documentation).
svyset [pw = v245]

* Inspect the list of included countries.
fre v2

* Rename the variable to something understandable.
ren v2 country

* Survey years.
table country, c(min s020 max s020)


* Dependent variable: Support for sharia law
* ------------------------------------------

* Inspect the overall dependent variable.
fre iv166

* Clone the nonmissing values of the variable: exclude 'DK/NA' codes.
clonevar sharia = iv166 if inrange(iv166, 1, 5)

* We use -clonevar- to create a variable with the same coding and labels as the
* original one. The first argument ('sharia') is the name of the new variable
* that we want to create. The new variable appears at the end of the dataset, as
* the -d- command (for -describe-) would show.

* The rest of the command excludes missing values from the cloned variable: we
* use the -if- logical operator to do that. The condition used above means that
* only values within the '1 to 5' range will be cloned from iv166 into sharia.

* In the present case, we could have obtained the same result by using any of
* the following commands:

// clonevar sharia = iv166 if iv166 > 0 & iv166 < 6
// clonevar sharia = iv166 if iv166 > 0 & iv166 < 8

* Using -clonevar- allows us to use a new variable name, to recode the missing
* values, and to copy the valuable attributes of the original variable (variable
* and value labels), all while preserving the original variable for reference.

* Inspect the clean version of the variable.
fre sharia

* Find in which countries the variable was measured.
fre country if !mi(sharia)

* Create a variable counting nonmissing observations in each country.
bys country: egen sharia_count = count(sharia)

* Keep only countries for which the variable has nonmissing observations.
drop if !sharia_count

* In the first command, the -!mi- operator means 'not missing' and therefore
* produces the list of countries for which the DV is available. In the second
* command, -drop- removes all observations for which the DV is missing.


* Recoding to dummies
* -------------------

* Recall the DV frequencies.
fre sharia

* Recode the variable to a simpler form: pro-sharia respondents vs others.
* The recoded variable is binary: it takes only two values, either 0 or 1.
* These variables are affectionately called 'dummies'.
recode sharia ///
	(1/2 = 1 "Support") ///
	(4/5 = 0 "Oppose") ///
	(else = .), gen(prosharia)
la var prosharia "Legislative enforcement of sharia (0/1)"
fre prosharia

* Another way to understand a binary variable is to look at its mean: because
* the values of that variable are equal to either 0 or 1, its mean reads as the
* proportion of positive cases (1) within the total number of observations.
su prosharia

* Same thing, different command (more flexible; used later).
tabstat prosharia, s(n mean) c(s)

* Finally, you can generates dummies for each value of a variable, which here
* means generating five dummies starting with the 'sharia_' prefix:
tab sharia, gen(sharia_)

* Show all variables named 'sharia_[whatever]'.
codebook sharia_*, c


* Stacked plots with dummies
* --------------------------

* One reason to recode is to have a look at simplified versions of the DV in
* graphs. Here's a dot plot showing the mean value of the DV (its proportion)
* in each country, sorted by descending order:
gr dot prosharia, over(country, sort(1)des) ///
   name(dv_dot, replace)

* Recode the DV to three groups.
recode sharia ///
	(1/2 = 1 "Agree") ///
	(3 = 2 "Neither") ///
	(4/5 = 3 "Disagree") ///
	(else = .), gen(sharia3)
la var sharia3 "Legislative enforcement of sharia (3 groups)"

* Recode each category to a dummy.
tab sharia3, gen(sharia3_)
d sharia3_*

* Comparative plot at the country level, shown with tons of graphical options
* to illustrate a limitation of Stata: it requires some work to produce decent
* visualizations, especially with categorical variables.
gr bar sharia3_*, over(country, sort(1)des lab(angle(45))) stack percent ///
	ti("Support for sharia legislation") yti("% respondents") ///
	legend(row(1) order(1 "For" 2 "Neutral" 3 "Against")) ///
	note("World Values Survey 1999-2004. {it:N} = 13,541") ///
	scheme(burd3) name(dv_bar, replace)

* Identical plot, shown with horizontal bars and less options. Some settings
* that show up on my end are provided by the burd3 scheme, which is part of
* the course material; it will look different with other graph schemes.
gr hbar sharia3_*, over(country, sort(1)des) stack percent ///
	ti("Support for sharia legislation") yti("% respondents") ///
	legend(pos(1) row(1) order(1 "For" 2 "Neutral" 3 "Against")) ///
	note("World Values Survey 1999-2004. {it:N} = 13,541") ///
	scheme(burd3) name(dv_hbar, replace)


* =========================
* = INDEPENDENT VARIABLES =
* =========================


* Describe independent variables.
d v223 v225 v226 v241

* Overview of variable codes.
fre v223 v225 v226 v241


* IV: Gender
* ----------

fre v223

* Recode gender as a meaningful binary (either female or not) using a logical
* operator (in brackets), excluding missing observations from the operation and
* applying the 'female' label to the new 'female' dummy variable:
gen female:female = (v223 == 2) if inlist(v223, 1, 2)

* Label the values.
la def female 0 "Male" 1 "Female", replace

* Label the variable.
la var female "Gender"

* Final result.
fre female

* Compute the average support for sharia law among each gender group. Since the
* recoded DV only takes values of 0 or 1, its mean indicates the percentage of
* sharia supporters in each gender group.
bys female: su prosharia

* The same result can be viewed as a frequency by crosstabulating the variables.
tab prosharia female, col nof


* IV: Age
* -------

fre v225

* Strangely enough, '98' and '99' are missing values here, so we replace those
* values with the proper code for missing values. The -replace- command is the
* quickest way to do that.
replace v225 = . if inlist(v225, 98, 99)

* There are often more than one way to do things like recoding. The command
* above could have been written in many different ways, including this one:

// gen age = v225 if v225 < 98
// replace v225 = . if v225 == 98 | v225 == 99

* Now that the missing values are correctly encoded, we clone the variable.
clonevar age = v225

* Use -summarize- (or simply -su-) to get the summary statistics, as appropriate
* for continuous variables where the mean and standard deviation are meaningful.
* Do -not- use either -fre- or -tab- to summarize a continuous variable!
su age

* Histograms showing the distribution of age in each country.
hist age, by(country, note("")) bin(9) percent ///
	xti("Age distribution") ///
	name(age,replace)

* Recode to quartiles -- shown for demonstration purposes: recoding to groups
* makes much more sense here, but recoding to n-quantiles like percentiles or
* quartiles is useful in many explorative situations.
xtile age_q4 = age, nq(4)

* Check that the quartiles each capture roughly a quarter of the distribution.
fre age_q4

* Inspect how age varies within each quartile (e.g. compare top and bottom 25%).
tab age_q4, sum(age)

* Expectedly, there is more variance in the last, older group. Let's finally get
* the range, or lower (min) and lower (max) bounds, of each age quartile.
table age_q4, c(min age max age)

* Recode to four age groups. The -irecode- command creates categories based on
* continuous intervals: category 0 of age4 will contain observations of age up
* to 33, category 1 will contain those from 34 to 49, and so on.
gen age4:age4 = irecode(age, 33, 49, 64, .)

* Check the results. This is a different -table- command than the -tab- one used
* previously, which we will get to use for more flexible crosstabulations.
table age4, c(min age max age)

* And here's yet another way to crosstabulate: the -tab- command with the -sum- 
* option returns the average age in each age group, along with the SD and count.
* More on the SD (standard deviation) next week.
tab age4, sum(age)

* Write the value and variable labels.
la def age4 0 "16-33" 1 "34-49" 2 "50-64" 3 "65+", replace
la var age4 "Age groups"
fre age4

* Average support for sharia law by age group in each country.
gr dot prosharia, over(female) asyvars over(age4) by(country) ///
	name(dv_sex_age2, replace)
	

* IV: Education
* -------------

fre v226

* Recode to simpler educational attainment levels.
recode v226 ///
	(1/2 = 0 "None") ///
	(3/4 = 1 "Primary") ///
	(5/8 = 2 "Secondary") ///
	(9 = 3 "University") ///
	(else = .), gen(edu4)
la var edu4 "Education"
fre edu4

* Histograms showing the distribution of education in each country. Because the
* variable is categorical, the histograms require the -discrete- option to plot
* the histograms bin as zero-spaced frequency bars.
hist edu4, by(country, note("")) percent discrete xla(0(1)3) ///
	name(edu,replace)


* IV: Employment status
* ---------------------

fre v229

* Clone variable without missing values.
clonevar empl = v229 if v229 < 8
fre empl


* IV: Household composition
* -------------------------

fre v106 v107

* Married dummy.
gen married = (v106 == 1) if v106 < 8
tab v106 married

* Children dummy.
gen haskids = (v107 > 0) if v107 < 9
tab v107 haskids


* IV: City size
* -------------

* Recode to simpler categories.
recode v241 ///
	(1/3 = 1 "< 10k") ///
	(4/6 = 2 "< 100k") ///
	(7 = 3 "< 500k") ///
	(8 = 4 "> 500k") ///
	(else = .), gen(city4)
la var city4 "City size"
fre city4


* ===================== 
* = FINALIZED DATASET =
* =====================


* Finalizing a dataset before analysis involves doing two things. The first
* one consists in subsetting to fully measured data, which means dropping all 
* observations with missing values in the variables selected for analysis.
* This restriction is required by the kind of models that we will run later on.
* Prior to that, we will need to subset the data to the countries of interest.

* Recall how the country variable is coded.
fre country

* Subset to two countries of interest.
keep if inlist(country, 89, 96)

* Overall (i.e. both countries pooled together) pattern of missing values.
misstable pat sharia age female edu4 empl married haskids city4

* Pattern of missing values for Egypt.
misstable pat sharia age female edu4 empl married haskids city4 if country == 89

* Pattern of missing values for Algeria.
misstable pat sharia age female edu4 empl married haskids city4 if country == 96

* Studying the pattern of missing values is a crucial requirement: dropping
* observations with missing values might affect the representativeness of the
* data, or even bring it to such a low number of observations that statistical
* power (the capacity of your data to discriminate statistically significant
* relationships from insignificant ones) will be at risk. Adopt a reasonable
* strategy at that stage: find equivalents to variables that damage your sample,
* and adjust your research questions to the available data. Whatever choice you
* end up making, ensure that you understand how your finalized dataset relates
* to the original data with regards to representativeness.

* Subset to nonmissing observations.
drop if mi(sharia, age, female, edu4, empl, married, haskids, city4)

* Last step: get the final sample size (in each country).
bys country: count


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
