
/* ------------------------------------------ SRQM Session 8 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Fertility and Education, Part 2

 - DATA:   Quality of Government (2013)

   This do-file is a continuation from last week's do-file, which we start by
   running in the background. This will prepare the data by renaming variables,
   logging GDP per capita and recoding geographical regions to less categories
   and shorter labels.
   
   We then explore simple linear regression using a similar set of variables as
   the one used last week. Some variables are interpreted on non-linear scales.
   Dummies (and categorical variables generally) can also be passed to a simple
   linear regression equation, with another slight adjustment in interpretation.

   Our next two sessions will move from these fundamentals about regression to
   multiple linear regression, and then to logistic models for binary dependent
   variables. Make sure that you understand the logic of ordinary least squares
   (OLS) in order to include simple linear regression models in your next draft.

   Last updated 2013-05-28.

----------------------------------------------------------------------------- */


* Replicate last week and clear graphs. The data left in memory is a modified
* version the Quality of Government dataset, with all necessary recodes and
* renames already performed. It is very common to use different do-files for
* different tasks. In this example, the previous do-file is used for data
* management and the current do-file is used for analysis.
do code/week7.do
gr drop _all

* Log results.
cap log using code/week8.log, replace

* Graph macro. If you remember what we did last week, we used a macro to label
* the data points with country codes instead of using anonymous dots. Since we
* have executed last week's do-file in the background, this macro is available
* in memory, so we will be able to use '$ccode' to produce better scatterplots
* in this do-file too. We will also be able to use the following macro, which
* will remove the legend and dash the regression line of our linear fits.
global ci "legend(off) lp(dash)"


* =====================
* = REGRESSION MODELS =
* =====================


* (1) Fertility Rates and Schooling Years
* ---------------------------------------

* We are looking again at the relationship between fertility and education that
* we already observed in our previous do-file. At that stage, we assume that you
* have a substantive model to explain the relationship that you are studying, or
* the results of the model will land nowhere and serve no analytical purpose.

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
* Equation: predicted Y (DV) = alpha + beta X (IV) + epsilon (error term).
reg births schooling


* Plotting regression results
* ---------------------------

* Simple residuals-versus-fitted plot.
rvfplot, yline(0) ///
    name(rvfplot, replace)

* Get fitted values.
cap drop yhat
predict yhat

* Get residuals.
cap drop r
predict r, resid

* Plot residuals against predicted values of IV.
sc r yhat, yline(0) $ccode ///
    name(rvfplot2, replace)

* Plot DV with observed and predicted values of IV.
sc births schooling || conn yhat schooling, ///
    name(dv_yhat, replace)


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


* Fitting a transformed IV
* ------------------------

* The -qfit- command shows that a more advanced model might better explain the
* DV-IV relationship, as it looks less linear than quadratic: Y = a + bX could
* be replaced with Y = a + bX^2 to observe a more correct fit.
tw (sc births schooling, $ccode) (qfit births schooling, $ci), ///
    name(fert_edu_qfit, replace)

* In this case, using the square root of the independent variable might provide
* better estimates of its actual effect on the dependent variable. We could have
* diagnosed that earlier by looking at the normality of the schooling variable,
* for which a square root transformation is recommended by the ladder commands.

* Variable transformation.
gen sqrt_schooling = sqrt(schooling)
la var sqrt_schooling "Average schooling years (sqrt)"

* Visual inspection.
tw (sc births sqrt_schooling, $ccode) (lfit births sqrt_schooling, $ci), ///
    name(fert_edu_qfit, replace)

* Regression model of the form Y = alpha + beta sqrt(X).
reg births sqrt_schooling

* Reading the regression coefficient for schooling is less intuitive when it is
* computed on the square root of the variable: it requires a short equation to
* produce real-world examples of what the model means. However, more variance
* in the data is explained when the model is written in this more complex form.

* Visualization with solved square root units.
tw (sc births sqrt_schooling, $ccode) (lfit births sqrt_schooling, $ci), ///
    xla(1 "1" 1.5 "2.25" 2 "4" 2.5 "6.25" 3 "9" 3.5 "12.25") ///
    xti("Average schooling years") note("Horizontal axis in squared units.") ///
    name(fert_edu_sqrt, replace)


* (2) Fertility Rates and (Log) Gross Domestic Product
* ----------------------------------------------------

* As always, start with a visual inspection of the relationship.
tw (sc births log_gdpc, $ccode) (lfit births log_gdpc, $ci), ///
    name(fert_gdpc, replace)

