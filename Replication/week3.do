* What: SRQM Session 3
* Who:  F. Briatte and I. Petev
* When: 2012-02-06


/* Hi! Welcome to your third SRQM do-file.

 - Now is the point where you need to make a choice of dataset for your project.
   Start writing the commands that you used to select your data and variables to
   a do-file. Use the course do-files for inspiration: start with a short header
   in the comments, then load the data, then explore and recode the variables.

 - If you want to study one country or compare two of them, turn to survey data
   from the European Social Survey (ESS), U.S. General Social Survey (GSS) or
   World Values Survey (WVS). If you want to study country-level data, turn to
   the Quality of Government data (your sample will then be all world countries;
   do not restrict the sample further by subsetting to less observations).

 - When selecting variables, make sure that the dependent variable is continuous
   or pseudo-continuous. The dependent variable (DV) is the one that you want to
   explain through a selection of independent variables (IVs). Your introduction
   will offer a general theory to state the articulation between your variables.

*/


* =========
* = SETUP =
* =========


* Required commands.
foreach p in fre spineplot {
	cap which `p'
	if _rc==111 cap noi ssc install `p' // install from online if missing
}


* Log.
cap log using "Replication/week3.log" replace


* ========
* = DATA =
* ========


* Egypt underwent a social revolution in 2011. Who were the revolutionaries?
* What fraction of Egyptian society was willing to undergo radical reform?
* And most importantly perhaps, how strong was the support for the status quo?
* If the desire for reform spreads through society, which social groups will
* oppose the strongest level of resistance to change? What socio-economic
* characteristics predict a high level of support in the existing regime?

* Welcome again to Stata. This do-file contains the commands used during our 
* third session. Read the comment lines as you go along. We will explore the
* WVS 2000 dataset by concentrating on respondents from Egypt. The analysis
* will illustrate how to recode variables and missing values.

* Data: World Values Survey (2000).
use "Datasets/wvs2000.dta", clear

* Finally, if you need to use survey weights:
svyset [pw=v245]


* ====================
* = DATA PREPARATION =
* ====================


* Inspect the list of included countries.
fre v2
ren v2 country

* Subset the data to Egyptian respondents.
keep if country==89


* ======================
* = DEPENDENT VARIABLE =
* ======================


* Inspect the dependent variable: attitude towards society.
fre v140
ren v140 reform

* Recode missing values to the Stata '.' format.
replace reform=. if reform==9
fre reform

* Recode the variable to a simpler form: for or against the status quo.
* The recoded variable is binary: it takes only two values, either 0 or 1.
* Such variables are also called 'dummies'.
recode reform ///
	(1/2=0 "Change") ///
	(3=1 "Status quo") ///
	(else=.), gen(sq)
la var sq "Regime support"
fre sq

* Another way to understand a binary variable is by looking at its mean. All
* values being equal either to null (0) or 1, the mean of a binary variable
* reads as the proportion of positive values (1) within the total number of
* observations. Read the same variable again with that lens:
su sq

* The more appropriate command would have to take into account the fact that
* our status quo variable is a dichotomous outcome, and that the data should
* be weighted. We will explore these themes later on, but the command is:
svy: prop sq


* =========================
* = INDEPENDENT VARIABLES =
* =========================


* (1) Gender
* ----------

fre v223
ren v223 sex

* Recode as binary: either female or not.
recode sex (1=0 "Male") (2=1 "Female"), gen(female)
la var female "Gender"
fre female

* Compute the average support for the status quo among each gender group.
* Since the recoded status quo variable can only take values of 0 and 1,
* with 1 indicating support for the status quo, then its mean indicates the
* percentage of status quo supporters in each gender group.
bysort female: su sq

* The same result appears if you crosstabulate both variables.
tab sq female, col


* (2) Age
* -------

fre v225 // fine here, but do not use -fre- with continuous data in do-files
ren v225 age

* Recode missing values (strangely enough, '99' is a missing value here).
replace age=. if age==99
su age

* Distribution of age.
hist age, percent name(age, replace)

* Box plot by gender group.
gr hbox age, over(female) asyvars

* Recode to age groups.
recode age (16/33=1 "16-33 years") ///
	(34/49=2 "34-49 years") ///
	(50/64=3 "50-64 years") ///
	(65/max=4 "65+ years"), gen(agegroup)
la var agegroup "Age group"
tab agegroup

* Average support for the status quo by gender and age groups.
gr dot sq, over(female) over(agegroup) name(sq_sex_age, replace)

* Crosstabulation.
tab sq agegroup, nofreq col


* (3) Education
* -------------

