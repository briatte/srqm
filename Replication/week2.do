* What: SRQM Session 2
* Who:  F. Briatte and I. Petev
* When: 2012-01-26


* ================
* = INTRODUCTION =
* ================


* Hi! Welcome to your second SRQM do-file.

* All do-files for this course assume that you have set up Stata for your
* computer. This includes setting up several parameters, most importantly
* setting the working directory to your SRQM folder. Please refer to the
* do-file from Session 1 for guidance on setup.

* Welcome again to Stata. This do-file contains the commands used during our 
* second session. Read the comment lines as you go along. We will explore the
* NHIS 2009 dataset with a few basic, descriptive Stata commands. This implies
* that you have acess to the dataset on your current computer.

* Data: U.S. National Health Interview Survey (2009).
use "Datasets/nhis2009.dta", clear

* Once the dataset is loaded, the Variables window will fill up, and you will 
* be able to look at the actual dataset from the Data Editor. Read from the 
* course material to make sure that you know how to read through a dataset:
* its data structure should show observations in rows and variables in columns.
* If the columns contain years, then the dataset needs to be reshaped: follow
* the instructions from the Stata Guide to do so, and ask us for assistance.

* Log the commands and results from this do-file.
cap log using "Replication/week2.log", name(week2) replace


* ====================
* = DATA EXPLORATION =
* ====================


* Our first step verifies whether the survey is cross-sectional. If we find 
* that the data spans over several years, we will suppress observations for 
* all but one year of data. We will talk again about cross-sectional data.

* List all variables in the dataset.
describe

* Check whether the survey is cross-sectional.
lookfor year
tab year

* The data should be cross-sectional for the purpose of this course. However,
* the dataset contains observations for more than one year. We will solve that 
* issue by keeping observations for the 2009 survey year only.

* Delete all observations except for 2009.
drop if year != 2009

* The 'drop' command deleted all observations for which the variable 'year' is 
* different (!=) from 2009. An equivalent command would be:
*
* keep if year==2009
*
* This command keeps only observations for which the 'year' variable is equal 
* (==) to 2009. Notice that the 'equal to' operator in Stata is a double equal 
* sign (==). Logical operators apply to many commands: read on to find out.
* Also note that the spaces around logical operators are optional.

* Locate some variables of interest by looking for keywords in the variables.
* You can explore your dataset by looking for particular keywords in the
* variable names and labels. This is particularly useful when your dataset
* comes with variable names that are hard or impossible to understand by 
* themselves, such as 'v1' or 'epi_epi'. The example below will identify 
* several variables with either 'height' or 'weight' in their descriptors.
lookfor height weight

* List their values for the first ten observations.
list height weight in 1/10


* ===========================
* = VARIABLE TRANSFORMATION =
* ===========================


* Our next step is to compute the Body Mass Index for each observation in the 
* dataset (i.e. for each respondent to the survey) from their height and weight
* by using the 'height' and 'weight' variables, and the formula for BMI.

* Create the Body Mass Index from height and weight.
* The 'gen' command is shorthand for 'generate'.
gen bmi = weight*703/(height^2)

* If something looks wrong later on in your analysis, check your BMI equation.
* Also note that Stata is case-sensitive: we will write 'BMI' in the comments, 
* but the variable itself is called 'bmi' and should be written in lowercase.

* Add a description label to the variable. We will come back to labels, as
* they have many different uses. All label commands start with 'label' ('la').
* The one below applies a label to a variable (shorthanded 'var'):
la var bmi "Body Mass Index"

* List BMI among the variables included in the current dataset.
d bmi

* The 'describe' command (shorthanded 'd') shows that the BMI variable is now
* part of the NHIS dataset. However, DO NOT SAVE your dataset, even when you
* perform a useful operation like this one. Instead, you will run the do-file
* to generate the variable again, hence making your calculation of BMI fully
* understandable and replicable by an exterior observer, like us, or anyone.

* Take a look at the BMI of a few respondents. Values between 15 and 40 are 
* expected for human beings as we know them on this planet. We also list a
* few other variables to start thinking about possible relationships.
list sex age health bmi in 50/60
list sex age health bmi in -10/l


* ======================
* = SUMMARY STATISTICS =
* ======================


* We now turn to analysing the newly created 'bmi' variable, using the 
* 'summarize' command (shorthand 'su') to obtain its mean, min and max values, 
* as well as standard deviation, which we will cover later on.
su bmi

* Add the 'detail' option (shorthanded 'd') for precise statistics that cover
* its mean, minimum and maximum values, as well as its percentile distribution.
su bmi, d

* Further sessions will gradually explain how to read each statistic displayed.
* For now, just note that the median respondent in the dataset, which is meant 
* to be representative of the United States adult population in 2009, has a 
* BMI of 26, which indicates overweight. The average (mean) BMI is over that
* value, which indicates that higher BMI values are either more frequent 
* and/or more extreme than lower BMI values. You can also note that the top 1% 
* respondents has a BMI between 41 and 50, which indicates morbid obesity.

* Visualizing the distribution of BMI values among the observations contained
* in the dataset will make these first insights more clear and more complete.
* Create a histogram (shorthanded 'hist') for the distribution of BMI:
hist bmi, freq normal name(bmi, replace)

* A histogram describes the distribution of the variable in the sample, i.e.
* the distribution of different values of BMI among the respondents to the 
* survey. The 'freq' option specifies to use percentages, and the 'normal' 
* option overlays a normal distribution to the histogram, a curve to which 
* we will soon come back when we cover essential statistical theory. The
* 'name' option saves the graph in Stata temporary memory.

