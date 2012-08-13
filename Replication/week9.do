* What: SRQM Session 9
* Who:  F. Briatte and I. Petev
* When: 2011-10-24

* ================
* = INTRODUCTION =
* ================

* Start again where we stopped with the QOG dataset. This command will make
* sure that all variables transformations, renaming and recoding from our past 
* session are properly loaded. It will also keep the macros from last week and
* load some exploratory scatterplot graphs in memory, before we discard them
* with the next line to clear the screen from unnecessary clutter.
do "Replication/week8.do"

* Log.
cap log using "Replication/week9.log", name(week9) replace

* ============================
* = SIMPLE LINEAR REGRESSION =
* ============================

* (1) Fertility Rates and Schooling Years

* Looking again at Example 1, visualizing the negative linear fit.
tw (sc births schooling, $ccode) (lfit births schooling), ///
	name(nat_edu, replace)
	
* Looking at the regression coefficient and at the intercept provides a model
* of the relationship: the model basically reads as: starting with an initial
* level of (_cons) births, every increase of one unit of births is associated
* with a variation of (coef) units of schooling years. We cannot say that one
* variable is "causing" the other without confusing statistical causation with 
* actual causation, which is a common but serious mistake, unless we provide a 
* substantive theory to link both variables. We will come back to that later.
reg schooling births

* The relationship can be read in any direction: inverting the variables in 
* the model will affect the coeffient and intercept, but not the R-squared or
* the p-value of the regression itself. Only a substantive understanding of
* the model can determine the y (DV) and x (IV) assignment of the variables. 
reg births schooling

* Finally, we worked on a linear model, but a more advanced model might better
* explain the relationship as it actually looks less linear than quadratic.
tw (sc births schooling, $ccode) (qfit births schooling), ///
	name(nat_edu_q, replace)

* In this case, using the square root of the independent variable might provide
* better estimates of its actual effect on the dependent variable. We could have
* diagnosed that earlier by looking at the normality of the schooling variable,
* for which a square root transformation is recommended by the ladder commands.

* Variable transformation.
gen sqrt_schooling = sqrt(schooling)
la var sqrt_schooling "Average Schooling Years (Total) (square root)"

* Visual inspection.
tw (sc births sqrt_schooling, $ccode) (lfit births sqrt_schooling), ///
	name(nat_edu_q, replace)

* Regression model.
reg births sqrt_schooling

* Reading the regression coefficient for schooling is less intuitive when it is
* computed on the square root of the variable: it requires a short equation to
* produce real-world examples of what the model means. However, more variance 
* in the data is explained when the model is written in this more complex form. 

* (2) Schooling Years and (Log) Gross Domestic Product

* Looking again at Example 2, visualizing the positive linear fit. We here
* follow the convention where the first variable is considered to be the DV.
tw (sc schooling log_gdp, $ccode) (lfit schooling log_gdp), ///
	name(edu_gdp, replace)

* The interpretation of the coefficient and intercept are going to be rather
* difficult here due to the logarithmic unit of GDP, but the transformation
* was necessary to identify the linear relationship between the two variables.
reg schooling log_gdp

* (3) Corruption and Human Development

* Looking again at Example 3, visualizing the nonlinear, quadratic fit.
tw (sc corruption hdi, $ccode) (qfit corruption hdi), ///
	ysc(rev) ylabel(0 "High" 10 "Low", angle(hor)) name(cpi_hdi, replace)

* Before interpreting the model, remember that:
* - the relationship is, in fact, quadratic, and only approximately linear
* - the Corruption Perceptions Index is reverse-coded: 10 is highly corrupt
reg corruption hdi

* The following commands rely on a visual inspection of the model residuals.
* A more thorough exploration of residuals will be covered in later sessions
* on regression diagnostics, but here is a snapshot of what we can do and 
* understand by studying them in a bit more depth.
predict yhat
sc yhat corruption hdi, ///
	ysc(rev) connect(l) sort(yhat) lw(vthick) name(r_linear, replace)

* The curvilinearity, which approaches a y = x^2 function, can be taken care 
* of by squaring HDI and fitting the model again to the trasnformed data.
gen hdi2=hdi^2
reg corruption hdi hdi2
predict yhat2
sc yhat2 corruption hdi, ///
	ysc(rev) connect(l) sort(yhat) lw(vthick) name(r_curvilinear, replace)

* (4) Female Government Ministers and Corruption

* Looking again at Example 4, visualizing the absence of evident fit.
* A confidence interval was added to the regression line in order to show how
* poorly it accounts for the relationship between the variables: only a few
* data points are actually included in the interval, showing a mediocre fit.
tw (lfitci corruption femgovs) (sc corruption femgovs, $ccode), ///
	legend(row(1)) name(cpi_femgov, replace)

* Despite a less-than-optimal fit, the model yet returns a "good", by which
* we mean a satisfactory p-value lower than our alpha level of statistical
* significance. Hence, caution!
reg corruption femgovs

* The same information can be shown with a residuals-versus-fitted plot,
* which displays the regression line as a horizontal line at zero. The
* distance from that line indicates the fit of each data point. The other
* option is naturally the residuals-versus-predictor plot, which shows the
* residuals against values of the predictor (or independent variable).
rvfplot, $ccode yline(0) name(cpi_femgov_rvf, replace)
rvpplot femgovs, $ccode yline(0) name(cpi_femgov_rvp, replace)

* ========
* = EXIT =
* ========

* Clean all graphs from memory.
* gr drop _all

* Wipe the modified data.
* clear

* Close log (if opened).
cap log close week9

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
