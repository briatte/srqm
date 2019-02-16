
/* ----------------------------------------------------------------- QOG 2019 --

   Data:   Quality of Government (QOG)
   Source: Quality of Government Institute, University of Gothenburg, Sweden

   https://qog.pol.gu.se/
   https://qog.pol.gu.se/data/datadownloads/qogstandarddata
   https://www.qogdata.pol.gu.se/data/

   - Downloads the cross-sectional Standard dataset, January 2019 release
   - Downloads the codebook

   Last modified: 2019-02-14

   NOTE -- the -qog- and -qogbook- Stata packages available from SSC contain
   outdated links to both downloads and are not used here.

----------------------------------------------------------------------------- */

* dataset
loc f "qog2019.dta"
loc u "https://www.qogdata.pol.gu.se/data/qog_std_cs_jan19.dta"

di as inp "qog2019:", as txt "downloading", "`u'"

use `u', clear
saveold `f', replace // Stata 12

* codebook -- WARNING: large file, 168 MB
loc f "qog2019_codebook.pdf"
loc u "https://www.qogdata.pol.gu.se/data/qog_std_jan19.pdf"

di as inp "qog2019:", as txt "downloading", "`u'"

copy `u' `f', clear

// ------------------------------------------------------------ label dataset --

la da "Quality of Government 2019"

// ---------------------------------------------------------- have a nice day --
