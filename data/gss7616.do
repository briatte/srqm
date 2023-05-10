
/* ----------------------------------------------------------------- GSS 7616 --

   Data:   General Social Survey (GSS)
   Source: GSS website; host: NORC, University of Chicago

   http://gss.norc.org/
   http://gss.norc.org/get-the-data/stata
   http://gss.norc.org/Get-Documentation

   - Downloads the codebook
   - Downloads GSS cross-sectional cumulative data (Release 4, August 16, 2018)
   - Subsets to years 1976, 1986, 1996, 2006 and 2016

   Last modified: 2019-02-19

----------------------------------------------------------------------------- */

loc n "gss7616"
loc b "http://gss.norc.org/Documents/"

// -------------------------------------------------------- download codebook --
// WARNING: large-ish file, 28 MB, slow download rate

loc u "`b'codebook/gss_codebook.zip"
loc f "`n'_codebook"

noi di as inp "`n':", as txt "downloading", "`u'"

copy `u' `f'.zip, public replace

* .zip
unzipfile `f'.zip, replace
rm `f'.zip

* .pdf
copy gss_codebook.pdf `f'.pdf, public replace
rm gss_codebook.pdf

// --------------------------------------------------------- download dataset --
// WARNING: large-ish file, 32 MB, slow download rate

loc u "`b'stata/GSS_stata.zip"
loc f "GSS7216_R4.DTA"

noi di as inp "`n':", as txt "downloading", "`u'"

copy `u' `f'.zip, public replace

* .zip
unzipfile `f'.zip, replace
rm `f'.zip

* extra file
rm "Release Notes 7216_R4.pdf"

* .dta
use `f', clear
rm `f'

// ----------------------------------------------------------------- finalize --

* subset to selected years
keep if inlist(year, 1976, 1986, 1996, 2006, 2016)

// ------------------------------------------------------------ label dataset --

la da "U.S. General Social Survey 1976, 1986, 1996, 2006 and 2016"

note _dta: U.S. General Social Survey 1976, 1986, 1996, 2006 and 2016
note _dta: Source: NORC, University of Chicago
note _dta: URL: {bf:http://gss.norc.org/}

// ---------------------------------------------------------- have a nice day --
