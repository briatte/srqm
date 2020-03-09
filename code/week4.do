
* Check setup.
run setup/require fre

* Allow Stata to scroll through the results.
set more off

* Log results.
cap log using code/week4.log, replace

/* ------------------------------------------ SRQM Session 4 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Social Determinants of Adult Obesity in the United States

 - DATA:   U.S. National Health Interview Survey (2017)

 - Since last week, you should now know what dataset and variables you plan to
   use for your research project. Please register your project online by writing
   your names, keywords, data source and class ID to the student projects table.

 - This week focuses on inspecting the normality of your dependent variable. The
   DV should be continuous for best results, or at least pseudo-continuous like
   a 10-point scale measurement.
   
 - Avoid selecting variables with four dimensions or less as your DV, unless you
   can learn to interpret logistic regression in just a few weeks at the end of 
   the course. This requires some math and is for the most adventurous only.

 - Assessing the normality of a variable is first and foremost a visual process.
   You will need to visualize your DV a lot at that stage of your work. There is
   no systematic way to assess normality, but your decision should take skewness
   and kurtosis into account.
   
   Last updated 2020-03-09.

----------------------------------------------------------------------------- */

* Load NHIS data for latest survey year.
use data/nhis1017 if year == 2017, clear

* Set individual survey weights.
svyset psu [pw = perweight], strata(strata)


* Dependent variable: Body Mass Index
* -----------------------------------

gen bmi = weight * 703 / height^2 if weight < 996 & height < 96
la var bmi "Body Mass Index"

* Detailed summary statistics.
su bmi, d


* Independent variables
* ---------------------

* Inspect some of the variables.
d sex race earnings

* Low-dimensional, categorical variables.
fre sex
fre race
fre earnings

* The default -tab- command returns similar results, minus value labels.
tab sex

* High-dimensional, continuous variables.
fre bmi, rows(30)


* ================
* = DISTRIBUTION =
* ================


* Obtain summary statistics:
su bmi
tabstat bmi, s(n mean sd min max)

su bmi, d
tabstat bmi, s(p25 median p75 iqr)

* Visualize the distribution:
hist bmi, percent bin(10)
hist bmi, kdensity

* Histogram with normal distribution superimposed.
hist bmi, percent normal ///
	name(hist, replace)

* Kernel density.
kdensity bmi, normal legend(row(1)) title("") note("") ///
	name(kdens, replace)

* Box plots.
gr hbox bmi, over(race) ///
	name(bmi_race, replace)

gr hbox bmi, over(sex) asyvars over(race) ///
	name(bmi_race_sex, replace)

* The next commands use scalars to describe a distribution through its standard 
* deviation and outliers. This is a teaching example, not a course requirement.

* Obtain summary statistics.
su bmi, d

* To show the results of a command, Stata saves them first to a temporary space
* in its memory, r(). The results of the last command are readable from there:
ret li

* Let's save some of these statistics to scalars, in order to access them later.
* Scalars and macros are programming commands that you will not need to learn to
* operate Stata at regular user-level. However, they happen to be useful to code
* some teaching examples and demonstrations, as shown below.

* Save the mean and standard deviation of the summarized variable.
sca de mean = r(mean)
sca de sd   = r(sd)

* Save the 25th and 75th percentiles and compute the interquartile range (IQR),
* which is the range from the first quartile (Q1) to the third quartile (Q3).
sca de q1  = r(p25)
sca de q3  = r(p75)
sca de iqr = q3 - q1

* List all saved scalars, which are used in the next sections in combination to
* the -di- command for quick verifications about the distribution of
* the dependent variable (BMI) in the sample.
sca li


* Standard deviation
* ------------------

* We can verify what we learnt about the standard deviation by counting the
* number of BMI observations that fall between (mean - 1sd) and (mean + 1sd),
* and then by checking if this number comes close to 68% of all observations.
count if bmi > mean - sd & bmi < mean + sd
di r(N), "observations out of", _N, "(" 100 * round(r(N) / _N, .01) ///
	"% of the sample) are within one standard deviation from the mean."

