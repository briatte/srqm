* What: SRQM Session 11
* Who:  F. Briatte and I. Petev
* When: 2011-12-01


* =========
* = SETUP =
* =========


* Required commands.
foreach p in fre estout {
	cap which `p'
	if _rc==111 cap noi ssc install `p' // install from online if missing
}

* Export log.
cap log using "Replication/week11.log", replace


* ===========
* = DATASET =
* ===========


* Data: Quality of Government (2011).
use "Datasets/qog2011.dta", clear


* ================
* = DESCRIPTIONS =
* ================


* DV: Fertility rate (births per woman).
ren wdi_fr births

* IV: Educational attainment (years of schooling).
ren bl_asyt25 schooling

* Transformation to square root units.
gen sqrt_schooling = sqrt(schooling)
la var sqrt_schooling "Average Schooling Years (Total) (sqrt units)"

* IV: Gross Domestic Product per capita (contant USD).
gen gdpc = unna_gdp/unna_pop
la var gdpc "Real GDP/capita (constant USD)"

* Transformation to log units.
gen log_gdpc = ln(gdpc)
la var log_gdpc "Real GDP/capita (log units)"

* IV: HIV prevalence rate.
ren wdi_hiv hiv
su hiv, d

* Coding a dummy for the last quartile with highest prevalence rates.
gen aids=(hiv > 1.5) if !mi(hiv)
la var aids "High prevalence of HIV (dummy)"
fre aids

* Adding a categorical variable on geographical location.
tab ht_region, gen(region_)

* Method 1: automatially generated dummies.
d region_*

* Method 2: recoding to set Asia as the reference category.
recode ht_region ///
	(1=2 "Eastern Europe & post-Soviet Union") ///
	(2=3 "Latin America") ///
	(3/4=4 "Africa") ///
	(5=5 "Western Europe & North America") ///
	(6/10=1 "Asia & Pacific"), gen(region)
la var region "Geographical region"


* ===============
* = CORRELATION =
* ===============


pwcorr births sqrt_schooling log_gdpc aids, star(.05)
gr mat births sqrt_schooling log_gdpc, half

* Export correlation matrix.
eststo clear
qui estpost correlate births sqrt_schooling log_gdpc aids, matrix listwise
esttab using week11_correlations.txt, unstack not compress label replace

* Drop missing data.
drop if mi(births, sqrt_schooling, log_gdpc, aids)


* ==============================
* = MULTIPLE LINEAR REGRESSION =
* ==============================


sc births sqrt_schooling || lfit births sqrt_schooling
reg births sqrt_schooling

sc births log_gdpc || lfit births log_gdpc
reg births log_gdpc

sc sqrt_schooling log_gdpc || lfit sqrt_schooling log_gdpc
reg sqrt_schooling log_gdpc

* The computational logic of multiple regression is more complex than the
* operations above, but the practical approach with Stata is very similar.
* The example below expands on the previous ones, and the full logic of
* multiple linear regression will be covered during our next sessions with
* individual-level data, as to provide a different approach.


* Unstandardised (metric) coefficients
* ------------------------------------

* With schooling in metric units and GDP per capita in logged units.
reg births schooling log_gdpc

* With schooling as its square root and GDP per capita in metric (USD) units.
* (Not such a good choice of units.)
reg births sqrt_schooling gdpc


* Standardised ('beta') coefficients
* ----------------------------------

* With standardised, or 'beta', coefficients.
reg births sqrt_schooling log_gdpc, beta

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
reg births schooling log_gdpc, beta


* Dummies (categorical variables)
* -------------------------------

* Visualizing two categories (Asia and Africa) within the sample.
tw (sc births schooling if region==1, ms(O) mc(blue)) ///
	(sc births schooling if region==4, ms(O) mc(red)) ///
	(sc births schooling if !inlist(region,1,4), mc(gs10)) ///
	(lfit births schooling, lc(gs10)), ///
	legend(order(1 "Asian countries" 3 "Rest of sample" ///
	2 "African countries" 4 "Fitted values") row(2)) yti("Fertility rate") ///
	name(reg_geo, replace)

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

* Previous regression model.
reg births schooling i.region
* Storing fitted (predicted) values.
cap drop yhat
predict yhat

* Regression lines for the predicted values of Asia and Africa.
tw (sc births schooling if region==1, ms(O) mc(blue)) ///
	(sc births schooling if region==4, mc(red)) ///
	(sc births schooling if !inlist(region,1,4), mc(gs10)) ///
	(rcap yhat births schooling if region==1, c(l) lc(blue) lp(dash) msize(tiny)) ///
	(rcap yhat births schooling if region==4, c(l) lc(red) lp(dash) msize(tiny)) ///
	(sc yhat schooling if region==1, c(l) ms(i) mc(blue) lc(blue)) ///
	(sc yhat schooling if region==4, c(l) ms(i) mc(red) lc(red)), ///
	legend(order(1 "Asian countries" 6 "Fitted values (Asia)" 4 "Residuals (Asia)" ///
	2 "African countries" 7 "Fitted values (Africa)" 5 "Residuals (Africa)") row(2))
	
