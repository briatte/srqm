* What: SRQM profile
* Who:  F. Briatte
* When: 2012-09-09

// Use this do-file to set up Stata for the duration of the course: set your
// working directory to the SRQM folder, then type 'do profile' to configure
// your computer for the rest of the course. More advanced setup options are
// covered in the README file of the SRQM folder.

// Hook SRQM profile.
cap copy profile.do "`c(sysdir_stata)'"
if _rc == 0 {
	di as err "Setting up your computer for the SRQM course…"
	if !regexm(c(pwd),"Users") & !regexm(c(pwd),"c:") {
		di as err "Note: you are running in -experimental- mode, probably from a USB key."
		di as err "Packages -might- get installed at `c(pwd)'/Packages"
		cap mkdir "`c(pwd)'/Packages", public
		sysdir set PLUS "`c(pwd)'/Packages"
	}
	tempname fh
	file open fh using "`c(sysdir_stata)'profile.do", write replace
	file write fh "// SRQM setup" _n
	file write fh "cd " _char(34) "`c(pwd)'" _char(34) _n
	file write fh "noi run profile.do" _n
	file close fh
	local run 1
}
else { 
	local run 0
		
	noi di as inp _n "Working directory:"
	noi pwd
	noi ls, w
	
	// Check course folders.
	foreach f in  "Datasets" "Replication" "Programs" {
		cap cd "`f'"
		if _rc != 0 {
			di as err _n "Stata cannot find the " "`f'" " folder, which breaks paths in SRQM do-files."
			di as err "Please adjust the folder names or reinstall the original SRQM Teaching Pack."
			exit -1
		}
		noi di as inp _n "`f'" " folder:"
		noi pwd
		if "`f'" == "Datasets" noi ls *.dta, w
		if "`f'" == "Replication" noi ls *.do, w	
		cd ..
	}

}

// Course programs.
adopath + "`c(pwd)'/Programs"

// Permanent log.
cap log using "Replication/perma.log", name("permalog") replace
if _rc==0 {
	noi di as inp _n "Permanent log:" _n as res r(filename)
}
else if _rc==604 {
	noi di as err _n "The permanent log is apparent already open."
}
else {
	noi di as err _n "Permanent log returned an error."
}

// Finish line.
if `run'==1 noi srqm setup
noi di as inp _n "Welcome! You are running Stata with the SRQM profile."

// All set.
