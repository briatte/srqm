// --- SRQM --------------------------------------------------------------------

// This file sets up a computer for use with the SRQM course. It creates another
// profile.do file in the Stata application folder. See README file for details.

*! http://f.briatte.org/teaching/quanti/

// --- SETTINGS ----------------------------------------------------------------

if c(os) != "Unix" cap set update_query off
if c(version) < 12 cap set mem 500m, perm
if c(more) == "on" cap qui set more off, perm
if c(scrollbufsize) < 500000 cap set scrollbufsize 500000
if c(maxvar) < 7500 cap set maxvar 7500, perm
if c(varabbrev) == "on" cap set varabbrev off, perm
if c(scheme) != "burd" cap set scheme burd, perm

// --- LOGFILE -----------------------------------------------------------------

cap log using backup.log, name(backlog) replace
if _rc==604 {
	noi di as err "(backup log already open)"
}
else if _rc {
	noi di as err "(failed open a backup log)"
}

// --- COURSE ------------------------------------------------------------------

loc e = 0

// load utilities
adopath + "`c(pwd)'/setup"
cap run setup/utils.ado
if _rc loc e = 2

// check folder
cap noi srqm_scan
if _rc loc e = 2

// check packages
cap noi srqm_pkgs, quiet
if _rc loc e = 1

// check link
cap noi srqm_link
if _rc loc e = 1

if `e' > 0 {
  di as err "Your setup is incomplete."
  if `e' > 1 exit -1
}

// --- HELLO -------------------------------------------------------------------

local t = "morning"
if real(substr("`c(current_time)'",1,2)) > 12 local t = "afternoon"
noi di as inp _n "Hello!", as txt "Good `t', and welcome to the course."

// ttyl
