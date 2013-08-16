// --- SRQM --------------------------------------------------------------------

// This file sets up a computer for use with the SRQM course. It creates another
// profile.do file in the Stata application folder. See README file for details.

*! http://f.briatte.org/teaching/quanti/

// --- SETTINGS ----------------------------------------------------------------

if c(os) != "Unix"
  cap set update_query off
if c(version) < 12
  cap set mem 500m, perm
if c(more) == "on"
  cap qui set more off, perm
if c(scrollbufsize) < 500000
  cap set scrollbufsize 500000
if c(maxvar) < 7500
  cap set maxvar 7500, perm
if c(varabbrev) == "on"
  cap set varabbrev off, perm
if c(scheme) != "burd"
  cap set scheme burd, perm

// --- LOGFILE -----------------------------------------------------------------

cap log using backup.log, name(backlog) replace
if _rc==604 {
	noi di as err "(backup log already open)"
}
else if _rc {
	noi di as err "(failed open a backup log)"
}

// --- COURSE ------------------------------------------------------------------

// load utilities
cap adopath + "`c(pwd)'/setup"
cap run setup/utils.ado

// check folder
cap noi srqm_scan
if _rc != 0 exit -1

// check packages
cap noi srqm_pkgs

// check link
cap noi srqm_link

// --- HELLO -------------------------------------------------------------------

local t = "morning"
if real(substr("`c(current_time)'",1,2)) > 12 local t = "afternoon"
noi di as inp _n "Hello!", as txt "Good `t', and welcome to the course."

// ttyl
