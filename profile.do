
*! SRQM version 2019-02
*! URL: https://f.briatte.org/teaching/quanti/

/* --- SRQM --------------------------------------------------------------------

  This file sets up a computer for use with the SRQM course. It creates another
  profile.do file in the Stata application folder. See README file for details.

----------------------------------------------------------------------------- */

loc pid "[SRQM]"

// --- COURSE MACROS -----------------------------------------------------------

// working directory

gl SRQM_WD "`c(pwd)'"

// folders

gl SRQM_CODE  = "code"
gl SRQM_DATA  = "data"
gl SRQM_SETUP = "setup"

gl SRQM_FOLDERS  = "$SRQM_CODE $SRQM_DATA $SRQM_SETUP"

// datasets

gl SRQM_DATASETS = "ess0810 ess1214 gss0014 nhis1017 qog2019 wvs9904"

// packages

loc P_VARS    = "_gstd01 fre lookfor_all renvars" // revrs
loc P_DATA    = "kountry spmap wbopendata"
loc P_PLOTS   = "plotbeta spineplot" // catplot ciplot distplot
loc P_SCHEMES = "scheme-burd" // gr0002_3 (lean) blindschemes scheme_tufte
loc P_TABLES  = "estout leanout mkcorr tab_chi tabout" // outreg2
loc P_MISC    = "" // clarify log2do2

gl SRQM_PACKAGES = "`P_VARS' `P_DATA' `P_PLOTS' `P_SCHEMES' `P_TABLES' `P_MISC'"

// ado-files

loc A_CORE  = "srqm srqm_grab srqm_demo srqm_link srqm_pkgs srqm_scan srqm_wipe"
loc A_DATA  = "srqm_data"
loc A_UTILS = "stab stab_demo sbar sbar_demo utils"

gl SRQM_ADOFILES = "`A_CORE' `A_DATA' `A_UTILS'"

// do-files (including this one)

gl SRQM_DOFILES  = "profile.do require.do ../profile.do"

// log

gl SRQM_LOGFILE = "srqm.log"
gl SRQM_LOGNAME = regexr("$SRQM_LOGFILE", "\.", "_")

// --- COURSE LOG --------------------------------------------------------------

cap log using "$SRQM_LOGFILE", name("$SRQM_LOGNAME") replace
loc log "`c(pwd)'/$SRQM_LOGFILE"

if _rc == 604 {
  noi di as txt "logfile `log' already open"
}
else if _rc {
  noi di as txt "logfile `log' failed to open (code", _rc ")"
}
else {
  noi di as txt "logfile `log' opened"
}

// --- COURSE SETTINGS ---------------------------------------------------------

noi di as txt _n "`pid' Setting up Stata for the course..."

loc debug = 0

if c(version) < 11 | c(version) >= 14 | `debug' {
  noi di as err "`pid' WARNING:", ///
    as txt "code tested only with Stata 11, 12 and 13" _n
}

cap pr drop srqm_error
pr de srqm_error
  if _rc di as err "`pid' ERROR:", as txt "command failed (code", _rc ")"
end

if c(os) != "Unix" &  c(update_query) == "on" | `debug' {
  noi di as txt "`pid' permanently disabling -update_query-"
  cap set update_query off
  srqm_error
}

if c(more) == "on" | `debug' {
  noi di as txt "`pid' permanently disabling -more-"
  cap qui set more off, perm
  noi srqm_error
}

if c(varabbrev) == "on" | `debug' {
  noi di as txt "`pid' permanently disabling -varabbrev-"
  cap set varabbrev off, perm
  noi srqm_error
}

if c(version) < 12 | `debug' {
  noi di as txt "`pid' permanently setting -memory- to 500MB"
  cap set mem 500m, perm
  noi srqm_error
}

if c(maxvar) < 7500 | `debug' {
  noi di as txt "`pid' permanently setting -maxvar- to 7,500"
  cap set maxvar 7500, perm
  noi srqm_error
}

if c(scrollbufsize) < 500000 | `debug' {
  noi di as txt "`pid' setting -scrollbufsize- to 500,000"
  cap set scrollbufsize 500000
  noi srqm_error
}

if c(scheme) != "burd" | `debug' {
  noi di as txt "`pid' permanently setting -scheme- to 'burd'"
  cap set scheme burd, perm
  noi srqm_error
}

// --- COURSE FOLDERS ----------------------------------------------------------

foreach x of glo SRQM_FOLDERS {

  cap cd "`x'"

  if _rc {

    noi di ///
      as err "`pid' ERROR:" , ///
      as txt "missing"      , ///
      as inp "`x'"          , ///
    as txt "folder"

    exit _rc // fatal

  }

  cd ..

}

// --- COURSE UTLITIES ---------------------------------------------------------

adopath + "`c(pwd)'/$SRQM_SETUP"
cap run "$SRQM_SETUP/utils.ado"  // required by srqm_pkgs (pkgs)

// silently check setup/ folder
cap noi srqm
if _rc {
  exit -999 // bogus error code
}

loc e = 0

// check global profile.do
cap noi srqm_link
if _rc loc e = 1 // non-fatal

// check package installs
adopath + "`c(pwd)'/setup/pkgs" // find packages installed on restricted systems
cap noi srqm_pkgs, quiet
if _rc loc e = 1 // non-fatal

// check code and data
cap noi srqm_scan

if _rc {
  if _rc noi di ///
    as err "`pid' ERROR:", ///
    as txt "incomplete", ///
    as inp "$SRQM_CODE", ///
    as txt "folder"
  exit _rc // fatal
}
else if `e' {
  noi di as txt _n "`pid' WARNING: setup encountered nonfatal error(s)"
}

// --- HELLO -------------------------------------------------------------------

loc h = real(substr("`c(current_time)'", 1, 2)) // hour

if `h' <   6 loc t = "early"     // before 6am
if `h' >=  6 loc t = "morning"   // 6am  +
if `h' >= 12 loc t = "afternoon" // noon +
if `h' >= 18 loc t = "evening"   // 6pm  +
if `h' >= 22 loc t = "late"      // 10pm

if inlist("`t'", "early", "late") {

  noi di as inp _n _col(8) "It is too `t' to do statistics.", ///
    as txt "Go (back) to bed." _n

}
else {

  noi di as inp _n _col(8) "Good `t',", as txt "and welcome to the course." _n

}

// ttyl
