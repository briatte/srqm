* What: SRQM Session 12
* Who:  F. Briatte and I. Petev
* When: 2012-01-26


* ================
* = INTRODUCTION =
* ================


* Data: Quality of Government (2011).
use "Datasets/qog2011.dta", clear

* Log.
cap log using "Replication/week12.log", name(week12) replace

* Additional packages
foreach p in estout {
	cap which `p'
	if _rc==111 ssc install `p'
}

* ================
* = DESCRIPTIONS =
* ================


* Rename and recode variables of interest.
ren cname country
ren ccodewb cty
ren wdh_lsbw95_05 happy

recode ht_region ///
	(5=1 "Western Europe & North America") ///
	(1=2 "Eastern Europe & post-Soviet Union") ///
	(2=3 "Latin America") (3/4=4 "Africa") ///
	(6/10=5 "Asia & Pacific") ///
	, gen(region)
la var region "Geographical location"


* DV: Happiness
* -------------

codebook happy

* Critical note: an aggregate measure of happiness is an interesting concept
* that should raise, however, a certain amount of skepticism. The QOG codebook
* links to the source of the data, which documents the psychometric scale used
* calculating both components (life satisfaction and best-worst life). The QOG
* codebook also documents the method aggregation used to compile both scales
* into a single indicator. Even if both methods are separately sensible, their 
* combination has limits: life expectancy is used as multiplicator of both 
* components, causing happiness to be bound to increase with life expectancy.
* Differences in 'country-level happiness' are hence bound to represent, 
* first and foremost, increases in life expectancy. The meaningfulness of that
* relationship ultimately lies in subtantive interpretation of life expectancy
* as either an absolute human preference or as a correlate of other factors
* that can indeed be treated as measures of human happiness. This note should 
* not drive you to go postal about quantification and thereby decree that all 
* things that are relative are just impossible to measure (relativity actually
* ensures the possibility of measurement); nor is it the case that measures of
* happiness will necessarily rely on grounds as shaky as the measure of "gross 
* national happiness" proposed by the former king of Bhutan in 1972. My final
* word is just that the validity and reliability of your interpretation will 
* increase with your actual knowledge of the data.

* Remove observations for which there are no data.
drop if mi(happy)

* Sort data by life satisfaction.
sort happy

* Visualize the dependent variable by geographic region.
gr dot happy, over(region, sort(1) des) exclude0 name(happy_region, replace)

* Obtain the five-number summary, percentiles and normality indicators.
su happy, d

* List the most extreme values, based on the 5th and 95th percentiles.
* The 'Africa vs. Scandinavia', or more simply 'Africa vs. West' pattern will
* come in handy when we introduce dummies for these geographical regions to
* account for areal (i.e. usually continental or sub-continental) variation.
list happy country region if happy < 23.7 | happy > 60.8

* Visualize as a box plot. The total suboption introduces a box plot for the
* whole sample: geographical regions below it have a lower median happiness
* than the whole set of observed countries. We also added a few graph options
* to label potential outliers within each geographical region.
gr hbox happy, over(region, sort(1) des total) mark(1, mlab(cty) ///
	mlabp(6)) scale(.75) name(happy_box, replace)


* Independent variables
* ---------------------

* Rename variables of interest.
ren ffp_fsi state
ren bl_asyf15 edu_f
ren bl_asym15 edu_m
ren ciri_wosoc women
ren fh_press press
ren fh_ep elections
ren fh_ppp politics
ren gle_gdp gdp
ren kk_gg markets
ren wdi_lifexp life
ren wdi_mort infant

* Recoding the ciri_speech variable, which is reverse-coded. The new variable
* will avoid problems of interpretation at some later stages of our analysis.
gen speech = 2-ciri_speech
la var speech "Freedom of Speech"


* =========
* = MODEL =
* =========


* Notes on linear modelling
* -------------------------

