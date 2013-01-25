cap pr drop plotbeta2
*! Date    : 22 Jun 2012
*! Version : 1.12
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

/*
13Oct06 v 1.11  Added the addplot() option so that I could draw additional graphs into the plot like a scatteri
22Jun12 v 1.12 Changed email address above
*/

program define plotbeta2, rclass
version 9.0
preserve

/* Check for two commas */
local inp `"`0'"'
gettoken g inp: inp, parse(",") 
gettoken g inp: inp, parse(",") 
gettoken g inp: inp, parse(",") 
if `"`inp'"'~=`""' di as text "NOTE: Make sure there are no options in the lincom expressions"

/***********************************************************************
 * Now that has been checked continue... Might extend the command to 
 * accept the options per lincom suggested above 
 ***********************************************************************/

gettoken g 0: 0, parse(",") 
syntax [, Position(numlist) VERtical EFORM Level(integer 95) LABELS CIFMT(string asis) SAVEDATA(string) ADDPLOT(string asis) *]
local gopt `"`options'"'

if "`cifmt'"=="" local cifmt "%5.2f"

if `level' <10 | `level'>99 {
  di as error "Level must be an integer between 10 and 99"
  exit(198)
}
else local lev_frac = 1-(100-`level')/200


tempfile results
drop _all
qui gen x=.
qui gen name=""
qui gen est=.
qui gen se=.
qui gen ll=.
qui gen ul =.
qui gen ci=""
qui save "`results'",replace
restore,preserve

local anylincoms 0
local failedlincoms ""
local xposi 0
local line 1
while "`g'"~="" {
  gettoken first g: g, parse("|")
  while "`first'"=="|" {
    gettoken first g: g, parse("|")
  }

  cap qui lincom `first'
  if _rc~=0 {
    di as error "lincom `first' failed"
    di "This term will not be plotted"
    local failedlincoms `"`failedlincoms' `first' "'
    continue

  }
  local anylincoms 1

  qui lincom `first'

  local est = `r(estimate)'
  local se = `r(se)'
  local ul = cond("`eform'"=="", `est'+invnorm(`lev_frac')*`se', exp(`est'+invnorm(`lev_frac')*`se') )
  local ll = cond("`eform'"=="", `est'-invnorm(`lev_frac')*`se', exp(`est'-invnorm(`lev_frac')*`se') )
  local est = cond("`eform'"=="", `est', exp(`est') )
	*** added
	  local sef : di `cifmt' `se'
  local ulf : di `cifmt' `ul'
  local llf : di `cifmt' `ll'
  local estf : di `cifmt' `est'
  local ci  "`estf' (`llf',`ulf')"

  if "`position'"~="" local xposi: word `line' of `position'
  if "`position'"=="" {
    /* make sure that the xposi macro is not updated if position() is specified
       by having this if statement in brackets
     */
    local nxpos "`nxpos' `++xposi'"
  }

  cap local varlab: variable label `first'
  if "`varlab'"=="" local varlab "`first'"

  qui use "`results'",replace
  qui set obs `line'
  qui replace est = `est' in `line'
	// added
  qui replace se = `se' in `line'
  qui replace ul = `ul' in `line'
  qui replace ll = `ll' in `line'
  qui replace x = `xposi' in `line'
  qui replace ci = "`ci'" in `line'
  if "`labels'"=="" qui replace name = "`first'" in `line'
  else qui replace name = "`varlab'" in `line'
  if trim("`first'")=="_cons" qui replace name = "Intercept" in `line'
  local `line++'
  qui save "`results'",replace
  restore,preserve

}

return local failed = `"`failedlincoms'"'

if `anylincoms'==0 {
  di as error "NO LINCOM expressions left to plot"
  exit(198)
}
 
if "`position'"=="" local position "`nxpos'"

qui use "`results'", clear
qui compress

local maxlen = length(name)

local line 1
local ylab2 ""
local ylab1 ""
foreach i of numlist `position' {
  local teylab2 = ci[`line']
  local teylab1 = name[`line++']
  local ylab2  `"`ylab2' `i' "`teylab2'" "'
  local ylab1  `"`ylab1' `i' "`teylab1'" "'
}
**local xlab2 `" xlab( `ylab2' , angle(0) labc(green) labsize(small) notick) "'
**local ylab2 `" ylab( `ylab2' , angle(0) axis(2) labc(green) labsize(small) notick) "'
**local xlab1 `" xlab( `ylab1' , angle(0) axis(2) notick) "'
**local ylab1 `" ylab( `ylab1' , angle(0) notick) "'
local xlab2 `" xlab( `ylab2' , angle(0) notick) "'
local ylab2 `" ylab( `ylab2' , angle(0) axis(2) notick) "'
local xlab1 `" xlab( `ylab1' , angle(0) axis(2) notick) "'
local ylab1 `" ylab( `ylab1' , angle(0) notick) "'

local globalg "legend(off) graphr(fc(white)) plotr(lw(none))"
**local globalg "legend(off) graphr(fc(white))"

if "`savedata'"~="" save "`savedata'", replace
if "`savedata'"~="" {
	order name est se ll ul
	format est se ll ul `cifmt'
	ren name variable
	ren est coef
	outsheet variable coef se ll ul using "`savedata'.txt", replace
	}

if "`vertical'"~="" tw (rcap ul ll x, msiz(0)) (sc est x,`xlab1' ) ///
	(sc est x, `xlab2' xaxis(2) ms(i)) `addplot', xti("",axis(2)) xscale(noli axis(1)) xscale(noli axis(2)) `globalg' `gopt' note("`level'% Confidence Intervals")
else twoway (rcap ul ll x, msiz(0) hor `ylab1') (scatter x est) (scatter x ul, `ylab2' yaxis(2) ms(i) )  `addplot', `globalg' ysc(noli axis(2)) ysc(noli axis(1)) yti("", axis(1)) yti("", axis(2)) `gopt' note("`level'% Confidence Intervals") xti("") xline(0, lp(dash))

restore
end

use data/qog2011, clear
tab ht_region, gen(rg_)
reg wdi_fr wdi_gdpc rg_*
//plotbeta2 gdp | income | Edu | democulture | PolPluralism, vertical
plotbeta2 wdi_gdpc | rg_1 | rg_2 | rg_3 | rg_4, labels cifmt(%5.1f) scheme(bw) savedata(test)
