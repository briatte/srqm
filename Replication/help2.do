* What: Assignment No. 2 tips and tricks* Who:  F. Briatte and I. Petev* When: 2012-05-03

// ... this do-file completes the tips and tricks sent after our previous
// ... assignment; each tip can run separately, and has been written to solve
// ... common issues in do-files so far.

// Looking at linear models

* * *

// (0) Summary of export commands

// example data
use datasets/qog2011, clear

// install estout
* ssc install estout // uncomment to run, requires the Interwebs

// correlation matrix
eststo clear
qui estpost correlate wvs_abort bl_asyt25 wvs_theo, ///
	matrix listwise // correlate
esttab using correlates.csv, unstack not compress label replace // export

// regression model
eststo clear // clear memory
eststo m1: reg wvs_abort bl_asyt25 wvs_theo // model 1
eststo m2: reg wvs_abort bl_asyt25 // model 2
eststo m3: reg wvs_abort wvs_theo // model 3
esttab m1 m2 m3, mtitles("Full model" "Education" "Theocracy") // with titles
esttab m1 m2 m3 using models.csv, mtitles("Full model" "Education" "Theocracy") // export

// ... the little bit of code above can easily be adapted to your model
// ... it will simplify the Stata output and allow you to compare multiple models

// ... more examples in the Stata Guide, see also help estout and help esstab
// ... tip: using estout saves you time importing your data and formatting it!

* * *

// (1) Looking at negative findings

// example data
use datasets/qog2011, clear

// summary of dependent variable Y
su wvs_e023

// scatterplot showing linear model and mean value of Y
tw sc wvs_e023 bti_ds, yline(2.26) || lfit wvs_e023 bti_ds, lp(dash)

// ... the model and the mean value of Y are geometrically close
// ... looks like a correct linear fit but almost equal to a constant of mean(Y)
// ... correlation surely exists but will not significantly different from zero

// ... conclusion: association might exist but its effect is statistically negligible
// ... paper should report negative finding if surprising in regard to theory
// ... and absence of statistical significance need not mean no substantive link

reg wvs_e023 bti_ds // confirm negative findings

* * *

// (2) Association tests for ordinal data

// example data
use datasets/ess2008, clear

// ordered categories in the dependent variable
fre imwbcnt

// recode to less groups
recode imwbcnt (0/3=1 "worse") (4/6=2 "--") (7/10=3 "better"), gen(immig)
la var immig "Attitudes twds migrants"

// crosstabs
tab immig maritala, col nof chi2

// ... recoding is handy to bring high-dimensional data to a small number of categories
// ... it allows you to build easily interpretable percentages, tested with the Chi2
// ... however, when you lose categories, you lose information and variance

// ... solution: fall back to original variable for correlation and regression
// ... focus on identifying positive, linear correlation measures
// ... and use crosstabs or t-tests only for additional analysis

// correlation
pwcorr immig agea, sig
pwcorr imwbcnt agea, sig // almost identical but more reliable: variables have more values

// create age groups
gen age10 = floor(agea/10)*10
replace age10 = 15 if age10==15 // minimal age group
replace age10 = 70 if age10>=70 // maximal age group

// crosstabs offer a reading guide across generations
tab age10 immig, row nof

// t-test of age among two extreme reactions towards migrants
ttest agea if immig!=2, by(immig)

// ... paper should report only positive correlation, and mention qualitative
// ... results obtained by looking at further tests (coded in the do-file)

* * *

// (3) Categorical associations

// ... you want to make crosstabs and use the Chi-squared test
// ... as well as odds ratios if you are looking at dummy variables

// data
use datasets/ess2008, clear

fre imptrad
fre maritala

tab imptrad maritala, chi2 // alright, but too many dimensions to make immediate sense

// married dummy
recode marital (1=1 "Married") (missing=.) (nonmissing=0 "Else"), gen(married)
la var married "Married"

// recode to 3 points
recode imptrad (1/2=1 "high") (3/4=2 "med") (5/6=3 "low"), gen(trad3)
la var trad3 "Importance of traditions"

// visualize: the spine/mosaic plot is probably your best apply
spineplot married trad3

// speak in odds ratios
gen tradition=(trad3==1) if !mi(trad3) // dummy variable: "tradition==1" (support)

tab married tradition, exact // Fisher's exact test
logit tradition married, nolog or

// ... odds read: married people are 1.5 more likely to support tradition
// ... more about logistic (logit) regression for categorical in the Stata Guide

* * *

// (4) Comparing countries or country groups

// data
use datasets/ess2008, clear

// ... play it ˆ la Esping-Andersen: use conventional categories of countries
// ... and run separate models and tests on each group

keep if inlist(cntry,"FR","GB","PL","FI") // case selection
fre imptrad // DV

// comparative plots by age
gr bar imptrad, over(agea, lab(tstyle(none))) by(cntry)

// ... imptrad shows decrease in mean value over age
// ... i.e. stronger support (variable is reverse-coded)
// ... hypothesis: age increases support for tradition, 
// ... at a different rate for each country: compare rates with regression

// comparative regression lines
tw lfit imptrad agea, by(cntry)

bys cntry: reg imptrad agea
// ... build model in a similar way, by hypothesizing at country-level
// ... however, do not compare coefficients between models (veeeery risky)
// ... instead, look at comparative values of beta coefficients

* * *

// (5) Comparing at the supranational level

// data
use datasets/qog2011, clear

// describe at the regional level
table ht_region, c(n ccode) // i.e. how many countries per region?
table ht_region, c(mean wvs_abort mean bl_asyt25) // average levels of variables

// the more violent option to get regional data, which destroys your data:
* collapse wvs_theo, by(ht_region)

* * *

// (6) Using nested regression analysis

// example data
use datasets/qog2011, clear

// variables
d wvs_abort wvs_e023 undp_gdi bti_ds wdi_gdpc
gen wdi_gdpc_log=ln(wdi_gdpc)

reg wvs_abort wvs_e023 undp_gdi bti_ds wdi_gdpc_log // full model
nestreg: reg wvs_abort (wvs_e023 undp_gdi) (bti_ds wdi_gdpc_log) // create two blocks

// ... compare blocks using R2: higher R2 indicates higher predicted variance,
// ... which does not necessarily translate into higher explanatory value

* * *

// (7) Plotting clean regression graphs

// example data
use datasets/qog2011, clear

// clean graph schemes
* net from "http://leuven.economists.nl/stata" // uncomment both lines to run
* net install schemes

set scheme bw

// example scatterplots:
sc wvs_abort wvs_e023
// with linear fit:
tw lfit wvs_abort wvs_e023 || sc wvs_abort wvs_e023 
// with quadratic fit:
tw qfit wvs_abort undp_gdi || sc wvs_abort undp_gdi 

// for regression:
reg wvs_abort wvs_e023 undp_gdi bti_ds wdi_gdpc_log 
rvfplot, yline(0) // residuals versus fitted values
rvpplot undp_gdi, yline(0) // residuals versus one predictor

// ... see the Stata Guide for more diagnostic plots for regression
// ... and remember to constrain the amount of figures in your paper

