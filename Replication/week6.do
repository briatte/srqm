* What: SRQM Session 6
* Who:  F. Briatte and I. Petev
* When: 2011-10-12

* Data: Eurobarometer (2009).
use "Datasets/ebm2009.dta", clear

* Log.
cap log using "Replication/week6.log", name(week6) replace

* Country codes.
ren v7 ccode

* Weights.
ren v8 popweight
ren v38 ctyweight
gen wgt=popweight*ctyweight

* ======================
* = DEPENDENT VARIABLE =
* ======================

* Crisis: Mitigation through European currency.
fre v493 [aw=wgt]

* Cleaner recoding.

* Visualization.
catplot v493 [aw=wgt], over(ccode, sort(4)des lab(labsize(*.8))) ///
	asyvars percent(ccode) stack scale(.7) ytitle("") ///
	legend(rows(1) region(fc(none) ls(none))) ///
	bar(1, c(navy*.7)) bar(2, c(navy*1.3)) ///
	bar(3, c(sand*.5)) bar(4, c(sand)) bar(5, c(sand*1.5)) ///
	name(mitig, replace)

* Binary recoding.
recode v493 ///
	(1/2=1 "Agree") ///
	(3/4=0 "Disagree") ///
	(else=.), gen(mitig)
la var mitig "Crisis: mitigated through euro"
fre mitig [aw=wgt]

* You can read the frequency of the positive value in a binary variable by 
* inspecting its mean. In this case, the mean gives the fraction of respondents
* that perceive either their domestic government or the EU as the most capable
* actor in regard to the financial crisis:
su mitig [aw=wgt]

* Visualization.
catplot mitig [aw=wgt], over(ccode, sort(2) lab(labsize(*.8))) ///
	asyvars percent(ccode) stack scale(.7) ytitle("") ///
	legend(rows(1) region(fc(none) ls(none))) ///
	bar(1, c(sand)) bar(2, c(navy)) ///
	name(mitig, replace)

* Subset to respondents from Portugal, Italy, Greece and Spain.
keep if inlist(ccode,8,11,12,13)
fre mitig

* =========================
* = INDEPENDENT VARIABLES =
* =========================

* (1) Sex
ren v644 sex
recode sex (1=0 "Male") (2=1 "Female"), gen(female)
la var female "Gender"

* Crosstabulation; Chi-squared and Fisher's exact tests.
tab mitig female
tab mitig female, col nof
tab mitig female, row nof
tab mitig female, exp chi2
tab mitig female, exact

* (2) Age
ren v645 age
ren v646 age4
fre age age4

* Crosstabulation; Chi-squared test.
tab mitig age4, col nof chi2

* (3) Education
ren v642 edu
recode edu ///
	(1/15=1 "15- yrs") ///
	(16/19=2 "16-19 yrs") ///
	(20/max=3 "20+ yrs") ///
	(98=.), gen(edu4)
la var edu4 "Education"

* Crosstabulation; Chi-squared test.
tab mitig edu4, col nof chi2

* (4) Occupation
ren v767 pro

* Crosstabulation; Chi-squared test.
tab mitig pro, col nof chi2

* Visualization with categories ordered by descending order.
gr dot mitig, over(pro, sort(1) des)

* Isolating student respondents with a binary variable.
recode pro (8=1) (else=0), gen(student)
la var student "Student"

* Crosstabulation; Fisher's exact test.
tab mitig student, col nof exact

* (5) Left-right political positioning
ren v638 pol10
ren v639 pol3
ren v640 pol5
fre pol10 pol3 pol5

* Visualization over 10 categories.
catplot mitig, over(pol10) asyvars stack scale(.8) ///
	bar(1, c(sand)) bar(2, c(navy)) legend(region(fc(none) ls(none))) ///
	ytitle("") name(mitig_pol10, replace)

* Visualization over 3 categories.
catplot mitig, over(pol3) asyvars percent(pol3) stack scale(.8) ///
	bar(1, c(sand)) bar(2, c(navy)) legend(region(fc(none) ls(none))) ///
	ytitle("") name(mitig_pol5, replace)

* Visualization over 5 categories.
catplot mitig, over(pol5) asyvars percent(pol5) stack scale(.8) ///
	bar(1, c(sand)) bar(2, c(navy)) legend(region(fc(none) ls(none))) ///
	ytitle("") name(mitig_pol5, replace)

* Chi-squared tests on recodings.
tab mitig pol3, col nofreq chi2
tab mitig pol5, col nofreq chi2

* Confidence intervals for each proportion.
prop mitig, over(pol5)

* (6) Perception of European Union
ren v182 eum

* Crosstabulation; Chi-squared test.
tab mitig eum, col nof chi2

* ========
* = EXIT =
* ========

* Wipe the modified data.
* clear

* Close log (if opened).
cap log close week6

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
