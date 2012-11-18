* What: SRQM Session 9
* Who:  F. Briatte and I. Petev
* When: 2012-11-05


* =========
* = SETUP =
* =========


* Replicate last week and clear graphs (also loads and prepares the data)
do "Replication/week8.do"
gr drop _all

* Required commands.
foreach p in mkcorr {
	cap which `p'
	if _rc==111 cap noi ssc install `p' // install from online if missing
}

* Log results.
cap log using "Replication/week9.log", replace

* Graph macro.
global ci "legend(off) lp(dash)"

gen region:region = ht_region

* Recode and relabel values.
recode region (6/10=6)
la de region 1 "E. Europe and PSU" 2 "Lat. America" ///
	3 "N. Africa and M. East" 4 "Sub-Sah. Africa" ///
	5 "W. Europe and N. America" 6 "Asia, Pacific and Carribean" ///
	, replace


* Finalized sample
* ----------------

* Have a quick look.
codebook births schooling gdpc hdi corruption femgov region, c

* Check missing values.
misstable pat births schooling gdpc hdi corruption femgov region

* Subset to complete observations (not run for demonstration purposes).
drop if mi(births, schooling, gdpc, hdi, corruption, femgov)


* ==========
* = MODELS =
* ==========


* (1) Fertility Rates and Schooling Years
* ---------------------------------------

* We are looking again at Example 1 for the previous do-file. At that stage, we
* assume that you have a substantive model to explain the relationship that you
* are studying, otherwise the results of the model will land nowhere and serve
* no analytical purpose. Theoretical support is unavoidable hereinafter.

* Visual fit.
sc births schooling, $ccode ///
	legend(off) yti("Fertility rate (births per woman)") ///
	name(fert_edu1, replace)

* Linear fit.
tw (sc births schooling, $ccode) (lfit births schooling, $ci), ///
	yti("Fertility rate (births per woman)") ///
	name(fert_edu2, replace)

* Add 95% CI.
tw (sc births schooling, $ccode) (lfitci births schooling, $ci), ///
	yti("Fertility rate (births per woman)") ///
	name(fert_edu3, replace)

* Estimate the predicted effect of the education level on the fertility rate.
* Function: number of births = _cons (alpha) + Coef (beta) * schooling years.
reg births schooling

* Simple residuals-versus-fitted plot.
rvfplot, $ccode yline(0) ///
	name(rvfplot, replace)


* Plotting regression results
* ---------------------------

* Get fitted values.
cap drop yhat
predict yhat

* Plot DV with observed and predicted values of IV.
sc births schooling || conn yhat schooling, ///
	name(dv_yhat, replace)

* Get residuals.
cap drop r
predict r, resid

* Plot residuals against predicted values of IV.
sc r yhat, ///
	name(rvfplot2, replace)


* Small multiples
* ---------------

* Draw scatterplots and linear fits for each region. Visualizing small multiples
* requires using an independent variable with a limited number of categories and
* might reveal additional strengths or weaknesses of your model.
sc births schooling || lfit births schooling, by(region) ///
	name(lfit_region, replace)

* Run the linear regression models for each region. Observe how the standard
* errors and p-values of the regression coefficients widen when the regional
* sample size falls at lower numbers of observations.
bys region: reg births schooling

* Detailed residuals-versus-fitted plots.
sc r yhat, yline(0) by(region, total) $ccode ///
	name(rvfplot2, replace)


* Transforming the DV
* -------------------

* We will start working on linear models, but a more advanced model might better
* explain the relationship as it actually looks less linear than quadratic.
tw (sc births schooling, $ccode) (qfit births schooling), ///
	name(fert_edu, replace)

* In this case, using the square root of the independent variable might provide
* better estimates of its actual effect on the dependent variable. We could have
* diagnosed that earlier by looking at the normality of the schooling variable,
* for which a square root transformation is recommended by the ladder commands.

* Variable transformation.
gen sqrt_schooling = sqrt(schooling)
la var sqrt_schooling "Average schooling years (sqrt)"

