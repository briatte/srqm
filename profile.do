*! http://f.briatte.org/teaching/quanti/  Sciences Po, Spring 2013  Version 1.1

// --- LOG ---------------------------------------------------------------------

cap log using backup.log, name(backlog) replace
if _rc==0 | _rc==604 {
	qui log query backlog
	noi di as inp _n "Backup log:" _n as txt r(filename)
}
else {
	noi di as err "(Could not open a backup log.)"
}

// --- COURSE ------------------------------------------------------------------

cap adopath + "`c(pwd)'/Programs"
cap noi srqm check folder, nolog
if _rc != 0 exit -1

// packages

cap noi srqm setup packages, nolog

// settings

if c(update_query)=="on" | c(more)=="on" | c(scheme) != "burd" {
	noi di as txt _n ///
		"(It looks like we need to adjust some Stata settings.)"
	cap noi srqm setup, nolog
}

// folder

if "$srqm_wd" != c(pwd) {
	noi di as txt _n ///
		"(It looks like we need to (re)locate the SRQM folder.)"
	cap noi srqm setup folder, nolog
}

// --- HELLO -------------------------------------------------------------------

local t = "morning"
if real(substr("`c(current_time)'",1,2)) > 12 local t = "afternoon"
noi di as inp _n "Good `t'!", as txt "Welcome to the course."

// ttyl
