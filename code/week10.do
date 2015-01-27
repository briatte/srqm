
* Check setup.
run setup/require estout fre tab_chi renvars scheme-burd

* Allow Stata to scroll through the results.
set more off

* Log results.
cap log using code/week10.log, replace

/* ------------------------------------------ SRQM Session 10 ------------------

   F. Briatte and I. Petev

 - TOPIC:  Attitudes Towards Immigration in Europe
 
 - DATA:   European Social Survey Round 4 (2008)

   This do-file complements the series that we finished running last week using
   the Quality of Government dataset. It shows how multiple regression can apply
   to survey data, and introduces a different form of regression model.
   
   Survey data commonly feature response items that are discrete rather than 
   continuous. This means that linear regression models will be of limited use
   with this type of data.
   
   When the dependent variable cannot be normaly distributed, a solution is to 
   simplify it to a dummy and to estimate a logistic regression model, which is
   a generalization of the linear model.
   
   This do-file introduces logistic models. For your own work, decide whether a
   logistic estimator is more appropriate than a linear one, and include draft
   models in your revised draft.
   
   Last updated 2013-08-17.

----------------------------------------------------------------------------- */

* Load ESS dataset.
use data/ess0810, clear

* Subsetting to respondents age 25+ with full data.
drop if agea < 25 | mi(imdfetn, agea, gndr, brncntr, eduyrs, hinctnta, lrscale)

* Survey weights (design weight by country, multiplied by population weight).
gen dpw = dweight * pweight
la var dpw "Survey weight (population*design)"

* Country dummies (used for clustered standard errors).
encode cntry, gen(cid)


* DV: Allow many/few immigrants of different race/ethnic group from majority
* --------------------------------------------------------------------------

fre imdfetn

* Relabel for concise legends in graphs.
la def imdfetn 1 "Many" 2 "Some" 3 "Few" 4 "None", replace

* Normality: distribution shows symmetricality but the reduced number of items
* on a 4-point scale limits variability and will create postestimation issues.
hist imdfetn, discrete percent addl ///
	name(dv, replace)

* Dummy: 1 = allow many/some immigrants.
gen diff = (imdfetn < 3)
la var diff "Allow many/some migrants of different race/ethnicity from majority"


* IVs: age, gender, country of birth, education, income, left-right scale
* -----------------------------------------------------------------------

d agea gndr brncntr eduyrs hinctnta lrscale

* Renaming.
renvars agea hinctnta lrscale \ age income rightwing

* Create age groups.
gen cohort = irecode(age, 24, 34, 44, 54, 64, 74)
replace cohort = 15 + 10 * cohort

* Dummify sex.
gen female:sex = (gndr == 2)
la def sex 0 "Male" 1 "Female", replace

* Dummify country of birth.
gen born:born = (brncntr == 1)
la def born 0 "Foreign-born" 1 "Born in country", replace

* Recode education years.
su eduyrs, d
xtile edu3 = eduyrs if eduyrs < 22, nq(3)
la var edu3 "Education level"
la def edu3 1 "Low" 2 "Medium" 3 "High"
la val edu3 edu3


* Export summary statistics
* -------------------------

* The next command is part of the SRQM folder. If Stata returns an error when
* you run it, set the folder as your working directory and type -run profile-
* to run the course setup, then try the command again. If you still experience
* problems with the -stab- command, please send a detailed email on the issue.

stab using week10_stats.txt, replace ///
	mean(age rightwing) ///
	prop(imdfetn female born edu3 income)

/* Syntax of the -stab- command:

 - using FILE  - name of the exported file; plain text (.txt) recommended
 - replace     - overwrite any previously existing file
 - mean()      - summarizes a list of continuous variables (mean, sd, min, max)
 - prop()      - summarizes a list of categorical variables (frequencies)

  In the example above, the -stab- command will export one file to the working
  directory, containing summary statistics for the full European sample. */


* =====================
* = ASSOCIATION TESTS =
* =====================


* Dummify the DV categories.
tab imdfetn, gen(immig_)

