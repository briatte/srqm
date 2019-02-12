
// -------------------------------------------------------- NHIS 1999-2011 -----

* Last modified: 2019-02-12
* URL: http://www.cdc.gov/nchs/nhis.htm

// ------------------------------------------------------------- get the data --

* use raw data from CDC website
loc data "ihis_00001"
copy "`src'/NHIS/9711/`data'.zip" "`data'.zip"
unzipfile "`data'.zip"

* run preparation script
do "`src'/NHIS/9711/`data'.do"

erase "`data'.dat"
erase "`data'.zip"

// ------------------------------------------------------------------- subset --

* keep sample children and adults for years 1997+
qui keep if year >= 1997 & astatflg == 1
drop cstatflg astatflg

* keep only odd years
qui keep if mod(year, 2) == 1

// ------------------------------------------------ simplified raceb variable --

* simplify race variable
qui gen raceb = racea
qui replace raceb = 1 if raceb == 100
qui replace raceb = 2 if raceb == 200
qui replace raceb = 3 if hispeth != 10
qui replace raceb = 4 if raceb > 310 & raceb < 570
* 310 American Indian, 570 other, 580 unreleasable, 600 multiple

qui replace raceb = . if raceb > 4
la de raceb_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian"
la val raceb raceb_lbl
la var raceb "Racial-ethnic profile"

notes raceb: ///
	Assembled from hispeth and racea, ///
  excluding American Indians and unclassifiable cases.

// -------------------------------------------------- correlate BMI estimates --

* correlate class estimates and official figures of Body Mass Index
qui gen bmi2 = weight * 703 / height^2 if weight < 996 & height < 96

* ssc install fre
fre bmi if abs(bmi - bmi2) > 1, r(5)

mean bmi bmi2 if bmi < 99.8 [pw = sampweight]

kdensity bmi, addplot(kdensity bmi2) ti("") ///
  legend(order(1 "Official measure" 2 "Public file"))

drop bmi bmi2

// ---------------------------------------------------- drop unused variables --

* drop 10-pt health status (available only for year 1988)
drop health10pt

* drop household weights (unused)
drop hhweight

* drop supp. weights flags (unavailable after 1997)
drop supp2wt

// ----------------------------------------------------------------- finalize --

* trim
srqm_datatrim

* label and zip
srqm_datamake, ///
  label(U.S. National Health Interview Survey 1997-2011) ///
  filename(nhis9911)

* have a nice day
