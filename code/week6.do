
/* ------------------------------------------ SRQM Session 6 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Opposition to Torture in Israel
 
 - DATA:   European Social Survey Round 4 (2008)
 
   This do-file introduces the topic of significance tests, i.e. statistical
   tools to assess whether an association that shows up in the data is different
   from the kind of arrangement that might be observed in random data.
   
   Associations are relationships between two of your variables. They correspond
   to real-world relationships, like the association between income and gender.
   Significance tests are helpful to observe and measure these phenomena.
   
   The null hypothesis, which is the kind of hypothesis that gets tested in a 
   significance test, is different from the substantive hypotheses that you 
   previously formulated about your data. It is usually denoted "H_0".
   
   The null hypothesis is the extent to which it is possible to reproduce the
   association that you observe in the data by statistical accident. It measures
   the consistency of your data with randomness.
   
   A significance test never proves anything. It can only reject the possibility
   that an association in your data is consistent with accidental situations.
   The aim of a significance test is therefore to reject the null hypothesis.
   
   To obtain that kind of proof by contradiction, the significance test will
   estimate how likely it is to reach the same kind of association that you
   observe from random data. This likelihood is called the p-value of the test.
   
   A small p-value means that is highly unlikely to produce the same association
   as the one you observe out of randomness. Note how far that result is from an
   assessment of whether your hypothesis is right or wrong!
   
   The notions covered in the paragraphs above cannot be introduced technically,
   as short comments accompanying Stata commands. They require that you actually
   open your textbooks and read at length about statistical estimation.
   
   There are many different kinds of hypothesis tests: we will cover the t-test,
   the proportions test, the Chi-squared test and finally linear correlation.
   The Stata Guide also covers these tests. Make sure to read what you need to!

   Last updated 2012-11-13.

----------------------------------------------------------------------------- */


* Additional commands.
foreach p in fre tab_chi {
	if "`p'" == "tab_chi" local p = "tabchi" // fix
    cap which `p'
    if _rc == 111 cap noi ssc install `p' // install from online if missing
}

* Log results.
cap log using code/week6.log, replace


* ====================
* = DATA DESCRIPTION =
* ====================


use data/ess2008, clear

* Survey weights.
svyset [pw = dweight] // weighting scheme set to country-specific population

* Rename variables to short handles.
ren (agea gndr hinctnta eduyrs) (age sex income edu) // socio-demographics
ren (rlgdnm lrscale tvpol) (denom pol tv)            // religion, politics

* Have a quick look.
codebook cntry age sex income edu denom pol tv, c


* Subsetting
* ----------

* Delete incomplete observations.
drop if mi(age, sex, income, edu, denom, pol, tv)


* Dependent variable: Justifiability of torture in event of preventing terrorism
* ------------------------------------------------------------------------------

fre trrtort

* Generate dummies called 'torture_1 torture_2' etc. for each DV category.
tab trrtort, gen(torture_)

* Country-level breakdown using stacked bars and 5-pt scale graph scheme.
gr hbar torture_? [aw = dweight], stack ///
	over(cntry, sort(1)des lab(labsize(*.8))) ///
    yti("Torture is never justified even to prevent terrorism") ///
    legend(rows(1) ///
    order(1 "Strongly agree" 2 "" 3 "Neither" 4 "" 5 "Strongly disagree")) ///
    name(torture1, replace) scheme(burd5)

* Binary recoding (1 = torture is never justifiable; undecideds removed).
recode trrtort ///
    (1/2 = 1 "Never justifiable") ///
    (4/5 = 0 "Sometimes justifiable") ///
    (3 = .) (else = .), gen(torture)
la var torture "Opposition to torture"

* Average opposition to torture in Europe.
fre torture
tab torture [aw = dweight * pweight] // weighted by overall European population

* Average opposition to torture in each country.
gr dot torture [aw = dweight], over(cntry, sort(1) des) scale(.75) ///
    name(torture2, replace)

* Create a dummy for Israel vs. other European countries.
gen israel:israel = (cntry == "IL")
la def israel 1 "Israel" 0 "Other EU"

* Estimate DV proportions in Israel.
prop torture if israel

* Compare average opposition to torture inside and outside Israel.
prtest torture, by(israel)

* Subset to all European countries but Israel.
keep if israel

* Final sample size.
count


* ======================
* = SIGNIFICANCE TESTS =
* ======================


* IV: Age
* -------

su age

* Check normality.
hist age, bin(15) normal ///
    name(age, replace)

* Recoding to 4 age groups:
gen age4:age4 = irecode(age, 24, 44, 64)          // quick recode
table age4, c(min age max age n age)              // check result
la def age4 0 "15-24" 1 "25-44" 2 "45-64" 3 "65+" // value labels
la var age4 "Age (4 groups)"                      // label result
fre age4                                          // final result

* Spineplot.
spineplot torture age4, ///
	name(dv_age, replace)

* Comparison of average age in each category.
ttest age, by(torture)


* IV: Gender
* ----------

fre sex

gen female:female = (sex==2) if !mi(sex) // dummify
la def female 0 "Male" 1 "Female"
la var female "Gender"

* Conditional probabilities:
tab torture female, col nof // column percentages
tab torture female, row nof // rows percentages

* Comparison of proportions in each category.
prtest female, by(torture)


* IV: Income deciles
* ------------------

fre income

* Simpler coding (no value labels).
gen inc = income

* Spineplot.
spineplot torture inc

* Chi-squared test.
tab inc torture, row nof  // row percentages
tab inc torture, col nof  // column percentages
tab inc torture, cell nof // cell percentages
tab inc torture, chi2     // Chi-squared test


* IV: Education
* -------------

fre edu

* Verify normality.
hist edu, bin(10) normal ///
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
d faith_?
codebook faith_?, c

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
tab torture pol3, exp chi2   // expected frequencies


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
