* What: Assignment No. 1 tips and tricks* Who:  F. Briatte and I. Petev* When: 2012-02-23

// BASIC STATA OPERATIONS

* Tip (1): Set the working directory
*
* - Applies every time you open Stata (easy to forget!).
* - Requires you know where the SRQM folder is.
* - Requires you keep the SRQM folder in place.
*
cd "/Users/fr/Documents/Teaching/SRQM/"

* Tip (2): Install additional commands
*
* - Applies when the command is not native to Stata.
* - Requires to be online for 'ssc install' to work.
* - Requires you actually read the do-files :)
*
ssc install fre
ssc install spineplot
ssc install tabout

* Tip (3): Run multiple lines together
*
* - Applies every time you see '///' at the end of a line.
* - Requires you select all adjacent lines.
* - Requires you run them with Ctrl-D (Win) or Cmmd-Shift-D (Mac).
*
di "This is a test. Execute me by selecting this line, " ///
	"and this line too, " _newline ///
	"and this line too. Well done :)"

* Tip (4): Run all lines in sequential order
*
* - Applies to all do-files.
* - Requires you execute do-files in full.
* - Requires you know where you are in your code.
*
clear
set obs 100
gen test=1
ren test x // This line will not run if you do not run the previous ones.

* Tip (5): Destructive commands run only once
*
* - Applies to all do-files.
* - Requires you do not execute your do-file randomly.
* - Requires you understand the actual commands.
*
clear
set obs 100
gen test=0 // if you try to run this line twice, it will fail
ren test x // ditto, since 'test' will have already changed name to 'x'

// BASIC DATA OPERATIONS

* Tip (6): All datasets and documentation are in the SRQM Teaching Pack
*
* - The 'Datasets' folder of the 'SRQM' folder has all course datasets.
* - The attached documentation contains essential files for you to read.
* - The datasets will load only if your working directory is correctly set.
*
use "Datasets/nhis2009.dta", clear
use "Datasets/ess2008.dta", clear
use "Datasets/wvs2000.dta", clear // etc.

ls "Datasets/*.dta" // Show all datasets for this course.

* Tip (7): Your DV is just one continuous variable
*
* - The measure of your DV must take more than two values.
* - The more values your DV takes, the better (from a theoretical angle).
* - Your IVs are any variables you want, in any reasonable quantity.
*
use "Datasets/qog2011.dta", clear

su wvs_theo, d // continuous, skewness and kurtosis close to normality
hist wvs_theo, normal

su epi_up, d // continuous but far from symmetrical and excessive kurtosis
gladder epi_up
gen log_up=ln(epi_up) // log transform

su ht_regtype, d // BAD IDEA, using a continuous command on categorical data
fre ht_regtype // NOMINAL, no ordering possible, not a suitable DV at all

fre bti_wr // pseudo-continuous, imitates a scale
su bti_wr, d // reasonably normal, suitable as DV
hist bti_wr, normal

* Tip (8): Exporting summary statistics
*
* - Required for all variables used in your analysis.
* - Export continuous data summary statistics with tabstatout (part of tabout)
* - Export categorical data summary statistics with tabout (requires install).
*
su wvs_theo 
tabstat wvs_theo, c(s) s(n mean sd min max) // equivalent command
hist wvs_theo, normal
kdensity wvs_theo, normal bw(.08) // kernel density alternative visualization

* The next commands require prior installation of tabout, with this command:
ssc install tabout, replace

* Continuous data: export stats, then import CSV file in a spreadsheet editor.
tabstatout wvs_theo wvs_sup, ///
	tf(a1helper1) s(n mean sd min max) c(s) f(%9.2fc) replace

fre ht_regtype1 // categorical data
tab ht_regtype1 // equivalent command (minus the value labels)

* Categorical data: almost the same, some syntax modifications mostly.
tabout ht_regtype1 using a1helper2.csv, ///
	replace c(freq col) oneway ptot(none) f(2) style(tab) //exports frequencies

* The two files a1helper1.csv and a1helper2.csv can be imported and joined up to
* form a summary statistics table as shown in the course material. Additional 
* explanations are provided in the Stata Guide, Section 13.4.

// ADDITIONAL TRICKS

* Tip (9): Survey weights
* (for reference, not for direct use in this course)
* 
* - Look at the documentation attached to the course datasets.
* - Copy the 'svyset' command for your data and then ignore it.
* - QOG data does not have survey weights
*
use "Datasets/nhis2009.dta", clear
svyset psu [pw=perweight], strata(strata) vce(linearized) singleunit(missing)

use "Datasets/ess2008.dta", clear // read ess2008_weights.pdf
svyset [pw=dweight] // if analysing just one country (design weight)

gen wgt=pweight*dweight // product of design weights and population weights
svyset [pw=wgt] // if analysing over more than one country

use "Datasets/wvs2000.dta", clear
svyset [pw=v245]

* Tip (10): Graph labels
* 
* - use mlab() with scatterplots
* - use mark() with box plots
*
use "Datasets/qog2011.dta", clear

sc wvs_homo wdi_pop // ugly, but population can be transformed to log units
gen log_pop=ln(wdi_pop)
la var log_pop "log(Population)"

sc wvs_homo log_pop, mlab(ccodewb) // country labels, simple
sc wvs_homo log_pop, ms(i) mlab(ccodewb) mlabpos(0) // just acronyms, nicer

gr box log_pop, mark(1, mlab(cname)) // label outliers

* Tip (11): Quantile tables
* 
* - Interesting way to show detailed DV distribution for low-N data
* - Can be fit into a summary statistics tables (same number/type of columns)
* - Copy-paste code and adapt to your interests.
*
use "Datasets/qog2011.dta", clear
keep if !mi(wdi_aas) // example: access to sanitation water

// Quantile stats table.
xtile nq = wdi_aas, nq(4) // quartiles
table nq, c(n wdi_aas mean wdi_aas sd wdi_aas min wdi_aas max wdi_aas)

// Quantile groups.
qui su nq
local max = r(max)
forvalues v=1/`max' {
	di _n as res "Quantile " "`v'"
	levelsof cname if nq==`v', c sep(", ")
}

* Tip (12): Cross-dataset searches
ssc install lookfor_all, replace
lookfor_all poverty, dir(Datasets) // requires SRQM as the working directory

// That's all for now folks, hope this helps!
// EOF