* Visual inspection.
tw (sc births sqrt_schooling, $ccode) (lfit births sqrt_schooling), ///
	name(fert_edu, replace)

* Regression model.
reg births sqrt_schooling

* Reading the regression coefficient for schooling is less intuitive when it is
* computed on the square root of the variable: it requires a short equation to
* produce real-world examples of what the model means. However, more variance
* in the data is explained when the model is written in this more complex form.

* Visualization with solved square root units.
tw (sc births sqrt_schooling, $ccode) (lfit births sqrt_schooling), ///
	xla(1 "1" 1.5 "2.25" 2 "4" 2.5 "6.25" 3 "9" 3.5 "12.25") ///
	xti("Average schooling years") note("Horizontal axis in square units.") ///
	name(fert_edu, replace)


* (2) Schooling Years and (Log) Gross Domestic Product
* ----------------------------------------------------

* As always, start with a visual inspection of the relationship.
tw (sc schooling log_gdpc, $ccode) (lfit schooling log_gdpc), ///
	name(edu_log_gdpc, replace)

* The interpretation of the coefficient and intercept are going to be rather
* difficult here due to the logarithmic unit of GDP, but the transformation
* was necessary to identify the linear relationship between the two variables.
reg schooling log_gdpc


* (3) Corruption and Human Development
* ------------------------------------

* Looking again at Example 3, visualizing the nonlinear, quadratic fit.
tw (sc corruption hdi, $ccode) (qfit corruption hdi), ///
	ysc(rev) yla(0 "High" 10 "Low", angle(hor)) ///
	name(cpi_hdi, replace)

* Before interpreting the model, remember that:
* - the relationship is, in fact, quadratic, and only approximately linear
* - the Corruption Perceptions Index is reverse-coded: 10 is highly corrupt
reg corruption hdi

* The following commands rely on a visual inspection of the model residuals.
* A more thorough exploration of residuals will be covered in later sessions
* on regression diagnostics, but here is a snapshot of what we can do and
* understand by studying them in a bit more depth.
cap drop yhat
predict yhat
sc corruption yhat hdi, yla(0 "Highly corrupt" 10 "Lowly corrupt") ///
	ysc(rev) connect(i l) sort(yhat) ///
	name(r_linear, replace)

* The curvilinearity, which approaches a y = x^2 function, can be taken care
* of by squaring HDI and fitting the model again to the transformed data.
gen hdi2=hdi^2
reg corruption hdi hdi2
cap drop yhat2
predict yhat2
sc corruption yhat2 hdi, yla(0 "Highly corrupt" 10 "Lowly corrupt") ///
	ysc(rev) connect(i l) sort(yhat) || sc yhat hdi, legend(order(2 3) ///
	lab(2 "Quadratic fit") lab(3 "Linear fit")) name(r_curvilinear, replace)


* (4) Female Government Ministers and Corruption
* ----------------------------------------------

* Looking again at Example 4, visualizing the absence of evident fit.
* A confidence interval was added to the regression line in order to show how
* poorly it accounts for the relationship between the variables: only a few
* data points are actually included in the interval, showing a mediocre fit.
tw (lfitci corruption femgov) (sc corruption femgov, $ccode), ///
	legend(off) yla(1 "Highly corrupt" 10 "Lowly corrupt") ///
	name(cpi_femgov, replace)

* Despite a less-than-optimal fit, the model yet returns a "good", by which
* we mean a satisfactory p-value lower than our alpha level of statistical
* significance. Hence, caution!
reg corruption femgov

* The same information can be shown with a residuals-versus-fitted plot,
* which displays the regression line as a horizontal line at zero. The
* distance from that line indicates the fit of each data point. The other
* option is naturally the residuals-versus-predictor plot, which shows the
* residuals against values of the predictor (or independent variable).
rvfplot, $ccode yline(0) ///
	name(cpi_femgov_rvf, replace)

rvpplot femgov, $ccode yline(0) ///
	name(cpi_femgov_rvp, replace)


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
