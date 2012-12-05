
/* ------------------------------------------ SRQM Session 9 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Sexual Partners in the U.S.

 - DATA:   U.S. General Social Survey (2010)
 
   What makes Americans likely to report high numbers of sexual partners in the
   last five years? What makes them more likely to report low numbers?
   
   We explore that topic this week, as a means of introduction to multiple
   linear regression with individual-level data. Our first approach of linear
   regression will be relatively low-tech, as we will focus on fitting the
   model without diagnosing its validity. Regression diagnostics are explored
   next week.

   Last updated 2012-12-05.

----------------------------------------------------------------------------- */


* Install required commands.
foreach p in fre {
	cap which `p'
	if _rc==111 cap noi ssc install `p'
}

* Log results.
cap log using "Replication/week12.log", replace


* ====================
* = DATA DESCRIPTION =
* ====================


use "Datasets/gss2010.dta", clear

* Keep most recent year.
keep if year==2010

* Inspect DV, drop missing cases.
fre partnrs5
drop if mi(partnrs5)

* Inspect IVs, drop missing cases.fre sex age coninc educ marital wrkstat size, r(10)
drop if mi(age,coninc,educ,marital,wrkstat)

* Generate age decades.
gen age10 = 10*floor(age/10)

* Drop small-N category of age < 20.
drop if age < 20

* Inspect DV by age.
spineplot partnrs5 age10, scheme(burd8)

* Inspect DV by age, sex and interviewer's sex.
gr bar partnrs5, over(sex) asyvars over(age10) by(intsex)

* Drop ambiguous wrkstat category "Other".
drop if wrkstat==8

* Drop respondents oblivious of their sexual life.
drop if partnrs5==9

* Recodes.
recode sex (1=0 "Male") (2=1 "Female"), gen(female)
drop sex

* Final sample size.
count

* Survey weights.
svyset vpsu [weight=wtssall], strata (vstrata)


* ====================
* = DATA DESCRIPTION =
* ====================


* Explore the DV.
fre partnrs5
hist partnrs5, bin(10) percent addl norm

* Bivariate test of hypothesis.
tab partnrs5 female, nofreq col chi2
gr hbar partnrs5, over(female)
ttest partnrs5, by(female)


* =====================
* = REGRESSION MODELS =
* =====================


* A simple linear regression model test.
reg partnrs5 i.female

* Let's add some of our control variables one by one.
* Let's control for income:
* Is higher income associated with a higher number of partners in the US?
reg partnrs5 i.female coninc

* Let's transform income into a more meaningful scale: a dollar change in income
* is not large enough to have a large effect. Let's measure income to 10,000s of
* U.S. dollars.
gen inc = coninc/10000

reg partnrs5 i.female inc

* Let's control for education as well.
reg partnrs5 i.female inc educ

* Let's control for urban size.
reg partnrs5 i.female inc educ size

* How about working status?
reg partnrs5 i.female inc educ size i.wrkstat
fre wrkstat

* Let's add a control for marital status.
reg partnrs5 i.female inc educ size i.wrkstat i.marital
fre marital

* Finally, let's control for age.
reg partnrs5 i.female inc educ size i.wrkstat i.marital age

                 
* Reinterpretation of the constant
* --------------------------------

* Lastly, the constant reflects the value of y when the IVs are equal to the
* reference category for the categorical IVs (i.e., males, full-time employment,
* married) or 0 for the continuous IVs (income=0, education=0, age=0, size=0).
* However, often for continuous variables, as in this case, the 0 category is
* unlikely (educ=0 and income=0) or unreal (age=0 and size=0). Therefore, the
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
reg partnrs5 i.female zinc zeduc zsize i.wrkstat i.marital zage

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
reg partnrs5 i.female zinc zeduc zsize i.wrkstat i.marital zage

* Model with all coefficients expressed in standard deviation units.
reg partnrs5 i.female zinc zeduc zsize i.wrkstat i.marital zage, b


* Residuals
* ---------

* Distribution of the residuals.
predict r, resid
kdensity r, norm

* Residuals-versus-fitted values plot.
rvfplot

* Extensions
* ----------

recode partnrs5 (0=0)(1=1)(2=2)(3=3)(4=4)(5=8)(6=15)(7=60)(8=120)(else=.), gen(sxp)

* Multiple linear regression.
eststo LIN: reg sxp i.female inc educ size i.wrkstat i.marital age

* Negative binomial regression (for count data).
eststo NBR: nbreg sxp i.female inc educ size i.wrkstat i.marital age

* Compare models.
esttab LIN NBR, b(1) wide compress mti("Lin. reg." "Neg. bin.")


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