* The interpretation of the coefficient for GDP per capita is going to be less
* intuitive due to its logarithmic units, but the transformation was necessary
* to identify the linear relationship between the two variables.

* Regression model of the form Y = alpha + beta ln(X).
reg births log_gdpc


* Fitting 'lin-log' equations
* ---------------------------

* The relationship is a 'lin-log' equation, such that a 1% increase in X (IV) is
* associated with a 0.01 * beta unit increase in Y (DV). In this model, it means
* that a 15% increase in GDP per cap. is associated with -.74 * log(1.15) = -.16
* births per woman. For GDP per capita to reduce fertility by 1 birth per woman,
* this model would require exp(100/74) = 3.8, a 280% increase in GDP per capita.
* This is easy to observe from the reverse equation: -.74 * log(3.8) = -1.

* Why is that number so high? Recall how linear regression works: by computing
* the average marginal change that occurs in the DV (the coefficient) for each
* unit of the IV. This is the average marginal effect, computed over the whole
* sample. If GDP per capita expresses decreasing returns on fertility, then the
* average effect is bound to be higher than what is actually required at lower 
* levels of GDP per capita. What an econometrician would do in that case is to
* compute semi-elasticities (because the model is semi-logarithmic), but if you
* only need to quantify the average relationship, converting by hand is enough.


* (3) Corruption and Human Development
* ------------------------------------

* Visualizing a nonlinear, quadratic fit with corruption as the DV.
tw (sc corruption hdi, $ccode) (qfit corruption hdi, $ci), ///
    ysc(rev) yla(0 "High" 10 "Low") yti("Level of corruption") ///
    name(cpi_hdi, replace)

* Before interpreting the model, deal with the reverse-coding issue.
gen corrupt = 10 - corruption
la var corrupt "Corruption Perception Index"

* Regression model in first approximation (linear form).
reg corrupt hdi


* Fitting a quadratic term
* ------------------------

* A more thorough exploration of residuals will be covered in later sessions
* on regression diagnostics, but here is a snapshot of what we can do and
* understand by studying residuals in a bit more depth.
cap drop yhat
predict yhat

* Plot of linear fitted values.
sc corrupt yhat hdi, yla(0 "Lowly corrupt" 10 "Highly corrupt") ///
    connect(i l) sort(yhat) ///
    name(r_linear, replace)

* The curvilinearity approaches the function f: y = x^2 and can be taken care
* of by squaring HDI and fitting the model again with the quadratic term. The
* final mode is therefore a the equation Y = alpha + beta_1 X + beta_2 X^2.
gen hdi2 = hdi^2

* Regression model in second approximation (added quadratic term).
reg corrupt hdi hdi2

* Residuals of the quadratic model.
cap drop yhat2
predict yhat2

* Comparison of both fits.
sc corrupt yhat2 hdi, yla(0 "Highly corrupt" 10 "Lowly corrupt") ///
    c(i l) sort(yhat) || sc yhat hdi, c(l) legend(order(2 3) ///
    lab(2 "Quadratic fit") lab(3 "Linear fit")) ///
    name(r_curvilinear, replace)


* (4) Fertility and Democracy
* ---------------------------

* Create dummy.
gen democracy:democracy = (chga_hinst < 3) if !mi(chga_hinst)
la def democracy 0 "Dictatorship" 1 "Democracy", replace

* Visualization of the difference in mean of the DV.
gr bar births, over(democracy) asyvars over(region, lab(alt)) ///
    name(fert_democ, replace)


* Fitting a dummy predictor
* -------------------------

* Visualization of the "linear" fit using the dummy.
sc births democracy || lfit births democracy, $ci ///
    xsc(r(-.5 1.5)) xla(0 "Dictatorship" 1 "Democracy") xti("") ///
    name(fert_democ, replace)

* You actually know this result in a different form:
ttest births, by(democracy)

* This is actually identical to the following model:
reg births i.democracy

* In this model, democracy is understood as a categorical variable because we
* added the "i." prefix to it. The coefficient reveals that the fertility rates
* of democracies is, on average, significantly lower than in non-democracies.
* There is no regression coefficient for dictatorships: since democracy is a
* dummy, it takes only two values, 0 or 1. The coefficient is therefore null
* when democracy equals 0. Let's look at null models (Y = alpha) for a proof.

* Y = alpha + beta (democracy = 0) = alpha.
reg births if !democracy

* Y = alpha + beta (democracy = 1) = alpha + beta.
reg births if democracy


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
