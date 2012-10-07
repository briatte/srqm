* What: SRQM Session 6
* Who:  F. Briatte and I. Petev
* When: 2011-10-12


* ================
* = INTRODUCTION =
* ================


* Data: Eurobarometer (2009).
use "Datasets/ebm2009.dta", clear

* Log.
cap log using "Replication/week6.log", name(week6) replace

* Required packages.
foreach p in catplot fre tab_chi {
	cap which `p'
	if _rc==111 ssc install `p'
}


* ================
* = DESCRIPTIONS =
* ================


* Country codes.
ren v7 ccode

* Weights.
ren v8 popweight
ren v38 ctyweight
gen wgt=popweight*ctyweight
svyset [pw=wgt] // weighting scheme set to whole European population


* DV: Mitigation of crisis through European currency
* --------------------------------------------------

fre v493
svy: tab v493 // weighted proportions

* Visualization.
catplot v493, over(ccode, sort(4)des lab(labsize(*.8))) ///
	asyvars percent(ccode) stack scale(.7) ytitle("") ///
	legend(rows(1) region(fc(none) ls(none))) ///
	bar(1, c(navy*.7)) bar(2, c(navy*1.3)) ///
	bar(3, c(sand*.5)) bar(4, c(sand)) ///
	name(mitig, replace)

* Binary recoding.
recode v493 ///
	(1/2=1 "Agree") ///
	(3/4=0 "Disagree") ///
	(else=.), gen(mitig)
la var mitig "Crisis: mitigated through euro"

fre mitig
svy: tab mitig // weighted proportions

* You can read the frequency of the positive value in a binary variable by 
* inspecting its mean. In this case, the mean gives the fraction of respondents
* that perceive either their domestic government or the EU as the most capable
* actor in regard to the financial crisis.


* Visualization.
catplot mitig, over(ccode, sort(2) lab(labsize(*.8))) ///
	asyvars percent(ccode) stack scale(.7) ytitle("") ///
	legend(rows(1) region(fc(none) ls(none))) ///
	bar(1, c(sand)) bar(2, c(navy)) ///
	name(mitig, replace)

* Subset to respondents from Portugal, Italy, Greece and Spain.
keep if inlist(ccode,8,11,12,13)
fre mitig


* IV: Sex
* -------

ren v644 sex
recode sex (1=0 "Male") (2=1 "Female"), gen(female)
la var female "Gender"

* Crosstabulations:
tab mitig female       // raw frequencies
tab mitig female, cell // cell percentages

* Conditional probabilities:
tab mitig female, col nof    // column percentages
tab mitig female, row nof    // rows percentages

* Significance tests:
tab mitig female, exp chi2   // Chi-squared test (with expected frequencies)
tab mitig female, exp chi2 V // Cramer's V (requires an acute accent on 'e')

* Chi-squared residuals:
tabchi mitig female, r noo noe // raw residuals
tabchi mitig female, p noo noe // Pearson residuals

* Fisher's exact test
tab mitig female, exact


* Notes on association tests
* --------------------------

* - The Chi-squared test does not operate through the normal distribution to
* determine statistical significance. The degrees of freedom of the crosstab are
* used against a different distribution that expresses different assumptions, of
* which an important one is that the accuracy of the test is insatisfactory when
* cell counts fall under 5-10 (depending on what you want to call accuracy).

* - The general idea of nonparametric tests is that they harness a different
* set of properties in the sample than the total number of observations n, using
* instead the properties of table cells in different ways. Cramer's V is a means
* to reinject n in the equation: it measures the strength of association as read
* in a Chi-squared tests, from -1 to 1 on 2x2 tables, and from 0 to 1 otherwise.

* - A further refinement of the Chi-squared test is to read its residuals, i.e.
* the substraction of observed - expected frequencies in each cell. To relate
* the residuals to the overall table, we divide them by a square root of table
* dimensions to obtain Pearson residuals, where extreme values point the cells
* contributing most to the association.

* - Last, Fisher's exact test expresses yet other properties that make it exact
* from a statistical perspective, for very uninteresting reasons that I'll skip.
* It primarily applies to 2x2 tables, and fails on tables with high dimensions.
* You can try to use it as an alternative to the Chi-squared test when you have
* both low cell counts and low dimensions, i.e. low 'r x c' (rows by columns).


* IV: Age
* -------

ren v645 age
ren v646 age4

* Mean age in each age group.
tab age4, summ(age)

* Conditional probabilities:
tab mitig age4, col nof    // column percentages
tab mitig age4, row nof    // rows percentages


* IV: Education
* -------------

ren v642 edu
recode edu ///
	(1/15=1 "15- yrs") ///
	(16/19=2 "16-19 yrs") ///
	(20/max=3 "20+ yrs") ///
	(98=.), gen(edu4)
la var edu4 "Education"

* Mean age at each educational level.
tab edu4, summ(age)

* Conditional probabilities:
tab mitig edu4, col nof    // column percentages
tab mitig edu4, row nof    // rows percentages

* Significance tests:
tab mitig edu4, exp chi2 V


* IV: Occupation
* --------------

ren v767 pro

* Visualization with categories ordered by descending order.
gr dot mitig, over(pro, sort(1) des)

* Isolating student respondents with a binary variable.
gen student = (pro==8)

* Conditional probabilities:
tab mitig student, col nof    // column percentages
tab mitig student, row nof    // rows percentages

* Significance tests:
tab mitig edu4, exp chi2 V


* IV: Left-right political positioning
* ------------------------------------

fre v638-v640   // multiple choices here
ren v638 pol10 // using the version with most dimensions (warning, large tables)

* Visualization over 10 categories.
gr dot mitig, over(pol10)

* Conditional probabilities:
tab mitig pol10, col nof    // column percentages
tab mitig pol10, row nof    // rows percentages

* Significance tests:
tab mitig pol10, exp chi2 V


* IV: Perception of European Union
* --------------------------------

recode v182 (1=1 "Benefited") (2=0 "Not benefited"), gen(eum) // create a dummy

* Conditional probabilities:
tab mitig eum, col nof    // column percentages
tab mitig eum, row nof    // rows percentages

* Significance tests:
tab mitig eum, exp chi2 V exact // reminder: Cramer's V is [-1,1] on 2x2 tables
tabchi mitig eum, p noo noe     // Pearson residuals

* Save the crosstabulated frequencies to a matrix.
tab mitig eum, col matcell(odds)

* Explanatory statement.
di as txt _n "Respondents who think that their country benefited from EU membership are" _n ///
	"about " round((odds[2,1]*odds[1,2])/(odds[2,2]*odds[1,1]),.1) " times " ///
	"more likely to think that the euro mitigated the crisis" _n ///
	"than respondents who think that their country has not benefited from it." 

* Quick demonstration of odds and odds ratios (more next week).
tabodds mitig eum
tabodds mitig eum, or


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close week6

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
