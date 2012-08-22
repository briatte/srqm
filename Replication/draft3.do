* What: Example do-file for the final paper
* Who:  F. Briatte and I. Petev
* When: 2012-08-17

* Topic:  Attitudes towards immigration in Europe
* Survey: European Social Survey, Round 4 (2008)
* Sample: N = 28,178

* Note: like previous drafts, this do-file can be used to template your own. As
* the last draft is also your final paper, this is the stage where you need to
* make definite choices about your code, remove all errors and make sure that
* your do-file runs from beginning to end without any issues.

* Required packages (uncomment to install).
* ssc install fre, replace
* ssc install spineplot, replace
* ssc install tab_chi, replace
* ssc install estout, replace


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

* Use the black and white graph scheme by Edwin Leuven for figures.
cap net from "http://leuven.economists.nl/stata"
cap net install schemes
cap set scheme bw

* Log.
//cap log using "draft3.log", name(draft3) replace

* Subsetting to respondents age 25+ with full data.
drop if age < 25 | mi(imdfetn,agea,gndr,brncntr,edulvla,hinctnta,lrscale)

* Subsetting to variables used in the analysis.
keep cntry idno *weight imdfetn agea gndr brncntr edulvla hinctnta lrscale
 
* Survey weights (design weight by country, multiplied by population weight for
* each country in reference to country contribution to European population).
gen dpw=dweight*pweight
la var dpw "Population*Design survey weights"

* Create country dummies (used for clustering).
encode cntry, gen(cid)


* ================
* = DESCRIPTIONS =
* ================


* List.
codebook, c


* DV: Allow many/few immigrants of different race/ethnic group from majority
* --------------------------------------------------------------------------
fre imdfetn

* Relabel for concise legends in graphs.
la de imdfetn 1 "Many" 2 "Some" 3 "Few" 4 "None", replace

* Normality: distribution shows symmetricality but the reduced number of items
* on a 4-point scale limits variability and will create postestimation issues.
hist imdfetn, discrete percent addl name(dv, replace)

* Dummy: 1 = allow many/some immigrants.
gen diff = (imdfetn < 3)
la var diff "Allow many/some immigrants of different race/ethnic group from majority"


* IVs: age, gender, country of birth, education, income, left-right scale
* -----------------------------------------------------------------------
d agea gndr brncntr edulvla hinctnta lrscale

* Renaming.
ren (agea hinctnta lrscale) (age income rightwing)

* Dummies:
gen female:sex=(gndr==2)
la de sex 0 "Male" 1 "Female"

gen born:born=(brncntr==1)
la de born 0 "foreign-born" 1 "born in country"

* Collapse some educational categories.
recode edulvla (1 2=1 "Low") (3=2 "Medium") (4 5=3 "High") (else=.), gen(edu3)
la var edu3 "Education level"


* Summary statistics
* ------------------

* Export with tsst command.
tsst using draft3-stats.txt, su(age rightwing) fre(imdfetn female born edu3) replace


* Associations
* ------------

* Dummify the DV.
tab imdfetn, gen(immig_)

* Create age groups.
gen cohort = irecode(age,24,34,44,54,64,74)
replace cohort = 25 + 10*(cohort - 1)

* Crossvisualize DV with basic demographics (age, sex and country of birth).
gr bar immig_*, stack percent over(cohort) yti("") ///
	legend(lab(1 "Many") lab(2 "Some") lab(3 "Few") lab(4 "None") rows(1)) ///
	by(female born, note("")) name(demog, replace)

* Crosstabulation.
tab female imdfetn, row nof chi2 V // Chi-squared test and Cramer's V
tabchi female imdfetn, p noo noe   // Pearson residuals

tab born imdfetn, row nof chi2 V
tabchi born imdfetn, p noo noe

tab cohort imdfetn, row nof chi2 V
tabchi cohort imdfetn, p noo noe

* Dummify educational attainment.
tab edu3, gen(edu_)

* Clarify x-axis by dropping labels on income deciles.
la de inc10 1 "D1" 10 "D10", replace
la val income inc10

* Visualization of education with income, sex and country of birth.
gr bar edu_*, stack percent over(income) yti("") ///
	legend(lab(1 "Low") lab(2 "Medium") lab(3 "High") rows(1)) ///
	by(female born, note("")) name(edu_inc, replace)

* Crosstabulation.
bys female born: tab income edu3, row nof chi2 V // computed for each subgroup
tabchi income edu3, p noo noe

* Simplified political scale.
recode rightwing (0/4=1 "Left-wing") (5=2 "Centre") (6/11=3 "Right-wing"), gen(wing)
tab wing, gen(wing_)

* Visualization of left-right political leaning by income decile and age cohort.
gr bar wing_*, stack percent over(income) yti("") ///
	legend(lab(1 "Left-wing") lab(2 "Centre") lab(3 "Right-wing")) ///
	by(cohort, note("")) legend(rows(1)) name(pol_inc, replace)

* Crosstabulation.
tab income wing, row nof chi2 V
tabchi income wing, p noo noe