* The corresponding result is indeed close to 68% of all observations, and the
* same verification with the [mean - 2sd, mean + 2sd] range of BMI values is
* also satisfactorily close to including 95% of all observations.
count if bmi > mean - 2 * sd & bmi < mean + 2 * sd
di r(N), "observations out of", _N, "(" 100 * round(r(N) / _N, .01) ///
	"% of the sample) are within 2 standard deviations from the mean."

* The properties shown here hold for continuous variables that approach a
* normal distribution, as discussed below. We could go further and compute
* the [mean - 3sd, mean + 3sd] range, but the most extreme values of a
* distribution are more conveniently captured by the notion of outliers,
* i.e. observations that fall far from the median.


* Outliers
* --------

* Summarize mild (1.5 IQR) or extreme (3 IQR) outliers below Q1 and above Q3:
su bmi if bmi < q1 - 1.5 * iqr | bmi > q3 + 1.5 * iqr
su bmi if bmi < q1 - 3 * iqr   | bmi > q3 + 3 * iqr


* =============
* = NORMALITY =
* =============


* Continuous variables are expected to approach a normal distribution, a result
* more easily obtained at higher sample sizes. Let's check if the distribution
* of BMI values approaches normality, and if not, let's transform the variable
* to bring it closer to normality. We start with visual inspection and complete
* the assessment with two statistical measures.


* Visual assessment
* -----------------

* We draw a histogram with three different elements: the actual bins (bars)
* of the BMI variable, its kernel density, and an overimposed normal curve
* that we draw in a different colour using a few graph options.
hist bmi, bin(15) normal kdensity kdenopts(lp(dash) lc(black) bw(1.5)) ///
	note("Normal distribution (solid red) and kernel density (dashed black).") ///
	name(bmi, replace)

* The histogram shows what we knew from reading the mean and median of the
* BMI values: the distribution is skewed to the left, implying that there are
* more observations below the mean of the distribution than above it.

* As a result, the distribution is asymmetrical, which we can verify using a
* particular graphical technique that emphasizes deviations from symmetry.
* Perfect symmetry corresponds to the straight red line.
symplot bmi, ti("Symmetry plot") ///
	name(bmi_sym, replace)

* Another visualization plots the quantiles of the variable against those of the
* normal distribution. Perfect correspondence between the two distributions is
* observed at the straight red line.
qnorm bmi, ti("Normal quantile plot") ///
	name(bmi_qnorm, replace)

* The departures observed here are situated at the tails of the distribution,
* which means that there is an excess of observations at these values.


* Formal assessment
* -----------------

* Moving to statistical measures of normality, we can measure skewness, which
* measures symmetry and approaches 0 in quasi-normal distributions, along with
* kurtosis, which measures the size of the distribution tails and approaches 3
* in quasi-normal distributions. Use the -summarize- command with the -detail-
* option, respectively abbreviated as -su- and -d-.
su bmi, d

* There are more advanced tests to measure normality, but the tests above are
* sufficient to observe that we cannot assume the BMI variable to be normally
* distributed (i.e. we reject our distributional assumption).


* Variable transformation
* -----------------------

* A technique used to approach normality with a continuous variable consists
* in 'transforming' the variable with a mathematical operator that modifies
* its basic unit of measurement. We learnt that the distribution of BMI for
* its standard unit measurement is not normal, but perhaps the distribution
* of the same values is closer to normality if we take a different measure.

* The -gladder- command visualizes several common transformations all at once.
gladder bmi, ///
	name(gladder, replace)

* The logarithm transformation appears to approximate a normal distribution.
* We transform the variable accordingly.
gen logbmi = ln(bmi)
la var logbmi "Body Mass Index (log units)"

* Looking at skewness and kurtosis for the logged variable.
tabstat bmi logbmi, s(n sk kurtosis min max) c(s)

* The log-BMI histogram shows some improvement towards normality.
hist logbmi, normal ///
    name(logbmi, replace)


* Comparison plot
* ---------------

* Running the same graphs with a few options to combine them allows a quick
* visual comparison of the transformation.

* Part 1/4.
hist bmi, norm xti("") ysc(off) ti("Untransformed (metric)") bin(21) ///
	name(bmi1, replace)

