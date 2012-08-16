* What: Example do-file for the final paper
* Who:  François Briatte and Ivaylo Petev
* When: 2012-02-23

* Topic:  Attitudes towards Gender Equality in Europe
* Survey: European Social Survey, Round 4 (2008)
* Sample: N = 24,291

* Hypotheses:
* (H1) Females will support gender equality significantly more than males.
* (H2) Gender equality significantly increases from one age group to another.
* (H3) Socio-economic status will predict attitudes of both sexes.
* (H4) For both males and females, education will be the strongest predictor.

* Note: like previous drafts, this do-file can be used to template your own. As
* the last draft is also your final paper, this is the stage where you need to
* make definite choices about your code, remove all errors and make sure that
* your do-file runs from beginning to end without any issues.


* =========
* = SETUP =
* =========


* Data.
use "Datasets/ess2008.dta", clear

* Create a folder to export all files.
global pwd=c(pwd)
global wd "Replication/BriattePetev" // !note: edit to fill in your own names
cap mkdir "$wd"
cd "$wd"

* Log.
cap log using "draft3.log", name(draft3) replace

* This do-file uses a graph scheme by Edwin Leuven for its figures.
cap net from "http://leuven.economists.nl/stata"
cap net install schemes
cap set scheme bw

* Subsetting to variables used in the analysis.
keep cntry idno *weight ///
	mnrgtjb agea gndr lrscale hinctnta eduyrs edulvla rlgblg rlgdnm tvpol

* Set design weights (used only for illustrative purposes).
svyset [pw=dweight]


* ================
* = DESCRIPTIONS =
* ================


* List.
codebook, c

// Description:

* (a) DV
*
* "Men should have more right to job than women when jobs are scarce"
* (5-pt scale, 1 = Agree strongly.)
*
hist mnrgtjb, discrete

gen geq = mnrgtjb
la var geq "Support for gender equality"

su geq, d
global ymean=r(mean) // store mean value, to display in graphs

* (b) Age
*
* Create groups for 20-year intervals of age (useful for graphs and tables).
*
su agea

gen age20=floor(agea/20)*20
replace age20=. if age20 > 80 // remove a few very old outliers
tab age20 // note: group called '0' includes 15-19 years-olds

* (c) Gender
*
* Create dummy for females.
* Males will be the reference category in regressions.
*
gen female = (gndr==2)

la de female 0 "Male" 1 "Female"
la val female female

table female, c(n geq mean geq p25 geq p50 geq p75 geq)

* ... males are mostly distributed over answers 2-4, females 3-5: although mean
* support might look rather similar, clear distributional differences exist.

* (d) Wealth
*
* Measured in income deciles.
*
gen income = hinctnta

* Recoding to 4 income groups.
recode income (1/3=1 "D1-D3") (4/6=2 "D4-D6") ///
	(7/9=3 "D7-D9") (10=4 "D10"), gen(inc4)

* Crosstabulation, Chi-squared test.
tab geq inc4, col nof chi2

* (e) Education
*
* Measured in years of schooling.
*
gen edu = eduyrs

* Verify normality.
hist edu, bin(15) normal
kdensity edu if edu < 25, normal // corrected version, squishes outliers
replace edu=25 if edu > 25

* Comparison of average educational attainment in the two extreme DV categories.
ttest edu if geq==1 | geq==5, by(geq)

* ... statistically significant gap of roughly four years of education between
* strong opponents of gender equality and strong supporters.

* (f) Religion
*
* Two categorical measures: religious or not (binary), denomination (nominal).
*
fre rlgblg rlgdnm

gen religious = (rlgblg==1)

la de religious 0 "Non-religious" 1 "Religious"
la val religious religious

* Recoding to simpler groups.
recode rlgdnm (.a=1 "Not religious") (1/4=2 "Christian") ///
	(5=3 "Jewish") (6=4 "Muslim") (7/8=.) , gen(faith)
la var faith "Religious faith"

* Create dummies (useful later on).
tab faith, gen(faith_)

* Crosstabulation, Chi-squared test.
tab geq faith, col nof chi2

* (g) Political positioning
*
gen pol = lrscale

* Verifying normality.
hist pol, discrete

* Recoding to simpler categories
recode pol (0/4=1 "Left") (5=2 "Centre") (6/10=3 "Right"), gen(pol3)
la var pol3 "Political positioning"

* Crosstabulation, Chi-squared test.
tab geq pol3, col nof chi2

// Visualization:

// ... by country
gr dot geq, over(cntry, sort(1)des) scale(.75) ///
	yline($ymean, lp(dash)) ///
	yti("Support for gender equality") ///
	name(dv_age_sex, replace)

// ... by age and sex
gr bar geq [pw=dweight], over(age20) ///
	by(gndr, note("Horizontal line at sample average.")) ///
	yti("Support for gender equality") ///
	yline($ymean, lp(dash)) ///
	name(dv_age_sex, replace)

// ... by income decile
gr bar geq [pw=dweight], over(income) ///
	by(gndr, note("Horizontal line at sample average.")) ///
	yti("Support for gender equality") ///
	yline($ymean, lp(dash)) ///
	name(dv_income, replace)

// ... by age, sex and religious belief
gr bar geq, over(age20) over(female) ///
	by(religious, note("Horizontal line at sample average.")) ///
	yti("Support for gender equality") ///
	yline($ymean, lp(dash)) ///
	name(dv_age_sex_religion, replace)

