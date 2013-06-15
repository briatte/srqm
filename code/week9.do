
/* ------------------------------------------ SRQM Session 9 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Fertility and Education, Part 3

 - DATA:   Quality of Government (2013)
 
   This is our final do-file with the Quality of Government example that we have
   been running over three sessions. It explains how to build on correlation and
   simple linear regression to produce complete linear regression models.
   
   The code contains details on several aspects of multiple linear regression.
   It also shows how to use the -estout- command to store and export the results
   of regression models.
   
   For your second draft, go as far as possible with multiple linear regression.
   Start with correlations if applicable, then go forward with simple linear
   regressions (add scatterplots if your predictors are continuous).

   Follow the instructions from the draft paper template. If you manage to go as
   far as diagnosing your model, discuss them and add interaction terms if you
   detect issues of multicollinearity.
   
   The next sessions will provide another way to model the data for dependent
   variables that are (or are closer to being) categorical in nature, and will
   go deeper into the core mechanics of regression modelling.

   Last updated 2013-05-28.

----------------------------------------------------------------------------- */


* Install required commands.
foreach p in fre estout leanout mkcorr {
    cap which `p'
    if _rc == 111 cap noi ssc install `p' // install from online if missing
}

* Export log.
cap log using code/week9.log, replace


* ====================
* = DATA DESCRIPTION =
* ====================


use data/qog2013, clear

* Rename variables to short handles.
ren (wdi_fr bl_asy25mf wdi_hiv ciri_wosoc) (births schooling hiv womenrights)

* Transformation of real GDP per capita to logged units.
gen log_gdpc = ln(unna_gdp / unna_pop)
la var log_gdpc "Real GDP/capita (constant USD, logged)"

* Dummy for the highest quartile of HIV/AIDS prevalence.
su hiv, d
gen aids = (hiv > 1.5) if !mi(hiv)
la var aids "Highest HIV/AIDS prevalence quartile"

* Recode regions to less, shorter labels.
recode ht_region (6/10 = 6), gen(region)
la var region "Geographical region"
la val region region
la def region 1 "E. Europe and PSU" 2 "Lat. America" ///
    3 "N. Africa and M. East" 4 "Sub-Sah. Africa" ///
    5 "W. Europe and N. America" 6 "Asia, Pacific and Carribean" ///
    , replace


* Subsetting
* ----------

* Check missing values.
misstable pat births schooling log_gdpc aids, freq

* Check sampling bias due to low availability of schooling years.
gen mi = mi(schooling)
gr hbar (count) schooling (count) mi, over(region, sort(2)des) stack ///
    legend(order(1 "N(schooling)" 2 "Missing data")) ///
    name(mi, replace)

* Delete incomplete observations.
drop if mi(births, schooling, log_gdpc, aids, womenrights)

* Final sample size.
count


* Export summary statistics
* -------------------------

* The next command is part of the SRQM folder. If Stata returns an error when
* you run it, set the folder as your working directory and type -run profile-
* to run the course setup, then try the command again. If you still experience
* problems with the -stab- command, please send a detailed email on the issue.

stab using week9_stats.txt, replace ///
    mean(births schooling log_gdpc) ///
    prop(aids region)

/* Syntax of the -stab- command:

 - using FILE  - name of the exported file; plain text (.txt) recommended
 - replace     - overwrite any previously existing file
 - mean()      - summarizes a list of continuous variables (mean, sd, min, max)
 - prop()      - summarizes a list of categorical variables (frequencies)

  In the example above, the -stab- command will export two files to the working
  directory, containing summary statistics (week9_stats.txt) and a correlation
  matrix (week9_correlations.txt) created with the -corr()- argument. */


* =====================
* = ASSOCIATION TESTS =
* =====================


* Coefficients matrix.
corr births schooling log_gdpc

* Scatterplot matrix.
gr mat births schooling log_gdpc, half ///
    name(mat, replace)

* Export method using -mkcorr-.
mkcorr births schooling log_gdpc, ///
	lab num sig log("week9_mkcorr.txt") replace

* Export method using -estout-.
eststo clear
qui estpost correlate births schooling log_gdpc, matrix listwise
esttab using "week9_estpost.txt", unstack not compress label replace


* =====================
* = REGRESSION MODELS =
* =====================


