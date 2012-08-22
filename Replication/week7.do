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

* Weights.
svyset [pw=dweight] // weighting scheme set to country-specific population


* ================
* = DESCRIPTIONS =
* ================


* DV: Justifiability of torture
* -----------------------------

* Attitudes towards torture (hypothetical terrorist scenario).
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
bys cntry: ci torture [aw=dweight] // weighted by country-specific population

* Average opposition to torture in each country.
gr dot torture [aw=dweight], over(cntry, sort(1) des) scale(.7)

* Detailed breakdown in each country (requires catplot package)
* ssc install catplot
catplot trrtort [aw=dweight], over(cntry, sort(1)des lab(labsize(*.8))) ///
	asyvars percent(cntry) stack scale(.7) ytitle("") ///
	legend(rows(1) label(3 "Neither") region(fc(none) ls(none))) ///
	bar(1, c(sand)) bar(2, c(sand*.7)) bar(3, c(dimgray)) ///
	bar(4, c(navy*.7)) bar(5, c(navy)) ///
	name(torture, replace)

* Comparing Israel to other European countries.
gen israel:israel = (cntry=="IL")
la de israel 1 "Israel" 0 "Other EU"

* Comparison of average opposition to torture inside and outside Israel.
prtest torture, by(israel)

* Subset to all European countries but Israel.
drop if israel


* IV: Age
* -------

ren agea age

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

recode gndr (1=0 "Male") (2=1 "Female") (else=.), gen(female) // dummify
la var female "Gender"

* Significance tests:
tab torture female, exp chi2 V exact

* Comparison of proportions in each category.
prtest torture, by(female)


* IV: Income deciles
* ------------------

ren hinctnta income

* Average opposition to torture in each income decile.
gr bar torture, over(income)

* Recoding to 4 income groups.
recode income (1/3=1 "D1-D3") (4/6=2 "D4-D6") ///
	(7/9=3 "D7-D9") (10=4 "D10"), gen(income4)
la var income4 "HH income"

* Conditional probabilities:
tab torture age4, col nof    // column percentages
tab torture age4, row nof    // rows percentages

* Significance tests:
tab torture income4, exp chi2 V


* IV: Education
* -------------

ren eduyrs edu

* Verify normality.
hist edu, bin(15) normal

* Comparison of average educational attainment in each category.
ttest edu, by(torture)


* IV: Religious faith
* -------------------

fre rlgblg rlgdnm

* Comparison of proportions in each category.
prtest torture, by(rlgblg)

* Recoding to simpler groups.
recode rlgdnm (.a=1 "Not religious") (1/4=2 "Christian") ///
	(5=3 "Jewish") (6=4 "Muslim") (7/8=.) , gen(faith)
la var faith "Religious faith"

* Conditional probabilities:
tab torture faith, col nof    // column percentages
tab torture faith, row nof    // rows percentages

* Significance tests:
tab torture faith, exp chi2 V

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


* IV: Political positioning
* -------------------------

ren lrscale pol

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

fre tvpol

* Alternative reading (binary mean). The nolabel (nol) option gets rid of the
* value labels and makes the output table a tad softer on the reader's eye.
tab tvpol, summ(torture) nol

* Alternative reading (plot).
tab tvpol, plot

* Recoding to binary.
recode tvpol (0/3=0 "Low") (4/7=1 "High"), gen(media)
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
di as txt _n "Respondents with high political TV news exposure were about " ///
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
tab torture faith

* Odds across income deciles.
tabodds torture income, ciplot ///
	yti("Odds of opposing torture") xti("HH income deciles") ///
	xlab(1 10)

* Smoother results with less income granularity.
tabodds torture income4, ciplot ///
	yti("Odds of opposing torture") xti("HH income deciles") ///
	xlab(1 "Lowest" 4 "Highest")


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close week7

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
