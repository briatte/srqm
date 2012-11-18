
/* ------------------------------------------ SRQM Session 6 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Opposition to Torture in European Countries
 
 - DATA:   European Social Survey Round 4 (2008)
 
   Last updated 2012-11-13.

----------------------------------------------------------------------------- */


* Install required commands.
foreach p in fre catplot {
    cap which `p'
    if _rc==111 cap noi ssc install `p' // install from online if missing
}

* Log results.
cap log using "Replication/week6.log", replace


* ===========
* = DATASET =
* ===========


* Data: European Social Survey, Round 4 (2008).
use "Datasets/ess2008.dta", clear

* Survey weights.
svyset [pw=dweight] // weighting scheme set to country-specific population

* Rename variables to short handles.
ren (agea gndr hinctnta eduyrs) (age sex income edu) // socio-demographics
ren (rlgblg rlgdnm lrscale tvpol) (rel denom pol tv) // religion, politics

* Have a quick look.
codebook cntry age sex income edu rel denom pol tv, c


* ================
* = DESCRIPTIONS =
* ================


* DV: Justifiability of torture in event of preventing terrorism
* --------------------------------------------------------------

fre trrtort

* Binary recoding (1=torture is never justifiable; undecideds removed).
cap drop torture
recode trrtort ///
    (1/2=1 "Never justifiable") ///
    (4/5=0 "Sometimes justifiable") ///
    (3=.) (miss=.), gen(torture)
la var torture "Opposition to torture"

* Overall opposition to torture in Europe.
fre torture
tab torture [aw=dweight*pweight]   // weighted by overall European population
bys cntry: ci torture [aw=dweight] // weighted by country-specific population

* Average opposition to torture in each country.
gr dot torture [aw=dweight], over(cntry, sort(1) des) scale(.7) ///
    name(torture1, replace)


* Detailed breakdown in each country
* ----------------------------------

* Delete any previous variable called 'torture_*' where '*' can be anything.
cap drop torture_*

* Generate dummies called 'torture_1 torture_2' etc. for each DV category.
tab trrtort, gen(torture_)

* Plot using stacked horizontal bars and a 5-pt scale graph scheme.
gr hbar torture_* [aw=dweight], stack over(cntry, sort(1)des lab(labsize(*.8))) ///
    yti("Torture is never justified even to prevent terrorism") ///
    legend(rows(1) order(1 "Strongly agree" 2 "" 3 "Neither" 4 "" 5 "Strongly disagree")) ///
    name(torture2, replace) scheme(burd5)

* Let's go a step further and plot the 'Strongly agree/disagree' categories for
* each country in the sample. The code to get there is tugly: terrifyingly ugly.
cap drop mean1 mean2 cid
bys cntry: egen mean1 = mean(torture_1 + torture_2)
bys cntry: egen mean2 = mean(torture_4 + torture_5)
bys cntry: gen cid = _n // hack
sc mean1 mean2 if cid==1, ms(i) mlab(cntry) xsc(r(.15 .4)) ///
    yti("Opposition to torture") xti("Openness to torture") ///
    name(torture3, replace)


* Comparing Israel to other European countries.
gen israel:israel = (cntry=="IL")
la de israel 1 "Israel" 0 "Other EU"

* Comparison of average opposition to torture inside and outside Israel.
prtest torture, by(israel)

* Subset to all European countries but Israel.
drop if israel

* Final sample size.
count


* IV: Age
* -------

su age

* Check normality.
hist age, bin(15) normal ///
    name(age, replace)

* Recoding to 4 age groups.
recode age ///
    (18/35=1 "18-35 years") ///
    (36/49=2 "36-49 years") ///
    (50/64=3 "50-64 years") ///
    (65/max=4 "65+ years") ///
    (else=.), gen(age4)
la var age4 "Age (4 groups)"

* Crosstabulations:
tab torture age4       // raw frequencies
tab torture age4, cell // cell percentages

* Conditional probabilities:
tab torture age4, col nof    // column percentages
tab torture age4, row nof    // rows percentages

* Significance tests:
tab torture age4, exp chi2 V

* Comparison of average age in each category.
ttest age, by(torture)


* IV: Gender
* ----------

fre sex

recode sex (1=0 "Male") (2=1 "Female") (else=.), gen(female) // dummify
la var female "Gender"

* Significance tests:
tab torture female, exp chi2 V exact

* Comparison of proportions in each category.
prtest torture, by(female)


* IV: Income deciles
* ------------------

fre income

* Recoding to 4 income groups.
recode income (1/3=1 "D1-D3") (4/6=2 "D4-D6") ///
    (7/9=3 "D7-D9") (10=4 "D10"), gen(income4)
la var income4 "HH income"

* Conditional probabilities:
tab torture income4, col nof    // column percentages
tab torture income4, row nof    // rows percentages

* Significance tests:
tab torture income4, exp chi2 V


* IV: Education
* -------------

fre edu

* Verify normality.
hist edu, bin(15) normal ///
    name(edu, replace)

* Comparison of average educational attainment in each category.
ttest edu, by(torture)


* IV: Religious faith
* -------------------

fre rel denom

* Comparison of proportions in each category.
prtest torture, by(rel)

* Recoding to simpler groups.
recode denom (.a=1 "Not religious") (1/4=2 "Christian") ///
    (5=3 "Jewish") (6=4 "Muslim") (7/8=.) , gen(faith4)
la var faith4 "Religious faith"

* Conditional probabilities:
tab torture faith4, col nof    // column percentages
tab torture faith4, row nof    // rows percentages

* Significance tests:
tab torture faith4, exp chi2 V

* Create a binary variable for each category.
tab faith4, gen(faith_)
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


* IV: Political positioning
* -------------------------

fre pol

* Verifying normality.
hist pol, discrete percent addl

* Recoding to simpler categories
recode pol (0/4=1 "Left") (5=2 "Centre") (6/10=3 "Right"), gen(pol3)
la var pol3 "Political positioning"

* Conditional probabilities:
tab torture pol3, col nof    // column percentages
tab torture pol3, row nof    // rows percentages

* Significance tests:
tab torture pol3, exp chi2 V

* Comparing left-wing respondents to all others.
gen left = (pol3==1)

* Comparing left-wing respondents to all others.
prtest torture, by(left)


* IV: Media exposure
* ------------------

fre tv

* Alternative reading (binary mean). The nolabel (nol) option gets rid of the
* value labels and makes the output table a tad softer on the reader's eye.
tab tv, summ(torture) nol

* Alternative reading (plot).
tab tv, plot

* Recoding to binary.
recode tv (0/3=0 "Low") (4/7=1 "High"), gen(media)
la var media "Media exposure"

* Crosstabulation; Fisher's exact test.
tab torture media, col nof exact

* Comparing respondents with high TV exposure to others.
prtest torture, by(media)


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
