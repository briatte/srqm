*! http://f.briatte.org/teaching/quanti/

// Backup log.
cap log using backup.log, name(backlog) replace
if _rc==0 | _rc==604 {
	qui log query backlog
	noi di as inp _n "Backup log:" _n as txt r(filename)
}
else {
	noi di as err "(Could not open a backup log.)"
}

* Check course material
* ---------------------
*
cap adopath + "`c(pwd)'/Programs"
cap noi srqm check folder, nolog
if _rc != 0 exit -1

* 
*
*
cap noi srqm setup packages, nolog

* Check Stata settings
* --------------------
*
if c(update_query)=="on" | c(more)=="on" | c(scheme) != "burd" {
	noi di as txt _n ///
		"(It looks like we need to adjust some Stata settings.)"
	cap noi srqm setup, nolog
}

* Check link to course folder
* ---------------------------
*
if "$srqm_wd" != c(pwd) {
	noi di as txt _n ///
		"(It looks like we need to (re)locate the SRQM folder.)"
	cap noi srqm setup folder, nolog
}

* All set
* -------
*
local t = "morning"
if real(substr("`c(current_time)'",1,2)) > 12 local t = "afternoon"
noi di as inp _n "Good `t'!", as txt "Welcome to the course."

// Enjoy.
