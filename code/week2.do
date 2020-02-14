
* Check setup.
run setup/require fre

* Allow Stata to scroll through the results.
set more off

* Log results.
cap log using code/week2.log, replace

/* ------------------------------------------ SRQM Session 2 -------------------

   F. Briatte and I. Petev

 - TOPIC:  Social Determinants of Adult Obesity in the United States

 - DATA:   U.S. National Health Interview Survey (2017)

 - Hi! Welcome to your second SRQM do-file.

 - All the do-files for this course assume that you have set up Stata first by 
   adjusting some parameters, most importantly setting the working directory to
   your SRQM folder. Please refer to the do-file from Session 1 for guidance.

 - Welcome again to Stata. Read the comment lines as you go along, and run the
   code by executing command lines sequentially. Select lines with Cmd-L (Mac)
   or Ctrl-L (Win), and execute them with Cmd-Shift-D (Mac) or Ctrl-D (Win).

 - We will explore the National Health Interview Survey with a few basic Stata
   commands. This is to show you how to explore a dataset and its variables. You
   need to make a choice of dataset for your project by the end of the week.
 
 - If you want to study one country or compare two of them, turn to survey data
   from the European Social Survey (ESS), U.S. General Social Survey (GSS) or
   World Values Survey (WVS).

 - If you want to study country-level data, use the Quality of Government (QOG)
   dataset. Your sample should be all world countries: do not further restrict
   the sample further by subsetting to less observations.

   Last updated 2020-02-14.

----------------------------------------------------------------------------- */

* Load NHIS dataset.
use data/nhis1017, clear

* Once the dataset is loaded, the Variables window will fill up, and you will
* be able to look at the actual dataset from the Data Editor. Read from the
* course material to make sure that you know how to read through a dataset:
* its data structure shows observations in rows and variables in columns.

* List all variables in the dataset.
describe


* Finding variables
* -----------------

* Locate some variables of interest by looking for keywords in the variables.
* You can explore your dataset by looking for particular keywords in the
* variable names and labels. This is particularly useful when your dataset
* comes with variable names that are hard or impossible to understand by
* themselves, such as 'v1' or 'epi_epi'. The example below will identify
* several variables with either 'height' or 'weight' in their descriptors.
lookfor height weight

* List their values for the first ten observations.
list height weight in 1/10


* Subsetting to cross-sectional format
* ------------------------------------

* Our first step verifies whether the survey is cross-sectional. As we find
* that the data contains more than one survey wave and spans over several years,
* we keep only most recent observations. This step applies only to datasets that
* contain multiple survey years, which is generally not the case in this course.

* Check whether the survey is cross-sectional.
lookfor year
tab year

* The data should be cross-sectional for the purpose of this course. However,
* the dataset contains observations for more than one year. We will solve that
* issue by keeping observations for the 2017 survey year only.

* Keep observations for the single latest survey year.
keep if year == 2017

* The -keep- command keeps only observations for which the variable 'year' is
* equal (==) to 2017: all other dataset observations are dropped. Similarly:
drop if year != 2017

* The -drop- command tried to delete observations for which the 'year' variable
* is different (!=) from 2017 (but none were left after the -keep- command).

* Notice that the 'equal to' operator in Stata is a double equal sign (==).
* The space around logical operators is optional but recommended for clarity.

* Make sure that you fully understand how cross-sectional data are arranged by
* opening the Data Editor or using the -browse- command to take a quick look.


* Survey weights
* --------------

* The command below sets survey weights, which can be used to obtain weighted
* estimates at later stages of the analysis. We will not require them much.

* Survey weights (see NHIS documentation).
svyset psu [pw = perweight], strata(strata)


* =========================
* = VARIABLE MANIPULATION =
* =========================


* Dependent variable: Body Mass Index
* -----------------------------------

* Our next step is to compute the Body Mass Index for each observation in the
* dataset (i.e. for each respondent to the survey) from their height and weight
* by using the 'height' and 'weight' variables, and the formula for BMI.

* Create the Body Mass Index from height and weight. We can write the -generate-
* command as its -gen- shorthand. We will later call BMI our dependent variable,
* and we will use other (independent) variables to try to predict its values.
gen bmi = weight * 703 / height^2 if weight < 996 & height < 96

* If something looks wrong later on in your analysis, check your BMI equation.
* Also note that Stata is case-sensitive: we will write 'BMI' in the comments,
* but the variable itself is called 'bmi' and should be written in lowercase.


* Labelling a variable
* --------------------

* Add a description label to the variable. All label commands start with -label-
* (shorthand -la-). The one below labels a variable (shorthand -var-).
la var bmi "Body Mass Index"

