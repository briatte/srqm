* What: SRQM Session 7
* Who:  F. Briatte and I. Petev
* When: 2011-10-12


* ================
* = INTRODUCTION =
* ================


* Data: European Social Survey, Round 4 (2008).
use "Datasets/ess2008.dta", clear

* Log.
cap log using "Replication/week7.log", name(week7) replace

* Packages.
* ssc install fre
* ssc install catplot


* ====================
* = DATA PREPARATION =
* ====================


* Attitudes towards torture.
fre trrtort

* Binary recoding.
recode trrtort ///
	(1/2=1 "Never justifiable") ///
	(4/5=0 "Sometimes justifiable") ///
	(3=.), gen(torture)
la var torture "Opposition to torture"

* Weight results by survey design.
svyset [pw=dweight], vce(linearized) singleunit(missing)


* ======================
* = DEPENDENT VARIABLE =
* ======================


fre torture [aw=dweight*pweight]
su torture [aw=dweight*pweight]
ci torture [aw=dweight*pweight]

* Average opposition to torture in each country.
gr dot torture, over(cntry, sort(1) des) scale(.7)

* Detailed breakdown in each country.
catplot trrtort if trrtort != 8, over(cntry, sort(1)des lab(labsize(*.8))) ///
	asyvars percent(cntry) stack scale(.7) ytitle("") ///
	legend(rows(1) label(3 "Neither") region(fc(none) ls(none))) ///
	bar(1, c(sand)) bar(2, c(sand*.7)) bar(3, c(dimgray)) ///
	bar(4, c(navy*.7)) bar(5, c(navy)) ///
	name(torture, replace)

* Comparing Israel to other European countries.
gen israel=.
replace israel=1 if cntry=="IL"
replace israel=0 if cntry!="IL"

* Comparison of average opposition to torture inside and outside Israel.
prtest torture, by(israel)

* Subset to all European countries but Israel.
drop if cntry=="IL"


* =========================
* = INDEPENDENT VARIABLES =
* =========================


* Continue the analysis at the micro-level (individuals).
* Weight results by survey design and country population.
gen wgt=dweight*pweight
svyset [pw=wgt], vce(linearized) singleunit(missing)

* (1) Age
* -------

ren agea age

* Verify normality.
hist age, bin(15) normal

* Recoding to 4 age groups.
recode age ///
	(18/35=1 "18-35 years") ///
	(36/49=2 "36-49 years") ///
	(50/64=3 "50-64 years") ///
	(65/max=4 "65+ years") ///
	(else=.), gen(age4)
la var age4 "Age (4 groups)"

* Crosstabulation; Chi-squared test.
tab torture age4
tab torture age4, col nof
tab torture age4, row nof
tab torture age4, exp
tab torture age4, col nof chi2

* Comparison of average age in each category.
ttest age, by(torture)

* (2) Gender
* ----------

recode gndr (1=0 "Male") (2=1 "Female") (else=.), gen(female)
la var female "Gender"

* Crosstabulation; Fisher's exact test.
tab torture female, col nof exact
	
* Comparison of proportions in each category.
prtest torture, by(female)

* (3) Income deciles
* ------------------

ren hinctnta income

* Average opposition to torture in each income decile.
gr dot torture, over(income) exclude0

* Recoding to 4 income groups.
recode income (1/3=1 "D1-D3") (4/6=2 "D4-D6") ///
	(7/9=3 "D7-D9") (10=4 "D10"), gen(income4)

* Crosstabulation; Chi-squared test.
tab torture income4, col nof chi2


* (4) Education
* -------------

ren eduyrs edu

* Verify normality.
hist edu, bin(15) normal

* Comparison of average educational attainment in each category.
ttest edu, by(torture)


* (5) Religious faith
* -------------------

fre rlgblg rlgdnm

* Comparision of proportions in each category.
prtest torture, by(rlgblg)

* Recoding to simpler groups.
recode rlgdnm (.a=1 "Not religious") (1/4=2 "Christian") ///
	(5=3 "Jewish") (6=4 "Muslim") (7/8=.) , gen(faith)
la var faith "Religious faith"

* Crosstabulation; Chi-squared test.
tab torture faith, col nof chi2