* Crossvisualize DV with basic demographics.
gr bar immig_*, stack percent over(cohort) by(female born, note("")) yti("") ///
	legend(order(1 "Many" 2 "Some" 3 "Few" 4 "None") row(1)) ///
	scheme(burd4) name(demog, replace)

* Crosstabulation: DV by gender.
tab female imdfetn, row nof chi2 // Chi-squared test
tabchi female imdfetn, p noo noe // Pearson residuals

* Crosstabulation: DV by country of birth.
tab born imdfetn, row nof chi2
tabchi born imdfetn, p noo noe

* Crosstabulation: DV by age cohort.
tab cohort imdfetn, row nof chi2
tabchi cohort imdfetn, p noo noe

* Dummify educational attainment.
tab edu3, gen(edu_)

* Clarify x-axis by dropping labels on income deciles.
la def inc10 1 "D1" 10 "D10", replace
la val income inc10

* Visualization of education with income, sex and country of birth.
gr bar edu_*, stack percent over(income) by(female born, note("")) yti("") ///
	legend(order(1 "Low" 2 "Medium" 3 "High") row(1) pos(11)) ///
	scheme(burd3) name(edu_inc, replace)

* Simplified political scale.
recode rightwing ///
	(0/4  = 1 "Left-wing")  ///
	(5    = 2 "Centre")     ///
	(6/11 = 3 "Right-wing") ///
	(else = .), gen(wing)
tab wing, gen(wing_)

* Visualization of left-right political leaning by income decile and age cohort.
gr bar wing_*, stack percent over(income) by(cohort, note("")) yti("") ///
	legend(order(1 "Left-wing" 2 "Centre" 3 "Right-wing") row(1)) ///
    scheme(burd3) name(pol_inc, replace)

* Crosstabulation.
tab income wing, row nof chi2
tabchi income wing, p noo noe


* =====================
* = REGRESSION MODELS =
* =====================


* Linear regression
* -----------------

global bl "age i.female i.born i.edu3 income rightwing" // store IV names

* Baseline OLS model.
reg imdfetn $bl [pw = dpw]

* Adjusted OLS model: observations clustered by country.
reg imdfetn $bl [pw = dpw], vce(cluster cid)

* The last option reads as 'variance-covariance estimation is clustered by cid'.
* This specification enforces robust standard errors into the model. It uses the
* respondents' country of residence as a panel variable in the estimation of all
* regression coefficients. Panel variables are variables at which level we might
* observe some form of within-sample clustering, which violates the assumption
* that the error term is independently distributed across the observations.

* Variance inflation.
vif

* Inspect residuals.
predict r, resid

* Diagnostic plots.
hist r, normal ///
	name(r, replace)   // distribution of residuals
rvfplot, yli(0) ///
	name(rvf, replace) // residuals vs. fitted values

* Export.
eststo clear
eststo lin_1: reg imdfetn $bl [pw = dpw]
eststo lin_2: reg imdfetn $bl [pw = dpw], vce(cluster cid)
esttab lin_? using week10_regressions.txt, mti("OLS" "Adj. OLS") replace

* The diagnostics clearly identify the issue here: the limited number of levels
* in the DV is causing residuals to follow a low-dimensional pattern that does
* not approximate a normal distribution. The residuals, for instance, follow a
* quadrimodal distribution that reflect the number of levels in the DV. The data
* therefore fail to fit the assumptions of the model by design.

* We turn to a logistic regression (logit) model, which accepts only dichotomous
* outcomes. The binary/dummy recoding of the DV was computed earlier as follows:
tab diff imdfetn

* You are very welcome to consult the UCLA Stata FAQ pages to learn how logistic
* regression works if you are interested in estimating a logit model. Otherwise,
* just follow the code and comments below to get some basic ideas. The following
* is a very short demo: it would take a full course to explain logistic models
* properly, and you are very welcome to ask for one :)


* Logistic regression
* -------------------

* Binarize the DV again to have 1 = no immigrants.
gen nomigrants = (imdfetn > 2)

* Column percentages (conditional probabilities).
tab cohort nomigrants, col nof

* Log-odds of f = ln(Y = 1).
tabodds nomigrants cohort