* Correlation
* -----------

pwcorr imdfetn age edu3 income rightwing

* Export correlation matrix.
eststo clear
estpost correlate imdfetn age edu3 income rightwing, matrix listwise
esttab using draft3-corr.csv, unstack not compress label replace


* =========
* = MODEL =
* =========


* Note: for each model, we produce baseline estimates on the weighted data and
* then adjust for potential within-country clustering by using robust standard
* errors that are heteroskedasticity-consistent. We also add some diagnostics,
* some marginal effects and some sensitivity tests, for illustrative purposes.
* For this course, you are only required to run your linear regression model 
* and its diagnostics.


* Linear regression
* -----------------

global bl = "age i.female i.born i.edu3 income rightwing" // store IV names

* Baseline model.
reg imdfetn $bl [pw=dpw], b

* Adjusted model.
reg imdfetn $bl [pw=dpw], vce(cluster cid)

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
hist r, normal name(r, replace) // distribution of residuals
rvfplot, name(rvf, replace)     // residuals versus fitted values

* Export.
eststo clear
eststo lin_1: qui reg imdfetn $bl [pw=dpw], b
eststo lin_2: qui reg imdfetn $bl [pw=dpw], vce(cluster cid)
esttab lin_* using draft3-lin.csv, mtitles("Baseline OLS" "Adjusted OLS") replace

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

* Baseline model.
logit diff $bl [pw=dpw] // coefficients are log-odds* Log-odds are variations in the probability of the DV. Negative log-odds imply
* that an increase in the IV, or the presence of it, reduces the probability of
* the DV being equal to 1. Log-odds can be compared by magnitude, but at that
* stage, it is usually simpler to read only the sign of the coefficient and its
* significance level (p-value, closeness of confidence interval bounds to zero).* Odds ratios.
logit diff $bl [pw=dpw], or

* Odds ratios provide an easier means of comparison between coefficients: for
* example, in this model, completing upper secondary education increases the
* likelihood of allowing migrants from different groups by a factor of 2.03,
* i.e. higher-educated respondents are twice more likely than others to have
* answered "Some" or "Many" to the original question.
* Adjusted model.logit diff $bl [pw=dpw], vce(cluster cid)

* Odds ratios.
logit diff $bl [pw=dpw], vce(cluster cid) or

* Export.
eststo clear
eststo log_1: qui logit diff $bl [pw=dpw]
eststo log_2: qui logit diff $bl [pw=dpw], vce(cluster cid)
esttab log_* using draft3-log.csv, mtitles("Baseline logit" "Adjusted logit") replace


* Marginal effects
* ----------------

* Marginal effects of political attitude: estimated probability of DV at each
* level of the 10-point left/right scale used in the model, all other factors
* kept constant (demographics, education and income).
margins, at(rightwing=(0(1)10))
marginsplot, xlab(minmax) recast(line) recastci(rarea) ciopts(col(*.6)) name(mfx_right, replace)

* Marginal effects of educational attainment, by gender and country of birth.
* The margins command will generate estimate for all possible permutations of
* the IV list provided, and then plot them as confidence intervals.
margins born#female, at(edu3=(1(1)3))
marginsplot, xlab(minmax) by(female born) name(mfx_demog, replace)

* Effect of increasing age on the probability of the DV being equal to 1, by sex
* and country of birth. The overlap in confidence intervals illustrates the weak
* value of age as a predictor for the DV: the marginal effect of age is residual
* in the model, at least in comparison to other predictors.
margins born#female, at(age=(25(5)85))
marginsplot, by(female) name(mfx_age, replace)

* Sensitivity analysis* --------------------* Ordered logistic regression, to test the cut point that we chose when recoding
* the DV to a dummy. The results should show identical signs on the coefficients
* and their order of magnitude should also stay stable. If not, then the model
* is sensitive to the choice of cutoff point that we made earlier. Note that in
* our example, the signs of the coefficients should actually be the same for the
* OLS (linear regression) and ordered logit, not for the logit (the logit codes
* the dummy in reverse order to the original variable).ologit imdfetn $bl [pw=dpw], vce(cluster cid)* Export all models
* -----------------

eststo clear
eststo lin_1: qui reg imdfetn $bl [pw=dpw], b
eststo lin_2: qui reg imdfetn $bl [pw=dpw], vce(cluster cid)eststo log_1: qui logit diff $bl [pw=dpw]
eststo log_2: qui logit diff $bl [pw=dpw], vce(cluster cid)
eststo log_3: qui ologit imdfetn $bl [pw=dpw], vce(cluster cid)
esttab lin_* log_* using draft3-models.csv, constant label beta(2) se(2) r2(2) ///
	mtitles("Baseline OLS" "Adjusted OLS" "Baseline logit" "Adjusted logit" "Ordered logit") replace


* =======
* = END =
* =======


* Close log (if opened).
cap log close draft3

* Reset working directory.
cd "$pwd"
* We are done. Thanks for following! And all the best for the future.
* exit
