
* Check setup.
run setup/require estout fre leanout renvars scheme-burd spineplot

* Allow Stata to scroll through the results.
set more off

* Log results.
cap log using code/week11.log, replace

/* ------------------------------------------ SRQM Session 11 ------------------

   F. Briatte and I. Petev

 - TOPIC:  Satisfaction with Health Services in Britain and France
 
 - DATA:   European Social Survey Round 4 (2008)

   We explore patterns of satisfaction with the state of health services in
   the UK and France, two countries with extensive public healthcare systems
   and where health services play different roles in political competition.

 - (H1): We expect to observe high satisfaction on average, except among those
   in ill health, who we expect to report lower satisfaction regardless of age,
   sex, income or political views.

 - (H2): We also expect respondents in political opposition to the government to
   report less satisfaction with the state of health services in the country,
   independently of all other characteristics.

 - (H3): We finally expect to find lower patterns of satisfaction among those
   who report financial difficulties, as evidence of an income effect that
   we expect to exist in isolation of all others.

   We use data from the European Social Survey (ESS) Round 4. The sample used in
   the analysis contains N = 1,942 French and N = 2,079 UK individuals selected
   through stratified probability sampling and interviewed face-to-face in 2008.

   We run linear regressions for each country to assess whether satisfaction
   with health services can be predicted from political views, independently
   of age, sex, health status and financial situation.
   
   Last updated 2013-08-17.

----------------------------------------------------------------------------- */

* Load ESS dataset.
use data/ess0810, clear

* Country-specific design weight, multiplied by country-level population weight.
gen dpw = dweight * pweight
la var dpw "Survey weight (population * design)"

* Survey weights.
svyset [pw = dpw]

* Country dummies (used for clustered standard errors).
encode cntry, gen(cid)


* Dependent variable
* ------------------

d stf*

* Rename DV and a bunch of covariates
renvars stfhlth stfedu stfgov \ hsat esat gsat

* Country-specific distributions.
tab cntry, su(hsat)
hist hsat, discrete by(cntry, note("")) ///
	name(dv_bins, replace)

* Detailed summary statistics.
su hsat, d


* Cross-country comparisons
* -------------------------

* Cross-country visualization (mean).
gr dot hsat, over(cntry, sort(1)des) yla(0 "Min" 10 "Max") ///
    yti("Satisfaction in health services") ///
    name(dv_dots, replace)

* Cross-country visualization (median).
gr box hsat, noout over(cntry, sort(1)des) yla(0 "Min" 10 "Max") ///
    yti("Satisfaction in health services") ///
    name(dv_boxes, replace)

* Generate dummies for the full 11-pt scale DV.
cap drop hsat11_*
tab hsat, gen(hsat11_)

* Cross-country visualization (proportions).
gr hbar hsat11_*, over(cntry, sort(1)des) stack legend(off) ///
    yti("Satisfaction in health services") ///
    scheme(burd11) name(dv_bars, replace)


* Independent variables
* ---------------------

fre agea gndr health hincfel lrscale, r(10)

* Recode sex to dummy.
gen female:female = (gndr == 2) if !mi(gndr)
la def female 0 "Male" 1 "Female", replace
la var female "Gender"

* Fix age variable name.
ren agea age

* Generate six age groups (15-24, 25-34, ..., 65+).
gen age6:age6 = irecode(age, 24, 34, 44, 54, 64, .)
replace age6 = 10 * age6 + 15
la def age6 15 "15-24" 25 "25-34" 35 "35-44" ///
	45 "45-54" 55 "55-64" 65 "65+", replace
la var age6 "Age groups"

* Subjective low income dummy.
gen lowinc = (hincfel > 2) if !mi(hincfel)
la var lowinc "Subjective low income"

* Recode left-right scale.
recode lrscale (0/4 = 1 "Left") (5 = 2 "Centre") (6/10 = 3 "Right"), gen(pol3)
la var pol3 "Political views (left-right)"


* Subsetting
* ----------

* Check missing values.
misstable pat hsat age6 female health pol3 lowinc if cntry == "FR"
misstable pat hsat age6 female health pol3 lowinc if cntry == "GB"

* Select case studies.
keep if inlist(cntry, "FR", "GB")

* Delete incomplete observations.
drop if mi(hsat, age6, female, health, pol3, lowinc)

* Final sample sizes.
bys cntry: count


* Normality
* ---------

* Distribution of the DV in the case studies.
hist hsat, discrete normal xla(0 10) by(cntry, legend(off) note("")) ///
    name(dv_histograms, replace)

* Generate strictly positive DV recode.
gen hsat1 = hsat + 1

