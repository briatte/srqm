* What: SRQM Session 8
* Who:  F. Briatte and I. Petev
* When: 2011-10-24


* ================
* = INTRODUCTION =
* ================


* Data: Quality of Government (2011).
use "Datasets/qog2011.dta", clear

* Log.
cap log using "Replication/week8.log", name(week8) replace


* =============
* = VARIABLES =
* =============


ren wdi_fr births
ren bl_asyt25 schooling
gen gdpc = unna_gdp/unna_pop
la var gdpc "Real GDP/capita (constant USD)"
ren undp_hdi hdi
ren ti_cpi corruption
ren gid_fgm femgovs
d births schooling gdpc hdi corruption femgovs


* ===============
* = CORRELATION =
* ===============


* (1) Fertility Rates and Schooling Years
* ---------------------------------------

scatter births schooling

pwcorr births schooling
pwcorr births schooling, obs sig

* (2) Schooling Years and (Log) Gross Domestic Product
* ----------------------------------------------------

sc gdpc schooling

* A first look at the scatterplot shows no clear linear pattern, but we know
* from a previous session that the logarithmic variable transformation can be
* used to visualize exponential relationships differently. Consequently, we
* try to visualise the same variables with a logarithmic scale for GDP/capita.
sc gdpc schooling, yscale(log)

* In this classical case, log units are more informative than metric ones to
* identify the relationship between the dependent and independent variables.
gen log_gdpc = ln(gdpc)
la var log_gdpc "Real GDP/capita (log units)"

* Verify the transformation.
sc log_gdpc schooling

* Obtain summary statistics.
su log_gdpc schooling

* Visual inspection of the relationship within the mean-mean quadrants.
sc log_gdpc schooling, yline(7.5) xline(6)

* Verify inspection computationally.
pwcorr log_gdpc schooling, obs sig


* (3) Corruption and Human Development
* ------------------------------------

* Before graphing the variables, we need to pass a few graph options, because
* the Corruption Perception Index is reverse-coded (0 marks high corruption,
* and 10 marks very low corruption). To enhance visual interpretation, we
* therefore use an inverted axis scale, and add horizontal axis labels to it.
sc corruption hdi, yscale(rev) ylabel(0 "High" 10 "Low", angle(hor))

* The pattern that appears graphically is not linear: corruption is stationary
* for low to medium values of HDI, and then rapidly drops towards high values.
* Given its shape, this relationship is thus more likely to be quadratic, i.e.
* of the form y = x^n where y is corruption, x is HDI and n > 1 is a power.
* If the correlation coefficient is statistically significant, we might treat
* the relationship between corruption and HDI as approximately linear, but we
* will lose some of the information observed graphically by doing so.
pwcorr corruption hdi, obs sig


* (4) Female Government Ministers and Corruption
* ----------------------------------------------

* Obtain summary statistics.
su femgovs corruption

* Visual inspection of the relationship within the mean-mean quadrants.
sc femgovs corruption, yline(15) xline(4)

* No clear pattern emerges from the scatterplot above. Never force a pattern
* onto the data: relationships should be apparent, not constructed. If there is
* no straightforward relationship, disregard it. Identically, never include a
* graph in your work if the relationship that it intends to show will not
* strike the reader between the eyes (i.e. run an intra-ocular trauma test).
* Inconclusive visual inspection can come with significant correlations, as is
* the case here if you actually compute the coefficient, but visual inspection
* and theoretical elaboration provide no substantive justification for it.


* ======================
* = CORRELATION MATRIX =
* ======================


* The most practical way to consider all possible correlations in a list of
* predictors (or independent variables) is to build a correlation matrix out
* of their respective pairwise correlations. "Pair-wise" indicates that the
* correlation coefficient uses only pairs of valid, nonmissing observations,
* and disregards all observations where any of the variables is missing.
pwcorr births schooling log_gdpc hdi corruption femgovs

* The most common way to indicate statistically significant correlations in
* a correlation matrix is to use asterisks (stars) to mark them when their
* p-value is below the level of statistical significance.
pwcorr births schooling log_gdpc hdi corruption femgovs, star(.05)

* For explorative purposes, another option can be used to print out only the
* statistically significant correlations, which comes in handy especially in
* very large matrixes with majorily insignificant correlation coefficients.
pwcorr births schooling log_gdpc hdi corruption femgovs, print(.05)


* ==============
* = GRAPH TIPS =
* ==============


* (1) Using macros to set graph options
* -------------------------------------

* Macros are crucial elements of programming, not just in Stata but in any
* programming language. The example below is just one very simple example of
* what macros can do for you. As you know from experience, Stata requires
* passing a lot of options to produce informative graphs. If you are planning
* to use identical options on several graphs, you can store these options in
* a global macro and then call it by entering its name with a $ sign.
global ccode = "msymbol(i) mlabpos(0) mlabel(ccodewb) mlabcolor(gs4)"

* In the following examples, passing the "$ccode" option will actually pass
* the graphical options stored in the ccode ("country codes) macro. 

* Improved graph for Example (1)
sc births schooling, $ccode name(nat_edu, replace)

* Improved graph for Example (2)
sc log_gdp schooling, $ccode name(gdp_edu, replace)

* Improved graph for Example (3)
sc corruption hdi, $ccode yscale(rev) ylabel(0 "High" 10 "Low", angle(hor)) ///
	name(cpi_hdi, replace)

* Improved graph for Example (4)
sc corruption femgovs, $ccode ylabel(0 "High" 10 "Low", angle(hor)) ///
	name(cpi_femgov, replace)

* For another example of graph settings, try using this macro:
* global ccode = "msymbol(Oh) mcolor(gs4) mlabel(ccodewb) mlabcolor(gs8)"


* (2) Scatterplot matrixes
* ------------------------

* A scatterplot matrix contains all possible bivariate relationships between
* any number of variables. Building a matrix of your DV and IVs allows to spot
* relationships between IVs, which will be useful later on in your analysis.
gr mat births schooling gdpc hdi corruption femgovs


* ========
* = EXIT =
* ========


* Clean all graphs from memory.
* gr drop _all

* Wipe the modified data.
* clear

* Close log (if opened).
cap log close week8

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