* Create a binary variable for each category.
tab faith, gen(faith_)
d faith_*
codebook faith_*, c

* Comparing non-religious respondents to all others.
prtest torture, by(faith_1)

* Comparing Christian respondents to all others.
prtest torture, by(faith_2)

* Comparing Jewish respondents to all others.
prtest torture, by(faith_3)

* Comparing Muslim respondents to all others.
prtest torture, by(faith_4)


* (6) Political positioning
* -------------------------

ren lrscale pol

* Verifying normality.
hist pol, discrete percent addl

* Recoding to simpler categories
recode pol (0/4=1 "Left") (5=2 "Centre") (6/10=3 "Right"), gen(pol3)
la var pol3 "Political positioning"

* Crosstabulation; Chi-squared test.
tab torture pol3, col nof chi2

* Comparing left-wing respondents to all others.
gen left=.
replace left=1 if pol3==1
replace left=0 if pol3==2 | pol==3

* Comparing left-wing respondents to all others.
prtest torture, by(left)


* (7) Media exposure
* ------------------

fre tvpol

* Crosstabulation; Chi-squared test.
tab torture tvpol, col nof chi2

* Alternative reading (binary mean). The nolabel (nol) option gets rid of the
* value labels and makes the output table a tad softer on the reader's eye.
tab tvpol, summ(torture) nol nost

* Recoding to binary.
recode tvpol (0/3=0 "Low") (4/7=1 "High"), gen(media)
la var media "Media exposure (simplified)"

* Crosstabulation; Fisher's exact test.
tab torture media, col nof exact

* Comparing respondents with high TV exposure to others.
prtest torture, by(media)


* ==============
* = EXTENSIONS =
* ==============


* The following section covers techniques outside of the scope of this course.
* Feel free to replicate and read from the UCLA Stata annotated output pages on
* odds ratios and (ordered) logistic regression to understand the techniques we
* used to finalize our analysis.

 
* (1) Odds ratios
* ---------------

* Save the crosstabulated frequencies to a matrix.
tab torture media, col nof exact matcell(odds)

* Build an odds-ratios statement.
di as txt _n "Respondents with high political TV news exposure were about " ///
	round((odds[1,2]*odds[2,1])/(odds[2,2]*odds[1,1]),.01) " times " ///	_n "more likely to systematically support torture than other respondents."

* Same result as a logistic regression with a 99% CI odds ratio.
logit torture ib1.media, or level(99)

* Odds ratios are common in biostatistics, where analysts are often interested
* in calculating the risk ratio of exposure to a given pathological factor. We
* used the odds ratios here to change our initial perspective on the variable:
* instead of measuring opposition to torture, the odds ratios above relate to
* supporters of torture in particular circumstances. By shifting to a 99% level
* of confidence, we demonstrated that the effect of high exposure to political
* TV news is robust, i.e. superior to 1 even with a large confidence interval.
* This, again, applies mostly to biostatistics, where life-threatening factors
* are more common and therefore more likely to require a very low alpha level.
* Read on odds ratios and confidence intervals for more background.

* (2) Logistic regression
* -----------------------

* Our final model uses a technique that goes beyond this course. It restores
* some precision in variable measurement by using the full ordinal scales of
* all variables. It also computes robust standard errors by controlling for
* any country effect. 

* Ordered logistic regression with 95% CI odds ratios for all predictors.
ologit trrtort age i.female income edu i.faith pol tvpol, or vce(cluster cntry)

* Model checks indicate that the choice of predictors is very lowly efficient
* at predicting the DV: overall, this model explains very little about support
* and opposition to torture. However, it reaches stable conclusions: right-wing
* support and high media exposure are both more present among respondents who
* are open to the possibility of torture, but to a minor extent. The strongest
* predictors concern systematic opposition to torture, which is more frequent
* among females, higher income deciles and higher educated groups. A better way
* to explain the DV will use more predictors: further exploration shows that a
* low feeling of local safety is actually a reasonably powerful predictor of
* stronger support for the use of torture, other factors being kept constant.


* ========
* = EXIT =
* ========


* Clean all graphs from memory.
* gr drop _all

* Wipe the modified data.
* clear

* Close log (if opened).
cap log close week7

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