* Simple linear regressions
* -------------------------

* We have covered simple linear regression last week, and we briefly mentioned 
* 'lin-log' equations then. There are more situations to cover in theory, so 
* review both notions together. Recall, first, the regression equation in the 
* simplest case, where all variables are linear: Y = a + BX.

* IV: Education.
sc births schooling || lfit births schooling, ///
	name(simplereg1, replace)
reg births schooling

* An increase in one unit of schooling (years) is associated to a negative 
* variation of -.4 births, or rather, 2-3 additional years of schooling are
* associated with birth rates that are one child lower on average. When the
* IV is logged, things get complex because the association rule changes.

* IV: Real GDP per capita.
sc births log_gdpc || lfit births log_gdpc, ///
	name(simplereg2, replace)
reg births log_gdpc

* In this 'lin-log' equation, a 1% increase in GDP per capita is associated to a
* 0.01 * -.8 variation in the birth rate, or more exactly, -.8 * log(1.01). The
* mathematical trick is now to reverse the equation to understand the mechanism:

* Inverting the terms.
reg log_gdpc births

* The equation is now log-linear ('log-lin') instead of being 'lin-log'. The
* interpretation is: an increase in one child per woman is associated to GDP
* per capita that is 100 * -.8 = 80% lower (remember: on average).

* Illustrate the principle with two regions different by one child per woman.
tab region if region > 4, su(births)
tab region if region > 4, su(wdi_gdpc)

* In 'lin-log' and 'log-lin' equations, changes are proportionate rather than
* absolute. In a 'log-log' model, interpretation is proportionate on both sides
* of the equation: a 1% change in X is associated to a B% change in Y.

* IV-IV interaction.
sc schooling log_gdpc || lfit schooling log_gdpc, ///
	name(simplereg3, replace)
reg schooling log_gdpc


* Multiple linear regression
* --------------------------

* With schooling in metric units.
reg births schooling log_gdpc

* Recall the last model.
reg

* Recall the last model, with cleaner output.
leanout:


* Standardised ('beta') coefficients
* ----------------------------------

* With standardised, or 'beta', coefficients (abbreviated to -b- hereinafter).
reg births schooling log_gdpc, beta

* Proof of concept: Each variable in the equation has a different distribution
* and therefore a different standard deviation. As such, regression with metric
* coefficients cannot inform us of how variables perform against each other in
* explaining variance, because different metrics make coefficients uncomparable.
* One unit of births, for instance, is one child, while one log-unit of GDP per
* capita is, after unlogging, millions of U.S. dollars: their coefficient are
* produced in these units and their values are therefore incommensurable.
su births schooling log_gdpc

* If each variable had a mean of 0 and variance of 1, then the coefficients
* would become comparable because they would be following the unique metric
* of a standard normal distribution. Standardising is the name of that process
* that loses the metric, sensible units of variables to create a fictional view
* of coefficients that indicates which coefficient produces the biggest effect
* on the dependent variable and thus explains most variance within the model.
egen std_births    = std(births)
egen std_schooling = std(schooling)
egen std_log_gdpc  = std(log_gdpc)
su std_*

* Compare both regression outputs. The first one is the linear regression that
* produces identical coefficients to the right hand column of the second one.
reg std_*
reg births schooling log_gdpc, b

* Using the second command shown above is much quicker than using the 'std_*'
* trick that is featured here only as a teaching example. Note, finally, that
* you should NOT report standardized coefficients: their use is controversial,
* and their interpretation is less substantive than unstandardized ones. Your
* focus should always be on results expressed in meaningful units.


* Dummies (categorical variables)
* -------------------------------

* Visualizing two categories (Asia and Africa) within the sample.
tw (sc births schooling if region == 4, ms(O)) ///
    (sc births schooling if region == 6, ms(O)) ///
    (sc births schooling if !inlist(region,4,6), mc(gs10)) ///
    (lfit births schooling, lc(gs10)), ///
    legend(order(1 "African countries" 3 "Rest of sample" ///
    2 "Asian countries" 4 "Fitted values") row(2)) yti("Fertility rate") ///
    name(reg_geo1, replace)

* Previous regression model.
reg births schooling log_gdpc

* Previous regression model with geographical region and HIV dummies.
reg births schooling log_gdpc i.region