* Visual check of common transformations.
gladder hsat1, bin(11) ///
   name(gladder, replace)

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
   reasonable to carry on with the untransformed DV. */


* Export summary statistics
* -------------------------

* The next command is part of the SRQM folder. If Stata returns an error when
* you run it, set the folder as your working directory and type -run profile-
* to run the course setup, then try the command again. If you still experience
* problems with the -stab- command, please send a detailed email on the issue.

stab using week11_stats_FR.txt if cntry == "FR", replace ///
  mean(hsat) ///
  prop(female age6 health lowinc pol3)

stab using week11_stats_GB.txt if cntry == "GB", replace ///
  mean(hsat) ///
  prop(female age6 health lowinc pol3)

/* Syntax of the -stab- command:

 - using FILE  - name of the exported file; plain text (.txt) recommended
 - replace     - overwrite any previously existing file
 - mean()      - summarizes a list of continuous variables (mean, sd, min, max)
 - prop()      - summarizes a list of categorical variables (frequencies)

  In the example above, the -stab- command will export two files to the working
  directory, containing summary statistics for France (week11_stats_FR.txt) and
  Britain (week11_stats_GB.txt). */


* =====================
* = ASSOCIATION TESTS =
* =====================


* Relationships with socio-demographics
* -------------------------------------

* Line graph using DV means computed for each age and gender group.
cap drop msat_?
bys cntry age6: egen msat_1 = mean(hsat) if female
bys cntry age6: egen msat_2 = mean(hsat) if !female
tw conn msat_? age6, by(cntry, note("")) ///
    xti("Age") yti("Mean level of satisfaction") ///
    legend(row(1) order(1 "Female" 2 "Male")) ///
    name(hsat_age_sex, replace)

* Association between DV and gender.
by cntry: ttest hsat, by(female)

* Correlation between DV and age.
by cntry: pwcorr hsat age, obs star(.01)

* Generate a dummy from extreme categories of age.
cap drop agex
gen agex:agex = .
replace agex = 0 if age6 == 15
replace agex = 1 if age6 == 65
la def agex 0 "15-24" 1 "65+", replace

* Difference between age extremes.
bys cntry: ttest hsat, by(agex)


* Relationship to health status
* -----------------------------

* DV by health.
gr dot hsat, over(health) over(cntry) ///
    yti("Satisfaction in health services") ///
    name(dv_health, replace)

* Line graph using DV means computed for each health status and gender group.
cap drop mu_hsat_*
bys health female: egen mu_hsat_FR = mean(hsat) if cntry == "FR"
bys health female: egen mu_hsat_GB = mean(hsat) if cntry == "GB"
tw conn mu_hsat_* health, by(female, note("")) ///
    xti("Health status") yti("Mean level of satisfaction") ///
    xlab(1 "Good" 5 "Bad") ///
    legend(row(1) order(1 "FR" 2 "GB")) ///
    name(hsat_health, replace)

* Generate a dummy from health status (bad/very bad = 0, good/very good = 1).
cap drop health01
recode health (1/2 = 1 "Good") (4/5 = 0 "Poor") (else = .), gen(health01)

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
gr box hsat, noout note("") over(pol3) asyvars over(cntry) legend(row(1)) ///
    scheme(burd4) name(dv_pol3, replace)

* Comparison with covariates
* --------------------------

d hsat esat gsat

* DV and other ESS satisfaction items (edu = education, gov = government).
cap drop msat*
bys cntry lrscale: egen msat1 = mean(hsat)
bys cntry lrscale: egen msat2 = mean(esat)
bys cntry lrscale: egen msat3 = mean(gsat)

* Line graph, using the means computed above for each left-right group.
tw conn msat? lrscale, by(cntry, note("")) ///
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
   when the measures are examined by left-right positioning. Politics matter. */
 

* =====================
* = REGRESSION MODELS =
* =====================


* Multiple linear regression model for each country case.
bys cntry: reg hsat ib45.age6 female i.health lowinc ib2.pol3

* Cleaner output with the -leanout- command.
leanout: reg hsat ib45.age6 female i.health lowinc ib2.pol3 if cntry == "FR"
leanout: reg hsat ib45.age6 female i.health lowinc ib2.pol3 if cntry == "GB"