* Part 2/4.
gr hbox bmi, fysize(25) ///
	name(bmi2, replace)

* Part 3/4.
hist logbmi, norm xti("") ysc(off) ti("Transformed (logged)") bin(21) ///
	name(bmi3, replace)

* Part 4/4.
gr hbox logbmi, fysize(25) ///
	name(bmi4, replace)

* Final combined graph.
gr combine bmi1 bmi3 bmi2 bmi4, imargin(small) ysize(3) col(2) ///
	name(bmi_comparison, replace)

* Drop individual pieces.
gr drop bmi1 bmi2 bmi3 bmi4
gr di bmi_comparison


* ==================
* = SAMPLING ERROR =
* ==================


* Now here's a simple issue: if we subsample our data, the average BMI will not
* necessarily reflect the sample mean.
su bmi in 1/10

* The problem applies to our entire sample: how can we confirm that it reflects
* the true population mean? We cannot, but we can enforce a precaution measure,
* following the assumption that the data follow a somewhat normal distribution.


* Confidence intervals with means
* -------------------------------

* The confidence interval reflects the standard error of the mean (SEM), itself
* a reflection of sample size. We will come back to the SEM equation next week.

* Mean BMI for the full sample with a 95% CI.
ci bmi

* Mean BMI for the full sample with a 99% CI (more confidence, less precision).
ci bmi, level(99)

* Mean BMI for full sample with survey design weights (as set earlier).
svy: mean bmi

* Mean BMI for full sample with ajusted sample weights.
mean bmi [pw = sampweight]

* The confidence intervals for the full sample show a high precision, both at
* the 95% (alpha = 0.05) and 99% (alpha = 0.01) levels. This is due to the high
* number of observations available for the BMI variable.

* If we compute the average BMI for subsamples of the population, such as one
* category of the population, the total number of observations will drop and
* the confidence interval will widen, as shown here with smaller subsamples:
ci bmi in 1/10
ci bmi in 1/100
ci bmi in 1/1000
ci bmi in 1/10000

* Confidence bands can become useful to detect spurious relationships. Let's
* take a look, for instance, at the number of years spent in the U.S.
fre yrsinus
replace yrsinus = . if yrsinus == 0

* We know from previous analysis that BMI varies by gender and ethnicity.
* We now look for the effect of the number of years spent in the U.S. within
* each gender and ethnic categories.
gr dot bmi, over(sex) over(yrsinus) over(race) asyvars scale(.7) ///
	ti("Body Mass Index by age, sex, race and number of years in the U.S.") ///
	yti("Mean BMI") ///
	name(bmi_sex_yrs, replace)

* The average BMI of Blacks who spent less than one year in the U.S. shows
* an outstanding difference for males and sexs, but this category holds
* so little observations that the difference should not be considered.
bys sex: ci bmi if race == 2 & yrsinus == 1

* Identically, the seemingly clean pattern among male and sex Asians is
* calculated on a low number of observations and requires verification of
* the confidence intervals. The pattern appears to be rather robust.
bys yrsinus: ci bmi if race == 4


* Confidence intervals with proportions
* -------------------------------------

* A few things about confidence intervals with proportions, for which confidence
* bands follow a different method of calculation. Basically, categorical data is
* just dummies for a bunch of categories, and the distribution of binary data
* can hardly be normal. The binomial distributions applies instead.
ci sex, binomial

* Categorical variables, which can be described through proportions, also
* come with confidence intervals that reflect the range of values that each
* category might take in the true population. The proportions of ethnic groups
* in the U.S., for instance, are somehwere in these intervals:
prop race

* Actually, if you want to be completely correct, you need to weight the data
* with the svy: prefix to use the weight settings specified earlier. This will
* have a tremendous effect on your data in this case, shifting the proportion
* of White respondents from roughly 60% to roughly 70% of all U.S. adults, the
* reason being that other racial-ethnic groups are oversampled in NHIS data.
svy: prop race

* Identically to continuous variables, confidence intervals for categorical
* data will increase when the total number of observations decreases. The
* 95% CI for ethnicity on morbidly obese respondents illustrates that issue.
prop race if bmi > 40


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
