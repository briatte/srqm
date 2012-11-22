
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

   Last updated 2012-11-13.

----------------------------------------------------------------------------- */


* Install required commands.
foreach p in fre {
	cap which `p'
	if _rc==111 cap noi ssc install `p'
}

* Log results.
cap log using "Replication/week10.log", replace


* ====================
* = DATA DESCRIPTION =
* ====================


use "Datasets/gss2010.dta", clear


* Keep variables of interest and respondent ID.
keep id partnrs5 sex age coninc educ marital wrkstat size

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
gr bar partnrs5, over(female) asyvars over(age10) by(intsex)

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
svyset vpsu [weight=wtcomb], strata (vstrat)

* ================
* = DESCRIPTIONS =
* ================


* Explore the DV.
fre partnrs5
hist partnrs5, bin(10) percent addl

* Bivariate test of hypothesis.
tab partnrs5 female, nofreq col chi2
gr hbar partnrs5, over(female)
ttest partnrs5, by(female)


* ==========
* = MODELS =
* ==========


* A simple linear regression model test.
reg partnrs5 i.female

* Let's add some of our control variables one by one.
* Let's control for income:
* Is higher income associated with a higher number of partners in the US?
reg partnrs5 i.female coninc

* Let's transform income into a more meaningful scale.
* A dollar change in income is not large enough to expect a large effect.
* Let's change income to tens of thousands of dollars.
gen coninc2=coninc/10000

reg partnrs5 i.female coninc2

* Let's control for education as well.
reg partnrs5 i.female coninc2 educ

* Let's control for urban size.
reg partnrs5 i.female coninc2 educ size

* How about working status?
reg partnrs5 i.female coninc2 educ size i.wrkstat
fre wrkstat

* Let's add a control for marital status.
reg partnrs5 i.female coninc2 educ size i.wrkstat i.marital
fre marital

* Finally, let's control for age.
reg partnrs5 i.female coninc2 educ size i.wrkstat i.marital age


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

su coninc2
gen zconinc2=coninc2-r(mean)
su size
gen zsize=size-r(mean)
su age
gen zage=age-r(mean)
su educ
gen zeduc=educ-r(mean)

* Replicate the final regression model with transformed continuous variables.
reg partnrs5 i.female zconinc2 zeduc zsize i.wrkstat i.marital zage

* The results do not change except for the constant. For this model, the constant
* stands for the average number of partners of respondents who are:
* - Male
* - With average income
* - With average education
* - From a mid-sized town
* - Employed full-time
* - Married
* - Mid-age


* Robust standard errors
* ----------------------

reg partnrs5 i.female zconinc2 zeduc zsize i.wrkstat i.marital zage
reg partnrs5 i.female zconinc2 zeduc zsize i.wrkstat i.marital zage, r


* Standardized coefficients
* -------------------------

reg partnrs5 i.female zconinc2 zeduc zsize i.wrkstat i.marital zage
reg partnrs5 i.female zconinc2 zeduc zsize i.wrkstat i.marital zage, b


* Residuals
* ---------

rvfplot
rvpplot


* Variance inflation
* ------------------

vif


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