/* Notes:

 - This model is specified as a multiple linear regression. It captures linear
   relationships by computing the partial derivative of each variable, which is
   its effect on the DV when all other variables are held constant.

   We will therefore read the coefficient of an IV as its net effect on the DV,
   independently of all other variables in the model. This interpretation gives
   its meaning to the idiom of 'all other things being equal' (ceteris paribus).

 - The baseline age category is set to the category that contains the average
   population age (45-54 years-old) and is coded 'ib45' because the categories
   of 'age6' are coded 15, 25, 35 etc.

 - The baseline health status is set to default reference category 1 = very good.
   Categories 2-5 code for 2 = good to 5 = poor health.

 - The baseline political attitude is the modal (and central) category 2 = centre
   so that 1 = leftwing and 3-rightwing.
   
   The baseline model, given by the constant, is therefore the predicted mean of
   the DV for respondents who are males, aged 45-54, in very good health, at the
   centre politically and who did not report financial difficulties ('lowinc').
   
 - Let's manually check whether the model does a good job at predicting the
   constant (the baseline model) in the second country case:
   
   su hsat if age6 == 45 & !female & health == 1 & !lowinc & pol3 == 2 & cntry == "GB"
   
 - For the same country case, the model predicts a higher value for respondents
   aged 65+, keeping all other variables equal. Let's check that too:
   
   su hsat if age6 == 65 & !female & health == 1 & !lowinc & pol3 == 2 & cntry == "GB"
   
   Not so bad for a model predicting only 7% of the variance, but remember that
   the predicted values are only means, that they are significant only for some
   coefficients, and that they apply only to a fraction of all observations.
   
 - To assess the overall quality of the models, you should rather read the RMSE.
   The Root-Mean-Square Error is the standard error of the regression: it shows
   by how much we mispredict the DV on average.

   We later turn to regression diagnostics to explore the error term. */


* Using the -estout- command
* --------------------------

* Store model estimates.
eststo clear
bys cntry: eststo: qui reg hsat ib45.age6 female i.health lowinc ib2.pol3

* View stored model estimates.
eststo dir

* View standardized coefficients.
esttab, wide nogaps beta(2) se(2) sca(rmse) mti("FR" "GB")

* Export unstandardized coefficients.
esttab using week11_regressions.txt, replace ///
    nolines wide nogaps b(1) se(1) sca(rmse) mti("FR" "GB")


* Models with covariates
* ----------------------

* Store model estimates (again).
eststo clear
bys cntry: eststo: reg hsat ib45.age6 female i.health lowinc ib2.pol3

* Run identical model on satisfaction with education.
bys cntry: eststo: reg esat ib45.age6 female i.health lowinc ib2.pol3

* Run identical model on satisfaction with government.
bys cntry: eststo: reg gsat ib45.age6 female i.health lowinc ib2.pol3

* View updated list of model estimates.
eststo dir

* Compare DV and covariates in each country, using standardized coefficients,
* RMSE and R-squared to compare predicted variance across the models.
esttab est1 est3 est5, lab nogaps beta(2) se(2) sca(rmse) r2 ///
	mti("Health" "Education" "Government") ti("France")

esttab est2 est4 est6, lab nogaps beta(2) se(2) sca(rmse) r2 ///
	mti("Health" "Education" "Government") ti("UK")

/* Basic usage of -estout- commands:
  
 - The -estout- commands work by storing model estimates with -eststo- and then
   putting them into tables with -esttab-. Use these commands at the end of your
   models: start with -reg- and -leanout-, then use -eststo- and -esttab-.
   
 - The -estout- command is especially practical when you run many models, as
   shown here when we compare the model between country cases and then check
   how the DV model compares to other satisfaction measures (covariates). */


* ==========================
* = REGRESSION DIAGNOSTICS =
* ==========================


* Note: what we call 'diagnostics' at that stage actually covers a broader range
* of postestimation commands like -margins- and -marginsplot- (marginal effects)
* or seemingly unrelated regression (SUREG). The overall logic of these commands
* is to help with the detection of patterns that are not taken into account by
* our 'front-end' linear regression model.


* (1) France: Residuals
* ---------------------

reg hsat ib45.age6 female i.health lowinc ib2.pol3 if cntry == "FR"

* Variance inflation.
vif

* Residuals-versus-fitted values plot.
rvfplot, yline(0) ///
	name(rvf_fr, replace)

* Store the standardized residuals for the estimation sample (France only).
cap drop rst_fr
predict rst_fr if e(sample), rsta

* Distribution of the standardized residuals.
hist rst_fr, normal ///
	name(rst_fr_1, replace)

* Store the predicted values for the estimation sample (France only).
cap drop yhat_fr
predict yhat_fr if e(sample)

* Plot the distribution of the standardized residuals over socio-demographics.
hist rst_fr, normal by(female age6, legend(off)) bin(10) xline(0) ///
	name(rst_fr_2, replace)

* Plot the residuals-versus-fitted values by income and political views.
sc rst_fr yhat_fr, by(pol3 lowinc, col(2) legend(off)) yline(0) ///
	name(rst_fr_3, replace)