// ... within each major faith group
spineplot geq faith, xlab(,alt axis(2)) ///
	scheme(paired) name(dv_faith, replace)

// ... at each level of left-right positions
spineplot geq pol, xti("Left/Right", axis(2)) ///
	scheme(paired) name(dv_pol, replace)



* Summary statistics
* ------------------



* Correlation
* -----------



// Correlation matrix:

* Spearman coefficients.
spearman geq agea income edu lrscale, star(.05)

* Reminder: spearman is pwcorr for ordinal data. Spearman's correlation uses
* ranks instead of values to measure associations, which is more appropriate
* for ordinal data like k-point scales or other lowly dimensional measures.

* The correlational pattern is interesting: the coefficients of negative predictors
* of gender equality (age, right-wing) are lower than positive predictors, like
* income and education. There are also a lot of IV interactions to deal with.


* Export correlation matrix.
eststo clear
estpost correlate geq agea income edu lrscale, matrix listwise // correlate
esttab using correlates.csv, unstack not compress label replace // export



eststo clear
qui estpost correlate births sqrt_schooling log_gdpc aids, matrix listwise
esttab using corr.csv, unstack not compress label replace // export


* =========
* = MODEL =
* =========


// Multiple regression:

reg geq agea i.female income edu i.faith lrscale // use full model straight away
reg, beta

* ... the standardised coefficients are most informative here, as the effects 
* are quite mixed overall, but test our hypotheses as goes:
*
* (H1) positive female dummy means females are overall more supportive of gender
* equality, independently of differences in socio-economic conditions
*
* (H2) age and religion are both significant negative predictors of support for
* gender equality; the precise effect of age will require more analysis below
*
* (H3) the general fit of the model confirms that the list of predictors made
* sense, even if the relatively low R-squared means 80% unpredicted variance.
*
* (H4) education is the best positive predictor, and second overall; we cannot
* rely so much on beta coefficients, so the exact order is better left unknown.

// studying sex*religion interaction
reg geq agea i.female#i.faith income edu lrscale

// studying sex*education
reg geq agea i.female##c.edu i.faith income lrscale

// Diagnostics:

* Generate 
reg geq agea i.female income edu i.faith lrscale    // re-estimate full model

predict rst, rsta  // store standardized residuals

reg geq agea i.female income edu i.faith lrscale, r // robust standard errors

predict yhat       // store fitted values
predict r, resid   // store residuals

* Residuals.
kdensity r, normal  // assess normality
pnorm r
qnorm r

* Residuals vs. fitted values.
sc r yhat, yline(0) // assess homoscedasticity
rvfplot, yline(0)   // equivalent to above

* Residuals vs. predictors.
rvpplot agea, yline(0)
rvpplot income, yline(0)
rvpplot edu, yline(0)
rvpplot lrscale, yline(0)

* Outliers
sc rst yhat, yline(-2 0 2, lp(dash)) || ///
	sc rst yhat if abs(rst) > 2, ms(Oh) mc("$red") legend(off)

// variance
vif

// block modeling
nestreg: reg geq (agea female) (income edu) (lrscale)

// cluster by country


* Export models
* -------------

eststo clear // clear memory
eststo m1: qui logit geq1 agea i.female#i.faith income edu lrscale // model 1
eststo m2: qui logit geq1 agea i.female income edu lrscale // model 2
eststo m3: qui logit geq1 agea i.female#i.faith income edu // model 3
esttab m1 m2 m3, nogaps mtitles("Full model" "No religion" "No politics") // with titles
esttab m1 m2 m3 using models.csv, mtitles("Full model" "No religion" "No politics") replace // export


* =======
* = END =
* =======


* Close log (if opened).
cap log close draft3

* Reset working directory.
cd "$pwd"


* ==========
* = BONUS! =
* ==========


* A primer to logistic regression
* -------------------------------

* ... the model makes reasonably uniform predictions, without any apparent trace
* of excessive multicollinearity or anomalies in the residuals, but the linear
* assumption is violated by our not-very-normal dependent variable, so we switch
* to logit for regression with categorical data:

// create a dummy for opposing gender equality
gen geq1 = (mnrgtjb < 3) if !mi(mnrgtjb)

// logistic regression
logit geq1 agea i.female#i.faith income edu lrscale, nolog

* ... the model computes the marginal increase or decrease in probability that
* one unit of the IV creates in the DV; here, it predicts opposition to gender
* equality over the same list of covariates as used in linear regression.

* ... the negative coefficients indicate that young, educated female atheists
* are the least likely to oppose gender equality; the positive coefficients show
* that old right-wing males with religious beliefs will be most likely to do;
* the results are unsurprising so far, but the odds ratios are more informative:

logit geq1 agea i.female#i.faith income edu lrscale, nolog or

// muslim males and females are many more times susceptible to fit the dependent
// variable, but the conjugated effects of income and education are noticeable
// too; what we might conclude needs clarification at that stage

// marginal effects
margins female#faith, asbalanced
marginsplot, x(faith) scheme(set1)

* ... this plot shows the marginal effects of each religion in each gender group
* and clarifies the confusion about Jewish women, for the which the coefficient
* is not statistically differentiable from Jewish males.

// finally, ordered logit equivalent:
ologit geq agea i.female#i.faith income edu lrscale, nolog


* We are done. Thanks for following!
* exit
