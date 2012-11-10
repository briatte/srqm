* What: SRQM Session 10 (new)
* Who:  Franois Briatte and Ivaylo Petev
* When: 2012-11-10


* =========
* = SETUP =
* =========


* Required commands.
foreach p in estout fre leanout {
	cap which `p'
	if _rc==111 cap noi ssc install `p' // install from online if missing
}

* Log results.
cap log using "week10.log", replace


/* Research topic, hypotheses and methods:

 - We explore patterns of satisfaction with the state of health services in
   Britain and France, two countries with extensive public healthcare systems.

 - (H1): We expect to observe high satisfaction on average, except among those
   in ill health, who we expect to report lower satisfaction regardless of age,
   sex, income or political views.

 - (H2): We also expect respondents in political opposition to the government to
   report less satisfaction with the state of health services in the country,
   independently of all other characteristics.

 - (H3): We finally expect to find lower patterns of satisfaction among those
   who report financial difficulties, as evidence of an income effect that
   we expect to exist in isolation of all others.

 - We use data from the 2008 European Social Survey (Round 4), at which time the
   government was left-wing in Britain and right-wing in France.

 - We run linear regressions for each country to assess whether satisfaction 
   with health services can be predicted from age, sex, health status, political
   leaning and financial situation, controlling for age and sex.
   
*/


* ========
* = DATA =
* ========


use "Datasets/ess2008.dta", clear


* Dependent variable
* ------------------

fre stfhlth

* Rename DV.
ren stfhlth hsat

* Cross-country comparison.
tab cntry, summ(hsat)

* Detailed summary statistics.
su hsat, d


* Cross-country comparisons
* -------------------------

* Cross-country visualization (mean).
gr dot hsat, over(cntry, sort(1)des) yla(0 10) ///
	yti("Satisfaction in health services") ///
	name(dv_country, replace)

* Generate category dummies for the full 11-pt scale DV.
cap drop hsat11_*
tab hsat, gen(hsat11_)

* Cross-country visualization (full 11-pt scale).
gr hbar hsat11_*, over(cntry, sort(1)des) stack legend(off) ///
	yti("Satisfaction in health services") ///
	scheme(burd11) name(dv_country11, replace)


* Independent variables
* ---------------------

fre agea gndr health hincfel lrscale, r(10)

* Recode sex to dummy.
gen female:female = (gndr==2) if !mi(gndr)
la de female 0 "Male" 1 "Female", replace

* Fix age variable name.
ren agea age

* Generate six age groups (15-24, 25-34, ..., 65+).
gen age6:age6 = irecode(age,24,34,44,54,64,.)
replace age6 = 10*age6 + 15
la de age6 15 "15-24" 25 "25-34" 35 "35-44" 45 "45-54" 55 "55-64" 65 "65+", replace

* Subjective high income dummy.
gen lowinc = (hincfel > 2) if !mi(hincfel)

* Recode left-right scale.
recode lrscale (0/4=1 "Left") (5=2 "Centre") (6/10=3 "Right"), gen(pol3)


* Subsetting
* ----------

* Check missing values.
misstable pat hsat age6 female health pol3 lowinc if cntry=="FR"
misstable pat hsat age6 female health pol3 lowinc if cntry=="GB"

* Select case studies.
keep if inlist(cntry,"FR","GB")

* Delete incomplete observations.
drop if mi(hsat,age6,female,health,pol3,lowinc)


* Normality
* ---------

* Distribution of the DV in the case studies.
hist hsat, discrete normal xla(1 11) by(cntry, legend(off) note("")) ///
	name(dv_histograms, replace)

* Generate strictly positive DV recode.
gen hsat1 = hsat + 1 

* Visual check of common transformations.
//gladder hsat1, bin(11) ///
//	name(gladder, replace)

/* Notes:

 - There are more missing observations for Britain than for France, and this
   might distort the results if the non-respondents come, for example, from the
   same end of the political spectrum. We'll be careful.

 - The distribution of the DV is skewed to the right in both case studies, which
   is consistent with the hypothesis that extensive healthcare states like the
   ones found in Britain France enjoy higher popular support.

 - To allow for a log-transformation, the variable should be strictly positive
   since the function f: y = log(x) is undefined for x = 0. We use a recode of
   the DV of strictly positive range to test for transformations.

 - The square root comes only marginally closer to a normal distribution. With
   little improvement in normality, transforming the DV would be overkill. It is
   reasonable to carry on with the untransformed DV.

*/


* =====================
* = ASSOCIATION TESTS =
* =====================


* Relationships with socio-demographics
* -------------------------------------

* Line graph using DV means computed for each age and gender group.
cap drop msat*
bys cntry age6: egen msat1 = mean(hsat) if female
bys cntry age6: egen msat2 = mean(hsat) if !female
tw conn msat1 msat2 age6, by(cntry, note("")) ///
	xti("Age") yti("Mean level of satisfaction") ///
	legend(row(1) order(1 "Female" 2 "Male")) ///
	name(hsat_age_sex, replace)

* Association between DV and gender.
by cntry: ttest hsat, by(female)

* Correlation between DV and age (using the continuous measurements).
by cntry: pwcorr hsat age, obs sig

* Plot DV histograms over small multiples (6 age groups, 2 countries).
hist hsat, normal discrete by(cntry age6, col(3) note("") legend(off)) ///
	name(dv_age6, replace)

* Generate a dummy from extreme categories of age.
cap drop agex
gen agex:agex = .
replace agex = 0 if age6==15
replace agex = 1 if age6==65
la de agex 0 "15-24" 1 "65+", replace

