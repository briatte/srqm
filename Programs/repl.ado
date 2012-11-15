
*! repl: produce replication material folders

cap pr drop repl
program repl
	syntax name(id="project name")

	di as txt "Still in development. Bye!"
	exit -1

if "$srqm_repl" != "" exit 0
global srqm_repl = 1

// --- INIT --------------------------------------------------------------------

cap cd "$srqm_wd"
local pwd = c(pwd)

di as txt "Replication dataset: `c(filename)'"
di as txt "Replication do-file: `namelist'.do"

cap use "`c(filename)'", clear
if _rc != 0 {
	di as err "Dataset error", _rc
	di as err "Please run -repl- at the end of a do-file, or load the data before running it."
	cap cd "`pwd'"
	exit -1
}

qui cd Replication // will fail if trying to run repl recursively

cap confirm file `namelist'.do
if _rc != 0 {
	di as err "Do-file error", _rc
	di as err "Please provide -repl- with the name of a do-file from the Replication folder."
	di as err "Move your project do-file there if needed."
	cap cd "`pwd'"
	exit -1
}

gr drop _all

// --- SAVE --------------------------------------------------------------------

cap mkdir `namelist', public
copy `namelist'.do `namelist'`c(dirsep)'temp.do, replace
noi cd `namelist'

cap log close `namelist'.log
cap log using `namelist'.log, name(`namelist') replace

do temp.do

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
	"When:","`c(current_date)'" _n _n

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

qui cd "`pwd'"

end

// ttyl