* - Our model considers five series of regressors (or predictors; both names
* designate our independent, explanatory variables. The series are thematic
* and correspond to a simple theory: happiness is over-determined by five
* macro-sociopolitical factors (security, wealth, freedom, education, health).
* The factors form a pseudo-pyramid of basic human guarantees that is usually
* handled by nation-states, our unit of analysis.
*
* - We use macros to manipulate the factors more easily across the do-file.
* Macros were already silently introduced in our code as a way to set up nice
* graph options for scatterplots in previous session. Here, the $m1 to $m5
* terms just represent a list of variables: when you read $m3, for instance,
* just replace it mentally with the variables under consideration in our third
* model component, i.e. "speech press women elections politics".
*
* - We finally export all different models (basically three of them) to look
* at the respective contribution of each series of determinants. The estout
* package is used to simplify the export of regression output. See the do-file
* from Week 11 if you need to review how the estout package works.


* Predictors 1: Security
* ----------------------

global m1="state"
d $m1
su $m1
gr mat happy $m1, half name(m1, replace)


* Predictors 2: Wealth
* --------------------

global m2="gdp markets"
d $m2
su $m2
gr mat happy $m2, half name(m2, replace)

* Recoding GDP in log units.
gen log_gdp = ln(gdp)
la var log_gdp "Gross Domestic Product (log units)"
global m2="log_gdp markets"
gr mat happy $m2, half name(m2, replace)


* Predictors 3: Freedom
* ---------------------

global m3="speech press women elections politics"
d $m3
su $m3
gr mat happy $m3, half name(m3, replace)

* Creating a macro for model component #3 where the speech and women variables
* are treated as dummies, as they do not possess enough categories to be ran
* as pseudo-continuous variables in our regression models.
global m3dummies="i.speech press i.women elections politics"


* Predictors 4: Education
* -----------------------

global m4="edu_f edu_m"
d $m4
su $m4
gr mat happy $m4, name(m4, replace)


* Predictors 5: Health
* --------------------

global m5="life infant"
d $m5
su $m5
gr mat happy $m5, name(m5, replace)

* Detect potentially redundant (highly correlated) variables in the last two
* model components, as we have a substantive reason to expect education and
* basic health indicators to co-vary (intuition would actually suffice).
pwcorr happy $m4 $m5, obs sig

* Critical note: the matrix leads us to exclude predictors from series 4-5, 
* which relates to the aforementioned issue of high collinearity between
* our dependent variable and some of our predictors. The issue is extremely
* serious with multiple linear regressions that are built, as this one, from
* a 'kitchen sink' approach, as Philip Schrodt calls them: by listing as many
* independent variables as possible with no serious attention to collinearity.

* We now run the three models separately, and then add them to each other. The
* R-squared is expected to increase, even with adjustment. We also use robust
* standard errors, a simple method to deal with heteroscedasticity. Finally,
* we produce beta (b) coefficients along with unstandardized (B) coefficients.


* Model 1: Security
* -----------------

reg happy $m1, r beta
twoway (scatter happy state) (lfit happy state), name(happy_state, replace)

* Model 2: Wealth
* ---------------

reg happy $m2, r beta

* Model 3: Freedom
* ----------------

reg happy $m3, r beta

* Model 1+2: Security and Wealth
* ------------------------------

reg happy $m1 $m2, r beta

* Model 1+2+3: Security, Wealth and Freedom
* -----------------------------------------

reg happy $m1 $m2 $m3dummies, r beta

* Model selection through nested regression (note that we are treating all our
* variables as continuous for nested regression, which cannot handle dummies).
nestreg: reg happy ($m1) ($m2) ($m3), beta

* Clearly, model component #3 produces only a small increase in R-squared. The
* most satisfactory jump was when we added wealth variables to state security.

* Adding dummies for geographical areas, using Western countries as baseline.
reg happy $m1 $m2 $m3dummies i.region, r beta

* Look at how Western countries are positioned on happiness versus log-GDP.
tw (sc happy log_gdp if region != 1) ///
	(sc happy log_gdp if region==1), yti("Life satisfaction") ///
	legend(label(1 "Non-Western countries") label(2 "Western countries")) ///
	name(happy_west, replace)


* ===============
* = DIAGNOSTICS =
* ===============


* The story of how each diagnostic runs is not told in the do-file. Please
* turn to the course material for details on the first ones, and to the UCLA
* online handbook on linear regression diagnostics (ch. 2) for further help.

* Store the unstandardized residuals.
qui reg happy $m1 $m2 $m3dummies i.region
predict r, resid

* Store the total number of observations considered by the linear model.
count if !mi(r)
global obs = r(N)

* Assess the normality of residuals.
kdensity r, normal legend(off) title("") name(r_kdensity, replace)
pnorm r, name(r_pnorm, replace)
qnorm r, name(r_qnorm, replace)
* More formal tests also exist, like this one.
sktest r


* Multicollinearity
* -----------------

* Variance Inflation Factor (VIF)
vif

* The cut-off points for variance inflation are VIF > 10 or, with the tolerance 
* measure, 1/VIF <.1. Notice how kitchen sink models die from multicollinearity.

* Linearity of predictors in model components #1 and #2.
foreach predictor of varlist $m1 $m2 {
	// (optional)
	// acprplot `predictor', lowess name(diag_acpr_`predictor', replace)
	rvpplot `predictor', yline(0) ms(i) mlab(cty) name(diag_rvp_`predictor', replace)
}


* Heteroscedasticity
* ------------------

* Homoscedasticity of the residuals.
rvfplot, yline(0) name(diag_rvf, replace)

* Heteroscedasticity formal tests.
hettest
imtest

* The first test has a significant p-value, which means that we should reject
* the hypothesis of homogeneous variance in our model residuals. A fundamental
* assumption of linear regression is hence violated at that stage.


* Influential points
* ------------------

* Leverage-versus-residuals plot
lvr2plot, ms(i) mlab(cty) name(reg_lvr, replace)

* Extreme studentized residuals (outliers)
predict rst, rstudent
stem rst
sort rst
list rst cty country if abs(rst) > 2 & !mi(rst), clean N

* High leverage cases > (2k+2)/n
predict l, leverage
stem l
sort l

* Cook's D (depends on the number of observations, stored in $obs)
predict d, cooksd
stem d
sort d
list d cty country if d > 4/$obs & !mi(d), clean N

* Model without influential points
reg happy $m1 $m2 $m3dummies i.region
reg if d < 4/$obs


* Omitted variables
* -----------------

* If this test rejects the null hypothesis, then there is a way to improve
* the model by using a power (i.e. a polynomial) of the dependent variable.
ovtest
* Ouch. Clear rejection.
* Now the same test with the independent ('right hand side') variables.
ovtest, rhs
* Safe at p < 0.01: Retain.

* We could go on like this on and on, but this suffices to ditch the model
* as a very, very weak exercise. It's just that the phenomena considered do
* not behave in a linear fashion, if at all, in the very limited number of
* observations that we managed to include in our kitchen sink exercise. For
* all these reasons, it takes smart researchers to build models and data
* that actually return interesting results beyond mere regression output.


* Export models
* -------------

* Reminder: you will need the estout package from there on.

* Format the Models 1, 2 and 3 regression tables.
eststo clear
eststo: qui reg happy $m1, r beta
eststo: qui reg happy $m2, r beta
eststo: qui reg happy $m3dummies, r beta
esttab, constant label beta(2) se(2) r2(2) mtitles("Security" "Freedom" "Wealth")

* Format the additive models regression tables.
eststo clear
eststo: qui reg happy $m1 $m2, r beta
eststo: qui reg happy $m1 $m2 $m3dummies, r beta
eststo: qui reg happy $m1 $m2 $m3dummies i.region, r beta
esttab, constant label beta(2) se(2) r2(2) nonumber ///
	mtitles("Model 1+2" "Model 1+2+3" "Regional Dummies")


* ============
* = EPILOGUE =
* ============


* Observations:
* - Kitchen sink models (always) die at diagnosis stage.
* - Wealth is the best predictor according to the data.

* Conclusions:
* - We need much better models to handle nonlinearity.
* - We need much better data to observe other factors.

* That's all folks!

* Close log (if opened).
cap log close week12

* We are done. Just quit the application, have a nice life, and see you later!
* exit, clear