* Another visualization is the boxplot, which uses different criteria to shape
* the distribution of the variable. Refer to the course material to understand
* how quartiles and outliers are calculated to form each element of the plot.
gr hbox bmi, name(bmi_boxplot, replace)

* This more complex example uses with the 'over() asyvars' option to produce the
* box plots of BMI over gender categories, and then again over insurance status.
* Note that you need to select BOTH LINES TOGETHER to run the command properly.
* The result will stay in memory under the name given by the name() option.
gr hbox bmi if uninsured != 9, ///
	over(sex) asyvars over(uninsured) name(bmi_sex_ins, replace)

* Note how the 'DNK' category for insurance status was excluded by using a call
* to a conditional operator (if), which excluded observations with an insurance 
* status equal to 9 when drawing the plot. This part of the command reads as:
* 'draw a boxplot for all observations with an insurance status not equal to 9'.

* Here are more examples of logical operators:

su bmi if age >= 20 & age < 25
* This command reads as: 'run the 'summarize' command on the 'bmi' variable,
* but only for observations for wich the 'age' variable takes a value greater 
* than or equal to 20 and ('&') lesser than 25.'

su bmi if sex==1 & age >= 65
* This command reads as: 'summarize BMI for observations of sex equal to 1
* (i.e. males in this dataset) and of age greater or equal to 65.'

su bmi if raceb==2 | raceb==3
* This command uses the 'raceb' variable, which codes Blacks and Hispanics
* with values 2 and 3. This command therefore summarises BMI only for these
* two ethnic groups: the '|' symbol is the logical operator for 'or'. It
* reads as: 'summarize BMI if the respondent is Black or Hispanic.'

* If you have many categories to select, then using the -inlist- operator might
* be much quicker. The example below selects a series of income categories that
* fall either below the minimum wage in 2009 (15,000 dollars/year) or that fall
* five times over that or more (i.e. earnings==11, the highest income category 
* in the dataset).
tab earnings if inlist(earnings,1,2,3,11)

* This operator is also practical to select countries, regions and other nominal
* variables in country-level data, and it accepts strings, i.e. text variables.
* Examples to follow later. For the moment, simply note that the example above
* uses a tabulation command because the earnings variable is categorical. This
* difference in the type of variable is crucial, and is illustrated further.


* =========================
* = INDEPENDENT VARIABLES =
* =========================


* Body Mass Index is our "dependent" variable, i.e. the one that we want to 
* explain. We have reason to believe that some 'independent' variables like 
* gender, health status and race could be influencing BMI. In other words,
* we assume that BMI can be partially 'predicted' by sex, health and race.
lookfor sex health race

* Summarize BMI (as well as height and weight) for each value of 'sex'. The
* 'su' command presumes that you are describing a variable that can take any
* numerical value, and shows a five-number summary of it.
bysort sex: su bmi age height weight

* Read the Stata codebook for the 'health' variable:
codebook health

* The codebook shows that the 'health' variable comes in ordered categories.
* In that case, the 'su' command will not inspect the variable properly. You
* will instead need to use either the 'tab' or the 'fre' command to describe
* the variable properly, by viewing its frequencies:
fre health

* Note that health is measured on five levels that come as values (1-5), and
* labels attached to them (from "Excellent" to "Poor"). We will discuss this
* structure in depth when we introduce variable types and value labels. For
* the moment, simply note that the 'health' variable holds an ordinal scale
* of self-reported health status, and that the values attached to its labels
* are merely a way to create an ordinal scale: "poor" health is not worth 5
* points of anything. Refer later to the course material to make sure that
* you are familiar with the terminology and notions of variable description.

* Summarize BMI (as well as height and weight) for each value of 'health'.
bysort health: su bmi weight

* Graph the mean BMI of each ethnic group, using a dot plot.
gr dot bmi, over(raceb) ytitle("Average Body Mass Index") name(bmi_race, replace)

* Add a new categorical division between men and women to the dot plot.
gr dot bmi, over(sex) over(raceb) ytitle("Average Body Mass Index") name(bmi_race, replace)

* Each independent variable might influence BMI, but can also interact with
* another independent variable, making the explanation of BMI more complex 
* and detailed because its predictors might also significantly interact with
* each other. Visualization allows to explore that intuition in the same way
* that it helped thinking about predictors to the dependent variable. 

* The graph below explores a relationship between three independent variables.
* An additional trick in this graph is that its command runs over three lines.
* The '///' indicates that you have to select all three lines to properly run
* the graph command. This trick helps formatting do-files in short lines.
gr dot health, exclude0 yreverse over(sex) over(raceb) ///
	ylabel(1 "Excellent" 3 "Good" 5 "Poor") ytitle("Average health status") ///
	name(health_sex_race, replace)

* The graph uses several options: due to the numerical coding of the 'health'
* variable, we had to remove 0 from the dot plot, and reverse the axis. We also
* made the horizontal (y) axis more legible by adding (y)labels and a (y)title.

* Note that the visual difference is not sufficient to establish that there is
* a statistically significant difference in mean BMI across ethnic groups. Also
* note that the entire analysis will not inform us at any point about causality
* because causal links are provided by your theory, not by statistical analysis
* alone. The rest of the course will advance with that word of caution in mind.


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close week2

* The command above closes the log that we opened when we started this do-file.
* Logs are essential to keep records of your analysis. They complement do-files,
* which are records of your commands and comments only. Now that you have closed
* the log below, have a quick look at it.
view "Replication/week2.log"

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