* Proof of concept: A dummy simply codes for a particular category against all
* others. Running a dummy in a regression models adds a component to the linear
* equation for which the variable is equal either 0 or 1. Consequently, its
* coefficient indicates how each category performs in relation to the baseline.
* The baseline is, by default, the first category in the variable. Looking at
* predicted values, we can draw parallel regression lines for dummies.

* Bivariate regression model, for demonstration purposes.
reg births schooling i.region

* Storing fitted (predicted) values.
cap drop yhat
predict yhat

* Regression lines for the predicted values of Asia and Africa.
tw (sc births schooling if region == 4, mc(blue) ms(O)) ///
    (sc births schooling if region == 6, mc(red) ms(O)) ///
    (sc births schooling if !inlist(region,4,6), mc(gs10)) ///
    (rcap yhat births schooling if region == 4, ///
    	c(l) lc(blue) lp(dash) msize(tiny)) ///
    (rcap yhat births schooling if region == 6, ///
    	c(l) lc(red) lp(dash) msize(tiny)) ///
    (sc yhat schooling if region == 4, c(l) ms(i) mc(blue) lc(blue)) ///
    (sc yhat schooling if region == 6, c(l) ms(i) mc(red) lc(red)), ///
    legend(order(1 "African countries" 6 "Fitted values (Africa)" ///
    	4 "Residuals (Africa)" ///
    	2 "Asian countries" 7 "Fitted values (Asia)" ///
    	5 "Residuals (Asia)") row(2)) ///
    name(reg_geo2, replace)

* The example above is just a teaching demonstration: geographical continents
* are not appropriate as predictors. Let's now run some substantive examples,
* using a dummy and a 4-level categorical predictor.

* Visualizing HIV/AIDS dummy within the sample.
tw (sc births schooling if !aids, ms(O)) ///
    (sc births schooling if aids, ms(O)) ///
    (lfit births schooling, lc(gs10)), ///
    legend(order(2 "High AIDS prevalence" 1 "Rest of sample") row(1)) ///
    yti("Fertility rate") ///
    name(reg_aids1, replace)

* Regression line for the HIV/AIDS dummy.
tw (sc yhat aids) (lfit yhat aids), xlab(0 "Low" 1 "High") ///
	name(reg_aids2, replace)

* Comparison of t-test and regression results for a single dummy.
ttest yhat, by(aids)
reg yhat i.aids

* Switching to fertility and women's rights.
fre womenrights

* We start by visualizing the average fertility for each level of rights. The 
* plot contains a LOWESS smoothed trend to show the DV mean at each level.
sc births womenrights, yti("Fertility rate") || lowess births womenrights, ///
	name(fert_womenrights, replace)

* Regression model.
reg births i.womenrights