fre v226
ren v226 edu

* Recode missing values.
replace edu=. if edu==99

* Recode to simpler educational attainment levels.
recode edu ///
	(1/2=0 "None") ///
	(3/4=1 "Primary") ///
	(5/8=2 "Secondary") ///
	(9=3 "University"), gen(edulvl)
la var edulvl "Education attainment"
fre edulvl

* Average support for the status quo by educational attainment.
gr dot sq, over(female) over(edulvl) name(sq_edu, replace)

* Crosstabulation.
tab sq edulvl, col nofreq


* (4) Household composition (using a combination of two variables)
* -------------------------

fre v106
ren v106 marital
fre v107
ren v107 children

* Recode missing values (another strange coding: '9' is a missing value here).
replace children=. if children==9

* Recode marital status to simpler categories. Note that this recoding excludes
* divorced, separated and widowed respondents, as to focus on other households.
recode marital (1=1 "Married") (6=0 "Single") (else=.), gen(married)
la var married "Married"

* Verify the exceptionality of monoparental households.
bysort married: su children

* Crosstabulation.
tab sq married, col nofreq

* Distribution of children among married respondents.
hist children if married, percent discrete name(children, replace)

* Generate a new composite variable for both marital status and children.
gen hh=.
replace hh=0 if children==0
replace hh=1 if married
replace hh=2 if married & children==1
replace hh=3 if married & children==2
replace hh=4 if married & children==3
replace hh=5 if married & children==4
replace hh=6 if married & children>=5

* Create a label for the values of the composite variable.
la def hh_labels ///
	0 "Single" ///
	1 "Married, no child" ///
	2 "Married, 1 child" ///
	3 "Married, 2 children" ///
	4 "Married, 3 children" ///
	5 "Married, 4 children" ///
	6 "Married, 5+ children"
la val hh hh_labels
la var hh "Household composition"
fre hh

* Average support for the status quo by household composition.
gr dot sq, over(female) over(hh) name(sq_hhold, replace)

* Alternative visualization. Install the command by uncommenting the line below.
spineplot married sq, name(spine_married, replace)
spineplot hh sq, scheme(burd7) name(spine_hh, replace)

* Alternative crosstabulations:
table children female married, c(n sq mean sq) format(%9.2f) // supercolumns
tab sq married, cell // cell percentages.


* (5) Urban setting
* -----------------

fre v241
ren v241 city8 // note: level 7 (100,000-500,000) is missing

* Recode missing values.
replace city8=. if city8==9

* Average support for the status quo by city size. The "tab" command accepts a
* "sum" option to summarise a variable within each category of another variable.
* The standard deviations are used to check for variance.
tab city8, sum(sq)

* Recode to simpler categories.
recode city8 ///
	(1/3=1 "Small-size") ///
	(4/6=2 "Mid-size") ///
	(8=3 "Large-size"), gen(city3)
la var city3 "City size"

* Average support for the status quo by city size.
gr dot sq, over(city3) name(sq_city3, replace)

* Alternative visualization.
spineplot city3 sq, scheme(burd6) name(sq_city3, replace)

* Crosstabulation.
tab sq city3, col nofreq


* ========================
* = CONFIDENCE INTERVALS =
* ========================


* The following lines show what we will learn to do in future sessions when we
* add estimation and significance to our toolkit. You do not need to replicate
* this part of the code. Note: collapsing is going to alter the data in memory
* and you will have to run all lines from the 'preserve' to 'restore' commands
* for the code to execute properly.

* Recoding city size to dummy.
recode city8 (1/6=0 "lo") (8=1 "hi"), gen(city2)

* Preserve WVS 2000 data.
preserve

* Collapse data by age group and city size (destructive).
collapse (mean) sq (sd) sd = sq (count) n = sq, by(agegroup city2)

* Create upper-level and lower-level confidence intervals.
gen ul = sq + invttail(n-1,0.025)*(sd / sqrt(n))
gen ll = sq - invttail(n-1,0.025)*(sd / sqrt(n))

* Plot.
tw conn sq agegroup if city2==0 || ///
	rcap ul ll agegroup if city2==0 || ///
	rcap ul ll agegroup if city2==1 || ///
	conn sq agegroup if city2==1, ms(Oh) ///
	xlab(1 "16-33" 2 "34-49" 3 "50-64" 4 "65+") ///
	legend(subtitle("City population") pos(3) col(1) ///
	order(1 "< 500,000" 4 "> 500,000")) ///
	yti("Attitude = (status quo)") scheme(burd4) // that was long

* Restore original data.
restore


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