* List BMI among the variables included in the current dataset.
d bmi

* The -describe- command (shorthand -d-) shows that the BMI variable is now
* part of the NHIS dataset. However, DO NOT SAVE your dataset, even when you
* perform a useful operation like this one. Instead, you will run the do-file
* to generate the variable again, hence making your calculation of BMI fully
* understandable and replicable by an exterior observer, like us, or anyone.

* Take a look at the BMI of a few respondents. Values between 15 and 40 are
* expected for human beings as we know them on this planet. We also list a
* few other variables to start thinking about possible relationships.
li sex age health bmi in 50/60
li sex age health bmi in -10/l


* Summary statistics
* ------------------

* We now turn to analysing the newly created 'bmi' variable, using the
* -summarize- command (shorthand -su-) to obtain its mean, min and max values,
* as well as standard deviation, which we will cover later on.
su bmi

* Add the -detail- option (shorthand -d-) for precise statistics that cover
* its mean, minimum and maximum values, as well as its percentile distribution.
su bmi, d

* Further sessions will gradually explain how to read each statistic displayed.
* For now, just note that the median respondent in the dataset, which is meant
* to be representative of the United States adult population in 2009, has a
* BMI of 26, which indicates overweight. The average (mean) BMI is over that
* value, which indicates that higher BMI values are either more frequent
* and/or more extreme than lower BMI values. You can also note that the top 1%
* respondents has a BMI between 41 and 50, which indicates morbid obesity.


* Visualization
* -------------

* Visualizing the distribution of BMI values among the observations contained
* in the dataset will make these first insights more clear and more complete.
* Create a histogram (shorthand -hist-) for the distribution of BMI.
hist bmi, freq normal ///
	name(bmi, replace)

* A histogram describes the distribution of the variable in the sample, i.e.
* the distribution of different values of BMI among the respondents to the
* survey. The -freq- option specifies to use percentages, and the -normal-
* option overlays a normal distribution to the histogram, a curve to which
* we will soon come back when we cover essential statistical theory. The
* -name- option saves the graph under that name in Stata temporary memory.

* Another visualization is the boxplot, which uses different criteria to shape
* the distribution of the variable. Refer to the course material to understand
* how quartiles and outliers are constructed to form each element of the plot.
* Also note that a boxplot is pretty uninformative if, as in this example, you
* decide not to split the visualization over any number of categories.
gr hbox bmi, ///
	name(bmi_boxplot, replace)

* The next example uses the -over() asyvars- options to produce boxplots of BMI
* over gender groups, and then again over insurance status. This method creates
* several box plots, one for each category -- a method called 'visualizing over
* small multiples'. The result will stay in memory under the name given by the
* -name()- option. Note, finally, that you need to select both lines to run the
* command properly: if you do not include the final line, nothing will happen.
gr hbox bmi if uninsured != 9, over(sex) asyvars over(uninsured) ///
	name(bmi_sex_ins, replace)


* Logical expressions
* -------------------

* Note how the 'DK' category for insurance status was removed by using a call
* to the conditional operator -if-, to exclude observations with an insurance
* status equal to 9 when drawing the plot. This part of the command reads as:
* draw a boxplot of all observations with an insurance status not equal to 9.

* Here are more examples of logical expressions.

su bmi if age >= 20 & age < 25
* This command reads as: 'run the -summarize- command on the 'bmi' variable,
* but only for observations for wich the 'age' variable takes a value greater
* than or equal to 20 and ('&') lesser than 25.'

su bmi if sex == 1 & age >= 65
* This command reads as: 'summarize BMI for observations of sex equal to 1
* (i.e. males in this dataset) and of age greater or equal to 65.'

su bmi if race == 2 | race == 3
* This command uses the 'race' variable, which codes Blacks and Hispanics
* with values 2 and 3. This command therefore summarises BMI only for these
* two ethnic groups: the '|' symbol is the logical operator for 'or'. It
* reads as: 'summarize BMI if the respondent is Black or Hispanic.'

* If you have many categories to select, then using the -inlist- operator might
* be much quicker. The example below selects a series of income categories that
* fall either below the minimum wage in 2009 (15,000 dollars/year) or that fall
* five times over that or more (i.e. earnings == 11, the highest income category
* in the dataset).
tab earnings if inlist(earnings, 1, 2, 3, 11)

* This operator is also practical to select countries, regions and other nominal
* variables in country-level data, and it accepts strings, i.e. text variables.
* Examples to follow later. For the moment, simply note that the example above
* uses a tabulation command because the earnings variable is categorical. This
* difference in the type of variable is crucial, and is illustrated further.