* The baseline category here is womenrights = 0 (no women's rights). Compared
* to countries in this category, other countries have lower mean fertility rates
* and the effect increases as women's rights increases from categories 1 to 3.

* Change the baseline category to highest level "3" of women's rights. This is
* convenient when you need to compare from a reference category that is not the
* first one in the coding of the variable, which is the Stata default.
reg births ib1.womenrights


* =========================
* = REGRESSION DIAGNOSTICS =
* =========================


* Rerun regression model. Note that the "i." prefix is optional for dummies.
reg births schooling log_gdpc aids i.womenrights

* Storing fitted (predicted) values.
cap drop yhat
predict yhat


* (1) Standardized residuals
* --------------------------

* Store the unstandardized (metric) residuals.
cap drop r
predict r, resid

* Assess the normality of residuals.
kdensity r, norm legend(off) ti("") ///
    name(diag_kdens, replace)

* Homoskedasticity of the residuals versus fitted values (DV).
rvfplot, yline(0) ms(i) mlab(ccodewb) name(diag_rvf, replace)

* Store the standardized residuals.
cap drop rsta
predict rsta, rsta

* Identify outliers beyond 2 standard deviation units.
sc rsta yhat, yline(-2 2) || sc rsta yhat if abs(rsta) > 2, ///
    ylab(-3(1)3) mlab(ccodewb) legend(lab(2 "Outliers")) ///
    name(diag_rsta, replace)


* (2) Heteroskedasticity
* ----------------------

* Homoskedasticity of the residuals versus one predictor (IV), also showing the
* outliers above two standard deviation units (standardised residuals). This is
* a more complex diagnostic that shows how one variable influences the model in
* the background of the main regression equation. It might show some predictors
* are responsible for the overall sampling distribution of the residuals, which
* means that the model is captive of a restricted number of predictors.
sc r schooling, ///
	yline(0) mlab(ccodewb) legend(lab(2 "Outliers")) ///
	name(diag_edu1, replace)

* The trend in the error term can be visualized as a LOWESS curve to show when
* and how departures from homogenous variance occur throughout the sample as a
* function of the predictor. The trend reflects the influence of outliers with
* reference to that particular predictor: if the error term of the model shows
* a pattern in its standard errors, the LOWESS curve will show it by deviating
* from the null y-axis at values of the IV where the residuals are "clustered"
* above or below the expected mean of zero (which indicates homoskedasticity).
lowess rsta schooling, bw(.5) yline(0) ///
	name(diag_edu2, replace)


* (3) Variance inflation and interaction terms
* --------------------------------------------

* The Variance Inflation Factor (VIF) diagnoses an issue with 'kitchen sink'
* models that use high numbers of correlated variables together in the model,
* which measures several times the same effect and creates multicollinearity.
* This problem renders the regression coefficients useless. Critical cut-off
* points for variance inflation are VIF > 10 or 1/VIF < .1 (tolerance). Each
* VIF is computed as the reciprocal of the inverse R-squared, 1/(1-R^2), for
* each predictor in the model (that is, the R-squared of that variable minus
* the R-squared of the entire model without it).
vif

* Adding an interaction term is a technique to account for the variance that
* two variables explain in each other. The effect is calculated by multiplying
* the two variables together and throwing that product in the regression model.
* The regression coefficient for this product is the interaction effect. If that
* effect is significantly large, the model accounts for it by isolating it and
* reading other coefficients.
gen schoolingXlog_gdpc = schooling * log_gdpc
la var schoolingXlog_gdpc "GDP * Education"

* Regression model.
reg births schooling log_gdpc aids

* Regression model with an interaction term.
reg births schooling log_gdpc schoolingXlog_gdpc aids

* Standardised coefficients reveal the extent to which the interaction actually
* influences the model, in comparison to all other included predictors (IVs).
reg births schooling log_gdpc schoolingXlog_gdpc aids, b

* Last, a shorter way to write up an interaction for two continuous predictors.
reg births c.schooling##c.log_gdpc aids, b


* ========================
* = EXPORT MODEL RESULTS =
* ========================


* This section shows how to export regression results, in order to avoid having
* to copy out the results by hand, copy-paste or any other risky (non)technique
* that you might come up with at that stage. Exporting regression results also
* make it easier to build several regression models based on varying sets of
* covariates (independent variables), in order to compare their coefficients.

* The next commands require that you install the -estout- package first. Another
* frequently used command for the same task is the -outreg- or -outreg2- command
* that can be downloaded with -ssc install-.

* Wipe any previous regression estimates.
eststo clear

* Model 1: 'Baseline model'.
eststo M1: qui reg births schooling log_gdpc

* Re-read, in simplified form.
leanout:

* Model 2: Adding the HIV/AIDS dummy.
eststo M2: qui reg births schooling log_gdpc aids

* Re-read, in simplified form.
leanout:

* Model 3: Adding the interaction between education and wealth.
eststo M3: qui reg births c.schooling##c.log_gdpc aids

* Re-read, in simplified form.
leanout:

* Compare all models on screen.
esttab M1 M2 M3, lab b(1) se(1) sca(rmse) ///
    mti("Baseline" "Control" "Interaction")

* Export all models for comparison and reporting.
esttab M1 M2 M3 using week9_regressions.txt, replace /// 
	lab b(1) se(1) sca(rmse) ///
    mti("Baseline" "Controls" "Interactions")

/* Basic usage of -estout- commands:
  
 - The -estout- commands work by storing model estimates with -eststo- and then
   putting them into tables with -esttab-. Use these commands at the end of your
   models: start with -reg- and -leanout-, then use -eststo- and -esttab-.
   
 - The -estout- command is especially practical when you run many models, as
   shown here when we compare the model between country cases and then check
   how the DV model compares to other satisfaction measures (covariates).

 - Check the -estout- online documentation for more examples. */


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
