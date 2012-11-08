
// repl: produce replication material folders

cap pr drop repl
program repl
	syntax name(id="project name")

// --- INIT --------------------------------------------------------------------

local pwd = c(pwd)

cap use `c(filename)', clear
if _rc != 0 di as err "`c(filename)' returned an error:", _rc

cd Replication // will fail if trying to run repl from within a do-file

cap confirm file `namelist'.do
if _rc != 0 di as err "`namelist'.do returned an error:", _rc

gr drop _all

// --- SAVE --------------------------------------------------------------------

cap mkdir `namelist', public
copy `namelist'.do `namelist'`c(dirsep)'temp.do, replace
noi cd `namelist'

cap log close `namelist'.log
cap log using `namelist'.log, name(`namelist') replace

do temp.do, nostop

cap log close `namelist' // will contain a few extra error messages

// --- CLEAN -------------------------------------------------------------------

noi ls
cap rm `namelist'.do
copy temp.do `namelist'.do
rm temp.do

tempname fh
cap file open fh using README.txt, write replace
cap file write fh ///
	"What: `namelist'"  _n ///
	"When:`c(current_date)'" _n _n

confirm file "`namelist'.do"
if _rc == 0 cap file write fh "- `namelist'.do" _n

confirm file "`namelist'.log"
if _rc == 0 cap file write fh "- `namelist'.log" _n

// --- PLOTS -------------------------------------------------------------------

qui gr dir
local plots = r(list)
local ext = "pdf"
if "`png'" != "" local ext = "png"
foreach plot of local plots {
	gr di `plot', margin(small)
	if "`plot'" != "Graph" {
		cap noi gr export ///
			"`namelist'_`plot'.`ext'" ///
			, replace

		if _rc == 0 cap file write fh "- `namelist'_`plot'.`ext'" _n
	}
}

// --- DONE --------------------------------------------------------------------

file write fh _n "Generated at `c(current_time)'." _n
file close fh

di _n as txt "Replication material exported to folder", as inp "`namelist'"
di "{browse `c(pwd)'}" _n
type README.txt

qui cd `pwd'

end

// ttyl
