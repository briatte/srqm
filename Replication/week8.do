* What: SRQM Session 8
* Who:  F. Briatte and I. Petev
* When: 2011-10-24


* ================
* = INTRODUCTION =
* ================


* Install additional packages if needed.
foreach p in mkcorr {
	cap which `p'
	if _rc==111 cap noi ssc install `p'
}

* Data: Quality of Government (2011).
use "Datasets/qog2011.dta", clear

* Log.
cap log using "Replication/week8.log", name(week8) replace


* ================
* = DESCRIPTIONS =
* ================


* Rename variables to short handles.
ren (wdi_fr bl_asyt25 undp_hdi ti_cpi gid_fgm) (births schooling hdi corruption femgovs)

* Compute GDP per capita.
gen gdpc = unna_gdp/unna_pop
la var gdpc "Real GDP/capita (constant USD)"

* Have a quick look.
codebook births schooling gdpc hdi corruption femgovs, c


* ===============
* = CORRELATION =
* ===============


* IV: Fertility Rates and Schooling Years
* ---------------------------------------

scatter births schooling

pwcorr births schooling
pwcorr births schooling, obs sig

* IV: Schooling Years and (Log) Gross Domestic Product
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
pwcorr gdpc log_gdpc schooling, obs sig


* IV: Corruption and Human Development
* ------------------------------------

* Before graphing the variables, we need to pass a few graph options, because
* the Corruption Perception Index is reverse-coded (0 marks high corruption,
* and 10 marks very low corruption). To enhance visual interpretation, we
* therefore use an inverted axis scale, and add horizontal axis labels to it.
sc corruption hdi, yscale(rev) ///
	xlab(0 "Low" 1 "High") ylab(0 "Highly corrupt" 10 "Lowly corrupt", angle(hor))

* The pattern that appears graphically is not linear: corruption is stationary
* for low to medium values of HDI, and then rapidly drops towards high values.
* Given its shape, this relationship is thus more likely to be quadratic, i.e.
* of the form y = x^n where y is corruption, x is HDI and n > 1 is a power.
* If the correlation coefficient is statistically significant, we might treat
* the relationship between corruption and HDI as approximately linear, but we
* will lose some of the information observed graphically by doing so.
pwcorr corruption hdi, obs sig


* IV: Female Government Ministers and Corruption
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


* Correlation and scatterplot matrixes
* ------------------------------------


* Start with visual inspection of the data organized as a scatterplot matrix.
* A scatterplot matrix contains all possible bivariate relationships between
* any number of variables. Building a matrix of your DV and IVs allows to spot
* relationships between IVs, which will be useful later on in your analysis.
* Note that the example below shows the untransformed measure of GDP per capita.
gr mat births schooling gdpc hdi corruption femgovs, name(gr_matrix, replace)

* You could also look at a sparser version of the matrix that shows only a
* subset of geographical regions (subsaharan Africa and Western states).
gr mat births schooling log_gdpc hdi corruption femgovs if inlist(ht_region,4,5)

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

* Export a correlation matrix.
mkcorr births schooling gdpc hdi corruption femgovs, lab num sig log(corr.txt) replace


* Marker labels for scatterplots
* ------------------------------

* Here's a quick graph tip that will be useful to those working on country-level
* data, where it might be interesting to show country codes in scatterplots.

* Macros are crucial elements of programming, not just in Stata but in any
* programming language. The example below is just one very simple example of
* what macros can do for you. Note that this example is not recommendable as
* a programming tip (you would not normally fiddle with your global macros).

* As you know from experience, Stata requires passing a lot of options to 
* produce informative graphs. If you are using a set of consistent options
* on several graphs, you can store these options in a global macro and call
* it by entering its name with a $ (dollar) sign. Example below:
global ccode = "ms(i) mlabpos(0) mlab(ccodewb)"

* The option make the marker symbol invisible, then center the marker label and
* fill it with the ccodewb variable (just as for commands, you learn how to pass
* these options by reading the help pages, which can be slightly excruciating).
* In the following examples, passing the "$ccode" option will actually pass
* the graphical options stored in the ccode ("country codes") macro.

* Improve previous example.
sc births schooling, $ccode name(fert_edu1, replace)

* Add color to Western states.
sc births schooling, $ccode || ///
	sc births schooling if ht_region==5, $ccode legend(off) ///
	name(fert_edu2, replace)

* Add color to subsaharan Africa, remove color for ROTW.
sc births schooling, mlabc(gs10) $ccode || ///
	sc births schooling if ht_region==4, $ccode legend(off) ///
	name(fert_edu3, replace)


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close week8

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
