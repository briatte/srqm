* What: SRQM Session 6
* Who:  F. Briatte and I. Petev
* When: 2012-11-05


* =========
* = SETUP =
* =========


* Required commands.
foreach p in fre catplot {
	cap which `p'
	if _rc==111 cap noi ssc install `p' // install from online if missing
}

* Log results.
cap log using "Replication/week7.log", replace


* ===========
* = DATASET =
* ===========


* Data: European Social Survey, Round 4 (2008).
use "Datasets/ess2008.dta", clear

* Survey weights.
svyset [pw=dweight] // weighting scheme set to country-specific population

* Rename variables to short handles.
ren (cntry) (country)
ren (agea gndr hinctnta eduyrs) (age sex income edu) // socio-demographics
ren (rlgblg rlgdnm lrscale tvpol) (rel denom pol tv) // religion, politics

* Have a quick look.
codebook country age sex income edu rel denom pol tv, c


* ================
* = DESCRIPTIONS =
* ================


* DV: Justifiability of torture in event of preventing terrorism
* --------------------------------------------------------------

fre trrtort

* Binary recoding (1=torture is never justifiable; undecideds removed).
recode trrtort ///
	(1/2=1 "Never justifiable") ///
	(4/5=0 "Sometimes justifiable") ///
	(3=.) (miss=.), gen(torture)
la var torture "Opposition to torture"

* Overall opposition to torture in Europe.
fre torture
tab torture [aw=dweight*pweight]   // weighted by overall European population
bys country: ci torture [aw=dweight] // weighted by country-specific population

* Average opposition to torture in each country.
gr dot torture [aw=dweight], over(country, sort(1) des) scale(.7) ///
	name(torture, replace)

* Detailed breakdown in each country.
catplot torture [aw=dweight], over(country, sort(1)des lab(labsize(*.8))) ///
	asyvars percent(country) stack scale(.7) ytitle("") ///
	legend(rows(1) label(3 "Neither") region(fc(none) ls(none))) scheme(burd4) ///
	name(torture, replace)

* Comparing Israel to other European countries.
gen israel:israel = (country=="IL")
la de israel 1 "Israel" 0 "Other EU"

* Comparison of average opposition to torture inside and outside Israel.
prtest torture, by(israel)

* Subset to all European countries but Israel.
drop if israel


* IV: Age
* -------

su age

* Check normality.
hist age, bin(15) normal

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

* Average opposition to torture in each income decile.
gr bar torture, over(income)

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
hist edu, bin(15) normal

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


* ===============
* = ODDS RATIOS =
* ===============


* Odds ratios are common in biostatistics, where analysts are often interested
* in calculating the risk ratio of exposure to a given pathological factor. We
* used the odds ratios here to change our initial perspective on the variable:
* instead of measuring opposition to torture, the odds ratios above relate to
* supporters of torture among those exposed to TV news, as compared to support
* among unexposed respondents.


* Simple example
* --------------

tab torture media

* Handiest way to get odds:
tabodds torture media // shows the odds of being a 'case' instead of a 'control'
tabodds torture media, ciplot

* Odds ratios:
tabodds torture media, or base(1) // odds ratio against lo media exposure
tabodds torture media, or base(2) // odds ratio against hi media exposure

* Save the crosstabulated frequencies to a matrix.
tab torture media, col nof exact matcell(odds)

* Build an odds-ratios statement.
di as txt _n "Respondents with low political TV news exposure were about " ///
	round((odds[2,1]*odds[1,2])/(odds[1,1]*odds[2,2]),.01) " times " ///
	_n "less likely to systematically support torture than other respondents."

* Simple logistic regression provides the same result, except it uses log-odds
* to simplify interpretation: negative log-odds are odds under 1, i.e. lesser
* likelihood, while positive log-odds indicvate higher likelihood.
logit torture media
logit torture media, or     // odds ratio against lo media exposure
logit torture ib1.media, or // odds ratio against hi media exposure


* Complex example
* ---------------

tab torture income4

* Odds across income deciles.
tabodds torture income, ciplot ///
	yti("Odds of opposing torture") xti("HH income deciles") ///
	xlab(1 "Lowest" 10 "Highest")

* Smoother results with less income granularity.
tabodds torture income4, ciplot ///
	yti("Odds of opposing torture") xti("HH income quartiles") ///
	xlab(1 "Lowest" 4 "Highest")


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