* (2) France: Marginal effects
* ----------------------------

* Briefly recall the model by calling -reg- without any new specification.
reg

* Note: this section runs properly only on Stata 12+. If you are using an older
* version of Stata, you will be able to execute the -margins- commands, but not
* the -marginsplot- commands.
if c(version) > 11 {

	* What is observable above is the (positive) linear effect of one predictor
	* onto the DV: all other things kept equal, rightwing views lead to a higher
	* level of satisfaction with health services, independently of age, gender,
	* income and so on. You can show the same thing by predicting the marginal
	* effect of the IV on the DV with the -margins- command.
	margins pol3
	marginsplot, ///
		name(margins_pol3_fr, replace)

	* Let's plot a more complex interaction where we observe the effect of 
	* political views and health status combined. The linear effect of political
	* views remains observable at good health but becomes indistinguishable when
	* health degrades.
	margins health#pol3
	marginsplot, recast(line) recastci(rarea) ciopts(fi(25)) legend(row(1)) ///
		name(margins_health_pol3_fr, replace)

}

* (3) Britain: Exercise
* ---------------------

reg hsat ib45.age6 female i.health lowinc ib2.pol3 if cntry == "GB"

* As an exercise, run your own selection of regression diagnostics and marginal
* effects for the British model. Compare the predictors in each country and see,
* for instance, if age and political views have the same effects in Britain.


* ==============
* = EXTENSIONS =
* ==============


* Note: this section showcases some methods that are related to the content of
* the course, but go beyond its scope. Both techniques yield corrected standard
* errors, which is crucial for panel data analysis. These methods require more
* theoretical support (and possibly different data) to operate, and are shown
* here for demonstration purposes only.


* (1) Bootstrapping
* -----------------

reg hsat ib45.age6 female i.health lowinc ib2.pol3 if cntry == "FR", ///
	vce(bootstrap, r(100))
reg hsat ib45.age6 female i.health lowinc ib2.pol3 if cntry == "GB", ///
	vce(bootstrap, r(100))

/* What happened here:

 - Bootstrapping is a simulation technique that resamples the data as many times
   as you ask it (here we ran 100 replications) and then computes the standard
   error from the standard deviation of these simulations.

 - Resampling means that the data used in each simulation is randomly selected
   from the original dataset, with replacement: one value may appear many times.
   The result is 100 simulations of the data with slightly different values.
 
 - Bootstrapping is particularly efficient at lower sample sizes, for which it
   provides more reliable standard errors than the 'square root of N' formula.
   It applies to parametric estimation commands like -su-, -reg-, etc. */


* (2) Clustered standard errors
* -----------------------------

* Remember that we saved the initial models as 'est1' (FR) and 'est2' (GB).
eststo dir

* The next command stores the right-hand side of the regression equation, i.e.
* the list of predictors (IVs), into a convenient string of text handled by
* Stata as a local macro. This works almost like the global macro trick we saw
* before, and becomes useful when you have long lists of predictors.
local rhs "ib45.age6 female i.health lowinc ib2.pol3"

* IMPORTANT: storing the variable names into a local macro is technically more 
* appropriate than using a global one as we did in a earlier do-file. However, 
* this come with additional constraints: local macros are handled with `ticks'
* instead of the $dollar sign, and they have to be run in the same sequence as
* the regression commands to work properly, WITHOUT stopping execution. This
* means that your local macros will work only if you run the whole code block
* (the line below AND the -reg- commands), or the whole do-file.

* Store robust models.
eststo FRr: reg hsat `rhs' if cntry == "FR", vce(cluster region)
eststo GBr: reg hsat `rhs' if cntry == "GB", vce(cluster region)

* Compare both versions for a more realistic assessment of the standard errors.
esttab est1 FRr est2 GBr, nogaps b(2) se(2) sca(rmse) compress ///
	mti("FR" "FR robust" "GB" "GB robust")

/* What happened here:

 - We clustered the data by geographical region in each regression, which means
   that the standard errors of the coefficients will increase if the variance of
   the data differs between regions, indicating some macro-level effect.
 
 - In this example, we assume that poorer and/or less populated regions will not
   benefit from the same health care facilities than others, which will create
   differences between predicted means of the DV clustered by region.

 - The results show that the clustered models lose some significant coefficients
   in comparison to the original ones, which should invite us to correct some of
   our initial interpretations, or consider more advanced modelling.
   
 - Robust (corrected) standard errors become crucial when the data form a panel,
   as with cross-sectional time-series (CSTS) data, because the observations are
   then country-years and variance will exist between and within them. */


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done, and we have covered tons of stuff. Thanks for following!
* exit, clear