* Difference between age extremes.
bys cntry: ttest hsat, by(agex)


* Relationship to health status
* -----------------------------

* DV by health.
gr dot hsat [aw=dweight], over(health) over(cntry) ///
	yti("Satisfaction in health services") ///
	name(dv_health, replace)

* Generate a dummy from health status (bad/very bad = 0, good/very good = 1).
cap drop health01
recode health (1/2=1 "Good") (4/5=0 "Poor") (else=.), gen(health01)

* Association between DV and health status.
bys cntry: ttest hsat, by(health01)


* Relationship to low income status
* ---------------------------------

* DV by income.
bys cntry: ttest hsat, by(lowinc)

* Association between IV and political attitude.
bys cntry: tab lowinc pol3, col chi2 nokey

* Proportions test (since the lowinc dummy is a proportion of the sample).
bys cntry: prtest lowinc if pol3 != 2, by(pol3)


* Relationship to left-right attitude
* -----------------------------------

* Correlation between DV and political attitude (left 1-10 right).
by cntry: pwcorr hsat lrscale, obs sig

* Association between DV and political attitude (left, centre, right).
gr box hsat, over(pol3) asyvars over(cntry) legend(row(1)) ///
	scheme(burd4) name(dv_pol3, replace)


* Comparison with covariates
* --------------------------

d hsat stfedu stfgov

* DV and other ESS satisfaction items (edu = education, gov = government).
cap drop msat*
bys cntry lrscale: egen msat1 = mean(hsat)
bys cntry lrscale: egen msat2 = mean(stfedu)
bys cntry lrscale: egen msat3 = mean(stfgov)

* Line graph, using the means computed above for each left-right group. 
tw conn msat1-msat3 lrscale, by(cntry, note("")) ///
	xla(0 "Left" 10 "Right") xti("") yti("Mean level of satisfaction") ///
	legend(row(1) order(1 "Health services" 2 "Education" 3 "Government")) ///
	name(stf_lrscale, replace)

/* Notes:

 - The significance tests are expectedly highly positive due to the large N.
   The risk here is to make Type I errors, even though the variations between
   age groups in each country seem statistically robust.

 - Health status seems important in France but not in Britain, whereas old age
   seems important in Britain but not in France. It will be interesting to see
   if any of these effects persist after controlling for income.

 - The relationship between financial difficulties and political leaning shows
   how your independent variables are interacting with each other.
         
 - Other measures of satisfaction (which are not part of the model itself) show
   how health services correlate to other measures of public sector performance
   when the measures are examined by left-right positioning. Politics matter.
   
*/
 

* =====================
* = REGRESSION MODELS =
* =====================


bys cntry: reg hsat i.age6 female i.health lowinc i.pol3

* Cleaner output.
leanout: reg hsat i.age6 female i.health lowinc i.pol3 if cntry=="FR"
leanout: reg hsat i.age6 female i.health lowinc i.pol3 if cntry=="GB"

* Store model estimates.
eststo clear
bys cntry: eststo: reg hsat i.age6 female i.health lowinc i.pol3

* View standardized coefficients.
esttab, lab wide nogaps beta(2) se(2) mti("FR" "GB")

* Export unstandardized coefficients.
esttab using week10_regressions.txt, ///
	replace lab wide nolines nogaps b(1) se(1) mti("FR" "GB")

/* Notes:

 - On first read, the models seem to do fine: the RMSE indicates a mean error
   of 2 on a scale of 11. Furthermore, both case studies have the same constant,
   which makes it easy to compare from one to the other.

 - Note how some coefficients indicate similar effects (health, sex, income),
   whereas others reveal cross-case differences in either the direction and
   magnitude of the effect (old age) or statistical significance (politics).

 - The -leanout- command makes your model more readable and helps you focus on
   the essentials: coefficients, confidence intervals, root mean square error.
   Use it to read the regression model of each case study.
  
 - The -estout- command works by storing model estimates (eststo) and putting
   them into tables (esttab). Use it at the end of your regression commands:
   begin with -reg-, then -leanout-, then -eststo- (store), then -esttab-.

*/

* ======================
* = SUMMARY STATISTICS =
* ======================


* The next commands are part of the course and will work only if you have
* properly set up your computer for the course. Syntax documentation below.

* Export summary statistics for each country case, with t-tests.
stab using week10b [aw=dweight], ///
	su(hsat age lrscale) corr ///
	fr(female age6 health lowinc pol3) ttest ///
	by(cntry) ///
	replace

* Replicate and export all files and plots to a folder.
repl week10b

/* Syntax of -stab- command:

 - 'using name'  sets the name prefix of the exported file(s)
 - 'su()'        summarizes a list of continuous variables (mean, sd, min-max)
 - 'fre()'       summarizes a list of categorical variables (frequencies)
 - 'ttest'       adds t-tests to categorical values
 - 'corr'        adds a correlation matrix of continuous variables
 - 'by'          produces several tables over a given categorical variable
 - 'replace'     overwrite previous tables
 - '[aw,fw]'     use survey weights
 
 - Usage of -repl- command:
 
 1- set the SRQM folder as the working directory
 2- put your do-file in the Replication folder
 3- put the -repl- command at the end of your do-file
 4- select all your do-file and execute it

   Stata will take a few minutes (or less) to replicate your code and send all tables and saved graphs to a folder. Watch the output of the command on
   
*/


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Thanks for following!
* exit, clear
