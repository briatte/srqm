* What: SRQM Session 5
* Who:  François Briatte and Ivaylo Petev
* When: 2012-11-04

// draaaaaft // QOG-SOC example with CIs
// http://www.economics.gu.se/digitalAssets/1381/1381898_121023-haller--d.pdf

use datasets/qogsoc2012, clear

* Recode and relabel values.
gen region:region = ht_region
recode region (6/10=6)
la de region 1 "E. Europe and PSU" 2 "Lat. America" ///
	3 "N. Africa and M. East" 4 "Sub-Sah. Africa" ///
	5 "W. Europe and N. America" 6 "Asia, Pacific and Carribean" ///
	, modify

// DV
gr box pfi, over(region, sort(1)des) asyvars
hist pfi, by(region) bin(5) percent

ladder rsf_pfi, gen(pfi) // note: reverse-coded, measures oppression
// theory: there is a cost to oppress journalists; when is it paid?

// theory = instits
d fh_law // control: law
d ciri_kill // control: killings
gr box pfi, over(dpi_system) over(gol_polreg) // IV: instits, hyp: strong execs oppress more
sc pfi dpi_seats if dpi_seats < 1000 // IV: large legislatures oppress less

// total fractionalization
gr box pfi, over(tf)

xtile tf4 = dpi_tf, n(4) // quartiles
gr box pfi, over(tf4)

// theory = econ
gen log_exp = ln(wdi_exp) // IV: exports, hyp: more exports, less oppression
sc pfi log_exp

gen log_gdpc = ln(wdi_gdpc)
sc pfi log_gdpc
reg pfi log_gdpc

// theory = demog
gen log_rp = ln(wdi_rp) // IV: refugees, hyp: more refugees, more oppression
tw sc pfi log_rp || lfit pfi log_rp

pwcorr pfi lis_rpr60, obs


gr mat pfi fh_law dpi_tf log_exp log_gdpc log_rp if log_exp > 2

foreach v of varlist fh_law dpi_tf log_exp log_gdpc log_rp {
	reg pfi `v'
}

reg fh_law dpi_tf log_exp log_gdpc log_rp, b


* Required commands.
foreach p in WHATEVER {
	cap which `p'
	if _rc==111 cap noi ssc install `p' // install from online if missing
}

* Note: this do-file can be used as a template for your own draft, provided that
* you have set up Stata for the course by setting the working directory to the
* SRQM folder. You should have run and reviewed all previous do-files first.

* Note: rename all your files using your family names in alphabetical order,
* using underscores instead of spaces and adding a version number at the end.
* Examples: Briatte_Petev_1.do Briatte_Petev_1.log Briatte_Petev_1.pdf

* Reminder:
su bmi, d   // use su for a continuous measure
fre bmi7    // use fre for a categorical measure/recoding

* ======================
* = SUMMARY STATISTICS =
* ======================


* Reminder about building summary statistics tables
* -------------------------------------------------

* - Remember to discriminate between continuous and categorical variables.
*
*   It rarely makes sense to summarize the mean of a variable that has a low
*   number of values. Use five-number summaries (n, mean, sd, min, max) only
*   to describe continuous variables, and use frequencies to describe variables
*   that hold a low number of categories or groups.

* - Remember to report sensible values that can be interpreted.
*
*   In the example below, BMI is reported untransformed for legibility purposes.
*   We will use the log-transformed version of the variable for linear modelling
*   later on, but in the summary stats table, we want the reader to understand
*   what s/he reads in the mean, sd, min and max columns.

* - Pick your favourite export method: tabout or tsst.
*
*   This course offers a built-in command, tsst, that produces a simple summary
*   stats table in just one command. An alternative is to use the tabout package
*   after installing it. Please refer to the Stata Guide for examples of both.

* Export with tsst.
tsst using "stats.txt", su(bmi age) fr(female edu3 health phy race hins) replace