* Regression line for the HIV/AIDS dummy.
tw (sc yhat aids) (lfit yhat aids), xlab(0 "Low" 1 "High")

* Comparison of t-test and regression results for a single dummy.
ttest yhat, by(aids)
reg yhat i.aids


* ===============
* = DIAGNOSTICS =
* ===============


* Regression model.
reg births schooling log_gdpc aids i.region

* Storing fitted (predicted) values.
cap drop yhat
predict yhat


* Basic checks on residuals
* -------------------------

* Store the unstandardized (metric) residuals.
cap drop r
predict r, resid

* Assess the normality of residuals.
kdensity r, normal legend(off) title("") name(r_kdensity, replace)
pnorm r, name(r_pnorm, replace)
qnorm r, name(r_qnorm, replace)

* Store the standardized residuals.
cap drop rst
predict rst, rsta

* Identify outliers beyond 2 standard deviations.
sc rst yhat, yline(-2 2) || sc rst yhat if abs(rst)>2, mlab(ccodewb) ///
	ylab(-3(1)3) legend(lab(2 "Outliers")) name(diag_rst, replace)


* (b) Variance inflation and interaction terms
* --------------------------------------------

* The Variance Inflation Factor (VIF) diagnoses an issue with 'kitchen sink'
* models that use high numbers of correlated variables together in the model,
* which measures several times the same effect and creates multicollinearity.
* This problem renders the regression coefficients useless. Critical cut-off
* points for variance inflation are VIF > 10 or tolerance 1/VIF <.1.
vif

* Adding an interaction term is a technique to account for the variance that
* two variables explain in each other. The effect is calculated by multiplying
* the two variables together and throwing that product in the regression model.
* The regression coefficient for this product is the interaction effect. If that
* effect is significantly large, the model accounts for it by isolating it and
* reading other coefficients.
gen schoolingXlog_gdpc = schooling*log_gdpc
la var schoolingXlog_gdpc "GDP * Schooling"

* Regression model.
reg births schooling log_gdpc aids i.region, r

* Regression model with an interaction term.
reg births schooling log_gdpc schoolingXlog_gdpc aids i.region, r

* Standardised coefficients reveal how the interaction influences the model.
reg births schooling log_gdpc schoolingXlog_gdpc aids i.region, r beta

* Similarly, nested regression shows how the interaction advances the model.
nestreg: reg births ///
	(schooling log_gdpc aids) ///
	(schooling log_gdpc schoolingXlog_gdpc aids), r beta

* Finally, this is how an even more detailed model can be written. The first
* term tests a factorial interaction between two continuous variables, noted
* with the "c." prefix. Each variable is added to the model, along with their
* interaction term. The second term tests all combinations of two categorical
* variables, which will show the impact of high HIV prevalence per continent.
reg births c.schooling##c.log_gdpc aids#region, r beta


* (c) Heteroskedasticity
* ----------------------

* Homoscedasticity of the residuals versus fitted values (DV).
rvfplot, yline(0) ms(i) mlab(ccodewb) name(diag_rvf, replace)

* Identical, with outliers.
sc r yhat || sc r yhat if abs(rst) > 2, yline(0) mlab(ccodewb) ///
	legend(lab(2 "Outliers"))

* Homoskedasticity of the residuals versus one predictor (IV).
rvpplot schooling, yline(0) ms(i) mlab(ccodewb) name(diag_rvp, replace)

* Identical, with outliers.
sc r schooling || sc r schooling if abs(rst) > 2, yline(0) mlab(ccodewb) ///
	legend(lab(2 "Outliers"))

* Use robust standard errors to adjust for heterogeneous variance.
reg births c.schooling##c.log_gdpc aids##region, r beta


* =================
* = MODEL RESULTS =
* =================


* The next commands require that you install the -estout- package first.

* This section shows how to export regression results, in order to avoid having
* to copy out the results by hand, copy-paste or any other risky (non)technique
* that you might come up with at that stage. Exporting regression results also
* makes it easier to build several regression models based on varying sets of
* covariates (independent variables), in order to compare their coefficients.

* Wipe any previous regression estimates.
eststo clear

* Model 1: 'Baseline model'.
eststo M1: qui reg births schooling log_gdpc, r beta

* Model 2: Adding the HIV/AIDS dummy with regional interactions.
eststo M2: qui reg births schooling log_gdpc aids#i.region, r beta

* Model 3: Adding the interaction between education and wealth.
eststo M3: qui reg births c.schooling##c.log_gdpc aids#i.region, r beta

* Export all models for comparison and reporting.
esttab M1 M2 M3 using "week11_regressions.txt", replace constant beta(2) se(2) r2(2) ///
	label mtitles("Baseline" "Controls for HIV/AIDS" "Interaction effects")


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close week11

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
