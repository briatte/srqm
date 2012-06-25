* What: SRQM Session 4
* Who:  F. Briatte and I. Petev
* When: 2011-09-14

* Data: U.S. National Health Interview Survey (2009).
use "Datasets/nhis2009.dta", clear

* Log.
cap log using "Replication/week4.log", name(week4) replace

* ====================
* = DATA PREPARATION =
* ====================

* Subset to most recent year.
drop if year != 2009

* Compute the Body Mass Index.
gen bmi = weight*703/(height^2)
la var bmi "Body Mass Index"

* Weight the data with NHIS individual weights.
svyset psu [pw=perweight], strata(strata) vce(linearized) singleunit(missing)

* ================
* = DISTRIBUTION =
* ================

* Obtain summary statistics:
su bmi
tabstat bmi, s(n mean sd min max)

su bmi, d
tabstat bmi, s(p25 median p75 iqr)

* Visualize the distribution:
hist bmi, freq bin(10)
hist bmi, kdensity
hist bmi, percent normal name(bmi, replace)
kdensity bmi, normal legend(row(1)) title("") note("")

gr hbox bmi, over(raceb)
gr hbox bmi, over(sex) asyvars over(raceb) name(bmi_race, replace)

* The next commands use 'global macros' to illustrate how a distribution
* can be described through the standard deviation and through outliers. This
* course does not require that you use them in your own research projects.

* Obtain summary statistics.
su bmi, d
ret li

* Save statistics to macros:
global total=r(N)
global mean=r(mean)
global sd=r(sd)
di $total, $mean, $sd

global q1=r(p25)
global q3=r(p75)
global iqr= $q3-$q1
di $q1, $q3, $iqr
 
* (1) Standard deviation

* We can verify what we know about the standard deviation by counting the
* number of BMI observations that fall between (mean)-1sd and (mean)+1sd,
* and then by checking if this number comes close to 68% of all observations.
count if bmi > $mean - 1*$sd & bmi < $mean + 1*$sd
di %9.3g r(N)/$total

* The corresponding result is indeed close to 68% of all observations, and the
* same verification with the [mean-2sd,mean+2sd] range of BMI values is also 
* satisfactorily close to including 95% of all observations.
count if bmi > $mean - 2*$sd & bmi < $mean + 2*$sd
di %9.3g r(N)/$total

* We could go further and calculate the [mean-3sd,mean+3sd] range, but the 
* most extreme values of a distribution are more conveniently captured by
* the notion of outliers, i.e. observations that fall far from the median. 

* (2) Outliers

* The interquartile range (IQR) is the range between Q3 (p75) and Q1 (p25).
* We detect mild (1.5*IQR) or extreme (3*IQR) outliers below Q1 and above Q3: 
li bmi sex raceb if bmi < $q1-1.5*$iqr | bmi > $q3+1.5*$iqr, N
li bmi sex raceb if bmi < $q1-3*$iqr | bmi > $q3+3*$iqr, N

* ===================
* = NORMALITY TESTS =
* ===================

* The BMI variable is our dependent variable. Every statistical test or 
* quantitative method that we are going to use in this course is based on
* the assumption that this variable is close to being normally distributed.

* (1) Visual tests

* Let's check if the distribution of BMI values approaches normality, and 
* if not, let's transform the variable to bring it closer to normality.
* We start with visual interpretations and then to statistical operations.

* We draw a histogram with three different elements: the actual bins (bars)
* of the BMI variable, its kernel density, and an overimposed normal curve
* that we draw in a different colour using a few graph options.
hist bmi, kdensity normal normopts(lc(red)) name(bmi, replace)

* The histogram shows what we knew from reading the mean and median of the
* BMI values: the distribution is skewed to the left, implying that there are
* more observations below the mean of the distribution than above it.

* As a result, the distribution is asymmetrical, which we can verify using a
* particular graphical technique that emphasizes deviations from symmetry.
* Perfect symmetry corresponds to the theoretical straight line in the plot.
symplot bmi, name(bmi_sym, replace)

* Another technique, the quintile plot, emphasizes sudden variation in the 
* values taken by the variable. Again, perfect variation corresponds to the 
* theoretical straight line in the plot.
quantile bmi, name(bmi_qnt, replace)

* For similar visualizations, test the "pnorm" and "qnorm" commands.
pnorm bmi, name(bmi_pnorm, replace)
qnorm bmi, name(bmi_qnorm, replace)

* (2) Statistical tests

* Moving to statistical measures of normality, we can measure skewness, which
* measures symmetry and approaches 0 in quasi-normal distributions, along with 
* kurtosis, which measures the size of the distribution tails and approaches 3
* in quasi-normal distributions. Use the 'summarize' command with the 'detail'
* option, respectively abbreviated as 'su' and 'd'.
su bmi, d

* There are more advanced tests to measure normality, but the tests above are
* sufficient to observe that we cannot assume the BMI variable to be normally
* distributed (i.e. we reject our distributional assumption).

* ============================
* = VARIABLE TRANSFORMATIONS =
* ============================

* A technique used to approach normality with a continuous variable consists 
* in 'transforming' the variable with a mathematical operator that modifies 
* its basic unit of measurement. We learnt that the distribution of BMI for
* its standard unit measurement is not normal, but perhaps the distribution
* of the same values is closer to normality if we take a different measure.

* The 'gladder' command visualizes several common transformations all at once. 
gladder bmi

* The logarithm transformation appears to approximate a normal distribution.
* We transform the variable accordingly.
gen logbmi=ln(bmi)
la var logbmi "Body Mass Index (log units)"

* Looking at skewness and kurtosis for the logged variable.
tabstat bmi logbmi, s(n sk kurtosis min max) c(s)

* Running the same graphs as previously on the original BMI variable,
* we can observe some improvement towards normality with 'log-BMI'.
hist logbmi, normal name(logbmi, replace)
graph hbox logbmi

* Running the same graphs with a few options to combine them allows a quick
* visual comparison of the transformation.
hist bmi, normal xscale(off) yscale(off) ///
	title("Untransformed") name(bmi1, replace)
graph hbox bmi, fysize(25) name(bmi2, replace)
hist logbmi, normal xscale(off) yscale(off) ///
	title("Transformed") name(bmi3, replace)
graph hbox logbmi, fysize(25) name(bmi4, replace)
graph combine bmi1 bmi3 bmi2 bmi4, imargin(small) ysize(3) col(2)

* ==================
* = SAMPLING ERROR =
* ==================

* Sample size 
ci bmi

* Ask Stata to drop all but 50 randomly selected observations,
* and look again at the standard error and confidence interval.
sample 50, count
ci bmi

* ========
* = EXIT =
* ========

* Wipe the modified data.
* clear

* Close log (if opened).
cap log close week4

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
