// --- SRQM --------------------------------------------------------------------

// This file sets up a computer for use with the SRQM course. It creates another
// profile.do file in the Stata application folder. See README file for details.

*! http://f.briatte.org/teaching/quanti/

cap qui set more off, perm

// --- LOG ---------------------------------------------------------------------

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
cap run setup/srqm_utils.ado

// course folder
cap noi srqm check folder
if _rc != 0 exit -1

// additional commands
cap noi srqm setup packages

// system settings
if c(update_query)=="on" | c(more)=="on" {
	noi di as txt _n ///
		"(It looks like we need to adjust some Stata settings.)"
	cap noi srqm setup
}

// link

if "$srqm_wd" != "`c(pwd)'" {
	noi di as txt _n ///
		"(It looks like we need to (re)locate the SRQM folder.)"
	cap noi srqm setup folder
}

// --- HELLO -------------------------------------------------------------------

local t = "morning"
if real(substr("`c(current_time)'",1,2)) > 12 local t = "afternoon"
noi di as inp _n "Hello!", as txt "Good `t', and welcome to the course."

// ttyl