* Odds ratios: magnitude of success-failure rate.
tabodds nomigrants cohort, or

* Logistic regression with log-odds.
logit nomigrants i.cohort

* Logistic regression with odds ratios.
logit nomigrants i.cohort, or

* Baseline model.
logit nomigrants $bl [pw = dpw] // coefficients are log-odds

* Log-odds are variations in the probability of the DV. Negative log-odds imply
* that an increase in the IV, or the presence of it, reduces the probability of
* the DV being equal to 1. Log-odds can be compared by magnitude, but at that
* stage, it is usually simpler to read only the sign of the coefficient and its
* significance level (p-value, closeness of confidence interval bounds to zero).

* Odds ratios.
logit nomigrants $bl [pw = dpw], or

* Odds ratios provide an easier means of comparison between coefficients: for
* example, in this model, completing upper secondary education increases the
* likelihood of allowing migrants from different groups by a factor of 2.03,
* i.e. higher-educated respondents are twice more likely than others to have
* answered "Some" or "Many" to the original question.

* Adjusted model.
logit nomigrants $bl [pw = dpw], vce(cluster cid)

* Odds ratios.
logit nomigrants $bl [pw = dpw], vce(cluster cid) or

* Export.
eststo clear
eststo log_1: logit nomigrants $bl [pw = dpw]
eststo log_2: logit nomigrants $bl [pw = dpw], vce(cluster cid)
esttab log_? using week10_logits.txt, mti("Logit" "Adj. logit") replace


* Marginal effects
* ----------------

* Note: this section runs properly only on Stata 12+. If you are using an older
* version of Stata, you will be able to execute the -margins- commands, but not
* the -marginsplot- commands.
if c(version) > 11 {

	* Marginal effect of political attitude: estimated probability of DV at each
	* level of the 11-point left/right scale used in the model, with all other
	* factors kept constant (demographics, education and income).
	margins, at(rightwing = (0(1)10))
	marginsplot, xla(minmax) recast(line) recastci(rarea) ciopts(col(*.6)) ///
		name(mfx_right, replace)

	* Marginal effect of educational attainment, by gender and country of birth.
	* The -margins- command will generate estimate for all possible permutations
	* of the IV list provided, and then plot them as confidence intervals.
	margins born#female, at(edu3 = (1(1)3))
	marginsplot, xla(minmax) by(female born) ///
		name(mfx_demog, replace)

	* Effect of increasing age on the probability of the DV being equal to 1, by
	* sex and country of birth. The overlap in confidence intervals illustrates
	* the weak value of age as a predictor for the DV: the marginal effect of 
	* age is residual in the model, at least in comparison to other predictors.
	margins born#female, at(age=(25(5)85))
	marginsplot, by(female) recast(line) recastci(rarea) ciopts(col(*.6)) ///
		name(mfx_age, replace)

}

* Sensitivity analysis
* --------------------

* Ordered logistic regression, to test the cut point that we chose when recoding
* the DV to a dummy. The results should show identical signs on the coefficients
* and their order of magnitude should also stay stable. If not, then the model
* is sensitive to the choice of cutoff point that we made earlier. Note that in
* our example, the signs of the coefficients should actually be the same for the
* OLS (linear regression) and ordered logit, not for the logit (the logit codes
* the dummy in reverse order to the original variable).
ologit imdfetn $bl [pw = dpw], vce(cluster cid)


* Export model results
* --------------------

eststo clear
eststo lin_1: qui reg imdfetn $bl [pw = dpw], b
eststo lin_2: qui reg imdfetn $bl [pw = dpw], vce(cluster cid)
eststo log_1: qui logit nomigrants $bl [pw = dpw]
eststo log_2: qui logit nomigrants $bl [pw = dpw], vce(cluster cid)
eststo log_3: qui ologit imdfetn $bl [pw = dpw], vce(cluster cid)
esttab lin_* log_* using week10_models.txt, constant label beta(2) se(2) r2(2) ///
	mti("OLS" "Adj. OLS" "Logit" "Adj. logit" "Ord. logit") replace


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Thanks for following! And all the best for the future.
* exit, clear
