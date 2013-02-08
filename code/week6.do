
/* ------------------------------------------ SRQM Session 6 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Opposition to Torture in European Countries
 
 - DATA:   European Social Survey Round 4 (2008)
 
   Last updated 2012-11-13.

----------------------------------------------------------------------------- */


* Additional commands.
foreach p in fre tab_chi {
    cap which `p'
    if _rc == 111 cap noi ssc install `p' // install from online if missing
}

* Log.
cap log using code/week6.log, replace


* ====================
* = DATA DESCRIPTION =
* ====================


use data/ess2008, clear

* Survey weights.
svyset [pw = dweight] // weighting scheme set to country-specific population

* Rename variables to short handles.
ren (agea gndr hinctnta eduyrs) (age sex income edu) // socio-demographics
ren (rlgdnm lrscale tvpol) (denom pol tv) // religion, politics

* Have a quick look.
codebook cntry age sex income edu denom pol tv, c

* Delete incomplete observations.
drop if mi(age, sex, income, edu, denom, pol, tv)

* Final sample size.
count


* DV: Justifiability of torture in event of preventing terrorism
* --------------------------------------------------------------

fre trrtort

* Binary recoding (1 = torture is never justifiable; undecideds removed).
cap drop torture
recode trrtort ///
    (1/2 = 1 "Never justifiable") ///
    (4/5 = 0 "Sometimes justifiable") ///
    (3 = .) (else = .), gen(torture)
la var torture "Opposition to torture"

* Overall opposition to torture in Europe.
fre torture
tab torture [aw = dweight*pweight]   // weighted by overall European population
bys cntry: ci torture [aw = dweight] // weighted by country-specific population

* Average opposition to torture in each country.
gr dot torture [aw = dweight], over(cntry, sort(1) des) scale(.75) ///
    name(torture1, replace)


* Detailed breakdown in each country
* ----------------------------------

* Delete any previous variable called 'torture_*' where '*' can be anything.
cap drop torture_*

* Generate dummies called 'torture_1 torture_2' etc. for each DV category.
tab trrtort, gen(torture_)

* Plot using stacked horizontal bars and a 5-pt scale graph scheme.
gr hbar torture_* [aw = dweight], stack over(cntry, sort(1)des lab(labsize(*.8))) ///
    yti("Torture is never justified even to prevent terrorism") ///
    legend(rows(1) order(1 "Strongly agree" 2 "" 3 "Neither" 4 "" 5 "Strongly disagree")) ///
    name(torture2, replace) scheme(burd5)

* Comparing Israel to other European countries.
gen israel:israel = (cntry == "IL")
la de israel 1 "Israel" 0 "Other EU"

* Comparison of average opposition to torture inside and outside Israel.
prtest torture, by(israel)

* Subset to all European countries but Israel.
keep if israel

* Final sample size.
count


* IV: Age
* -------

su age

* Check normality.
hist age, bin(15) normal ///
    name(age, replace)

* Recoding to 4 age groups:
gen age4:age4 = irecode(age, 24, 44, 64)         // quick recode
table age4, c(min age max age n age)             // check result
la de age4 0 "15-24" 1 "25-44" 2 "45-64" 3 "65+" // value labels
la var age4 "Age (4 groups)"                     // label result
fre age4                                         // final result

* Spineplot.
spineplot torture age4, ///
	name(dv_age, replace)

* Comparison of average age in each category.
ttest age, by(torture)


* IV: Gender
* ----------

fre sex

recode sex (1 = 0 "Male") (2 = 1 "Female") (else = .), gen(female) // dummify
la var female "Gender"

* Conditional probabilities:
tab torture female, col nof // column percentages
tab torture female, row nof // rows percentages

* Comparison of proportions in each category.
prtest torture, by(female)


* IV: Income deciles
* ------------------

fre income

* Simpler coding (no value labels).
gen inc = income

* Spineplot.
spineplot torture inc


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

fre denom

* Recoding to simpler groups.
recode denom (1/4 = 1 "Christian") ///
    (5 = 2 "Jewish") (6 = 3 "Muslim") (else = .), gen(faith3)
la var faith3 "Religious faith"

* Conditional probabilities:
tab torture faith3, col nof    // column percentages
tab torture faith3, row nof    // rows percentages

* Chi-squared test:
tab torture faith3, exp chi2 // expected frequencies
tabchi torture faith3, noe p // Pearson residuals

* Create a binary variable for each category.
tab faith3, gen(faith_)
d faith_*
codebook faith_*, c

* Inspect underlying distribution by country.
tab cntry faith3

* Comparing Christian respondents to all others.
prtest torture, by(faith_1)

* Comparing Jewish respondents to all others.
prtest torture, by(faith_2)

* Comparing Muslim respondents to all others.
prtest torture, by(faith_3)


* IV: Political positioning
* -------------------------

fre pol

* Verifying normality.
hist pol, discrete percent addl

* Recoding to simpler categories
recode pol (0/4 = 1 "Left") (5 = 2 "Centre") (6/10 = 3 "Right"), gen(pol3)
la var pol3 "Political positioning"

* Conditional probabilities:
tab torture pol3, col nof    // column percentages
tab torture pol3, row nof    // rows percentages

* Chi-squared test:
tab torture pol3, exp chi2 // expected frequencies


* IV: Media exposure
* ------------------

fre tv

* Alternative reading (binary mean). The nolabel (nol) option gets rid of the
* value labels and makes the output table a tad softer on the reader's eye.
tab tv, summ(torture) nol

* Alternative reading (plot).
tab tv, plot

* Recoding to binary.
recode tv (0/3 = 0 "Low") (4/7 = 1 "High"), gen(media)
la var media "Media exposure"

* Chi-squared test:
tab torture media, exp chi2  // expected frequencies
tabchi torture media, noe p  // Pearson residuals

* Comparing respondents with high TV exposure to others.
prtest torture, by(media)


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
