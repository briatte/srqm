
* Check setup.
run setup/require estout fre scheme-burd spineplot

* Log results.
cap log using code/week12.log, replace

/* ------------------------------------------ SRQM Session 12 ------------------

   F. Briatte and I. Petev

 - TOPIC:  Sexual Partners in the United States

 - DATA:   U.S. General Social Survey (2010)
 
   What makes Americans likely to report high numbers of sexual partners in the
   last five years? What makes them more likely to report low numbers?
   
   For this session, all hypotheses are to be provided by the students.
   
   Last updated 2013-05-31.

----------------------------------------------------------------------------- */

* Load GSS dataset for selected survey year.
use data/gss0012 if year == 2010, clear

* Inspect DV.
fre partnrs5

* Keep only valid observations, excluding oblivious respondents.
clonevar sxp = partnrs5 if partnrs5 < 9

* Code missing values for deeper inspection.
gen missing = mi(sxp)

* Generate six age groups (15-24, 25-34, ..., 65+).
gen age6:age6 = irecode(age, 24, 34, 44, 54, 64, .)

* Code the value as the lower bound of the age groups (the data buckets).
replace age6 = 10 * age6 + 15

* Assign value labels.
la def age6 15 "15-24" 25 "25-34" 35 "35-44" ///
	45 "45-54" 55 "55-64" 65 "65+", replace
la var age6 "Age groups"

* Inspect missing values by age and sex.
gr bar (count) age, over(missing) asyvars stack over(age6) over(sex) ///
	name(missing_agesex, replace)

* Chi-squared test for age groups.
bys sex: tab age6 missing, col nof chi2

* Proportions test for sex groups.
prtest missing, by(sex)

* Comparison of average age between missing and nonmissing groups, by sex.
bys sex: ttest age, by(missing)

* Inspect DV by age.
spineplot sxp age6, scheme(burd8) name(sp, replace)

* Inspect DV by age, sex and interviewer's sex.
gr bar sxp, over(sex) asyvars over(age6) by(intsex) ///
	name(dv_agesexint, replace)

* Inspect IVs.
fre sex age coninc educ marital wrkstat size, r(10)

* Drop missing values.
drop if mi(sxp, age, coninc, educ, marital, wrkstat)

* Drop ambiguous wrkstat category "Other".
drop if wrkstat == 8

* Recode sex.
gen female = (sex == 1) if !mi(sex)

* Final sample size.
count

* Survey weights.
svyset vpsu [weight = wtssall], strata (vstrat)

* Export summary stats.
stab using week12_stats.txt, replace ///
	mean(coninc educ size) ///
	prop(age6 marital wrkstat)


* ===================
* = DV DISTRIBUTION =
* ===================


* Explore the DV.
fre sxp

* Histogram for normality assessment.
hist sxp, bin(10) percent addl norm ///
	name(dv_hist, replace)
	
* Bivariate hypothesis test: mean DV by sex.
ttest sxp, by(female)


* =====================
* = REGRESSION MODELS =
* =====================


* A simple linear regression model test.
reg sxp i.female

* Let's add some of our control variables one by one. Let's first control for
* income: is higher income associated with a higher number of partners?
reg sxp i.female coninc

* Let's transform income into a more meaningful scale: a dollar change in income
* is not enough to have a large effect. Let's measure income to 10,000s of USD.
gen inc = coninc / 10^4

* Regress again.
reg sxp i.female inc

* Let's control for education as well.
reg sxp i.female inc educ

* Let's control for urban size.
reg sxp i.female inc educ size

* How about working status?
reg sxp i.female inc educ size i.wrkstat
fre wrkstat

* Let's add a control for marital status.
reg sxp i.female inc educ size i.wrkstat i.marital
fre marital

* Finally, let's control for age.
reg sxp i.female inc educ size i.wrkstat i.marital age

                 
* Reinterpretation of the constant
* --------------------------------

* Lastly, the constant reflects the value of y when the IVs are equal to the
* reference category for the categorical IVs (i.e., males, full-time employment,
* married) or 0 for the continuous IVs (income = 0, education = 0, age = 0, size = 0).
* However, often for continuous variables, as in this case, the 0 category is
* unlikely (educ = 0 and income = 0) or unreal (age = 0 and size = 0). Therefore, the
* constant is not meaningful and interpretable. In such cases, it's best to
* recode your continuous IVs so that their mean is equal to 0, making the
* reference category for the constant the sample mean for each continuous IV.
* To do so, we simply nead to substract from each variable its mean.

su inc
gen zinc = inc - r(mean)

su size
gen zsize = size - r(mean)

su age
gen zage = age - r(mean)

su educ
gen zeduc = educ - r(mean)

* Replicate the final regression model with transformed continuous variables.
reg sxp i.female zinc zeduc zsize i.wrkstat i.marital zage

* The results do not change except for the constant. For this model, the constant
* stands for the average number of partners among respondents who are:
* - Male (female = 0)
* - With average income (zinc = 0)
* - With average education (...)
* - From a mid-sized town
* - Employed full-time
* - Married
* - Mid-age


* Standardized coefficients
* -------------------------

* Model with metric coefficients (in units of each variable).
reg sxp i.female zinc zeduc zsize i.wrkstat i.marital zage

* Model with all coefficients expressed in standard deviation units.
reg sxp i.female zinc zeduc zsize i.wrkstat i.marital zage, b


* Residuals
* ---------

* Get residuals.
predict r, resid

* Distribution of the residuals.
kdensity r, norm

* Residuals-versus-fitted values plot.
rvfplot


* Extensions
* ----------

recode partnrs5 (0 = 0) (1 = 1) (2 = 2) (3 = 3) (4 = 4) ///
				(5 = 8) (6 = 15) (7 = 60) (8 = 120) (else = .), gen(sxp_count)

* Multiple linear regression.
eststo LIN: reg sxp_count i.female inc educ size i.wrkstat i.marital age

* Negative binomial regression (for count data).
eststo NBR: nbreg sxp_count i.female inc educ size i.wrkstat i.marital age

* Compare models.
esttab LIN NBR, b(1) wide compress mti("Lin. reg." "Neg. bin.")

* Export in wide format.
esttab LIN NBR using week12_regressions.txt, ///
	b(1) wide compress mti("Lin. reg." "Neg. bin.")


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