* =========================
* = INDEPENDENT VARIABLES =
* =========================


* Body Mass Index is our 'dependent variable', i.e. the one that we want to
* explain. We have reason to believe that some 'independent' variables like
* gender, health status and race could be influencing BMI. In other words,
* we assume that BMI can be partially 'predicted' by sex, health and race.
lookfor sex health race


* Summarizing over categories
* ---------------------------

* Summarize BMI (as well as height and weight) for each value of 'sex'. The
* -su- command assumes that you are describing a variable that can take any
* numeric value, and shows summary statistics for it. The -bysort- prefix
* (shorthand -bys-) takes one categorical variable and repeats the command
* over its categories. The entire command thus reads: for each value of the
* 'sex' variable, summarize the continuous variables 'bmi', 'age' and weight.
bysort sex: su bmi age weight

* Read the Stata codebook for the 'health' variable.
codebook health

* The codebook shows that the health variable comes in ordered categories.
* In that case, the -su- command will not inspect the variable properly. You
* will instead need to use either the -tab- or the -fre- command to describe
* the variable properly, by viewing its frequencies:
fre health

* Note that health is measured on five levels that come as values (1-5), and
* labels attached to them (from 'Excellent' to 'Poor'). We will discuss this
* structure in depth when we introduce variable types and value labels. For
* the moment, simply note that the health variable holds an ordinal scale
* of self-reported health status, and that the values attached to its labels
* are merely a way to create an ordinal scale: 'poor' health is not worth 5
* points of anything. Refer later to the course material to make sure that
* you are familiar with the terminology and notions of variable description.

* Summarize BMI (as well as height and weight) for each value of the health
* variable. Note that -bys- is shorthand for the -bysort- prefix.
bys health: su bmi weight


* Visualization over categories
* -----------------------------

* Graph the mean BMI of each ethnic group, using a dot plot.
gr dot bmi, over(race) ytitle("Average Body Mass Index") ///
	name(bmi_race, replace)

* Add a new categorical division between men and women to the dot plot.
gr dot bmi, over(sex) over(race) ytitle("Average Body Mass Index") ///
	name(bmi_race, replace)

* Each independent variable might influence BMI, but can also interact with
* another independent variable, making the explanation of BMI more complex
* and detailed because its predictors might also significantly interact with
* each other. Visualization allows to explore that intuition in the same way
* that it helped thinking about predictors to the dependent variable.

* The graph below explores a relationship between three independent variables.
* An additional trick in this graph is that its command runs over three lines.
* The '///' indicates that you have to select all three lines to properly run
* the graph command. This trick helps formatting do-files in short lines.
gr dot health, exclude0 yreverse over(sex) over(race) ///
	ylabel(1 "Excellent" 3 "Good" 5 "Poor") ytitle("Average health status") ///
	name(health_sex_race, replace)

* The graph uses several options: due to the numerical coding of the 'health'
* variable, we had to remove 0 from the dot plot, and reverse the axis. We also
* made the horizontal (y) axis more legible by adding (y)labels and a (y)title.
* Note that the visual difference is naturally not sufficient to establish that 
* there is a significant difference in mean BMI across racial/ethnic groups.


* ==========================
* = FINALIZING THE DATASET =
* ==========================


* Patterns of missing values
* --------------------------

* Finally, let's see how many observations have all variables measured for our
* selection of variables. The -misstable- command produces a pattern that shows
* the number of observations with no missing values across all listed variables.
* Let's first check our core demographics and socio-economic indicators:
misstable pat age sex race health earnings uninsured, freq

* There are only a few missing values in the selection of variables above, due
* to the fact that our simplified 'race' variable excludes some small groups.
* Now let's see what happens when we add the 'variable' to that list:
misstable pat age sex health race earnings uninsured bmi

* We removed the -freq- option to get the size of the data with no missing 
* values as a percentage: we lose 10% of the data due to missing values, mostly
* concentrated in the Body Mass Index measurement. The IHIS/NHIS documentation
* explains why this happens with the public data files (you can try to guess).


* Subsetting
* ----------

* We can now finalize the dataset by deleting observations with missing data in
* our selection of variables. The final count is the actual sample size that we
* will analyze at later stages of the course.
drop if mi(bmi, age, sex, health, race, earnings, uninsured)

* Final count.
count


* =======
* = END =
* =======


* Close log (if opened).
cap log close

* The command above closes the log that we opened when we started this do-file.
* Logs are essential to keep records of your analysis. They complement do-files,
* which are records of your commands and comments only. Now that you have closed
* the log below, have a quick look at it.
view code/week2.log

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit, clear
