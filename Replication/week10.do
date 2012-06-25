* What: SRQM Session 10
* Who:  F. Briatte and I. Petev
* When: 2011-11-21

* Research Question: Do men have more sexual partners than women?
* Hypothesis: All other things kept equal, men declare having more sexual partners than women.
* DV  - How many sex partners respondent had in last 5 years.
* IVs - gender, age, family income, education, marital status, working status, size of residential area.

* Dataset: U.S. General Social Survey from 2010.
use "Datasets/gss2010.dta", clear

* Log.
cap log using "Replication/week10.log", name(week10) replace

* =========================
* = FINALIZING THE SAMPLE =
* =========================

* Keep variables of interest and respondent ID.
keep id partnrs5 sex age coninc educ marital wrkstat size

* Drop missing cases.
fre partnrs5
drop if mi(partnrs5)
fre sex age coninc educ marital wrkstat size, r(10)
drop if mi(age) | mi(coninc) | mi(educ) | mi(marital) | mi(wrkstat)

* Drop ambiguous wrkstat category "Other".
drop if wrkstat==8

* Drop respondents oblivious of their sexual life.
drop if partnrs5==9

* Recodes.
recode sex (1=0 "Male") (2=1 "Female"), gen(female)
drop sex

* =============
* = ANALYSIS =* =============

* Explore the DV.
fre partnrs5
hist partnrs5, bin(10) percent addl

* Bivariate test of hypothesis.
tab partnrs5 female, nofreq col chi2
gr hbar partnrs5, over(female)
ttest partnrs5, by(female)

* A simple linear regression model test.
reg partnrs5 i.female

* Let's add some of our control variables one by one.
* Let's control for income: Is higher income associated with a higher number of partners in the US?
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
* Male
* With average income
* With average education
* From a mid-sized town
* Employed full-time
* Married
* Mid-age

* The end.

* ========
* = EXIT =
* ========

* Wipe the modified data.
* clear

* Close log (if opened).
cap log close week10

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
