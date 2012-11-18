
*! repl: creates a replication material folder

cap pr drop repl
program repl
	syntax name(id="project name")

// --- INIT --------------------------------------------------------------------

local pwd = c(pwd)
if "`pwd'" != "$srqm_wd" {
	di as err "Not running from the SRQM folder."
	exit 0
}

*! - copy of do-file
cap mkdir `namelist', public
cap qui copy "Replication/`namelist'.do" "`namelist'`c(dirsep)'temp.do", replace
if _rc ==0 di as txt "Replication do-file: Replication/`namelist'.do"
cap confirm file `namelist'.do
if _rc != 0 {
	di as err "Do-file error", _rc
	di as err "Please use -repl- on a do-file from the Replication folder."
	di as err "Move your project do-file there if needed."
	cap cd "`pwd'"
	exit 198
}

*! - copy of dataset
cap mkdir "`namelist'`c(dirsep)'datasets", public
cap use "`c(filename)'", clear
local data = c(filename)
while strpos("`data'","/") > 0 {
	local data = substr("`data'",strpos("`data'","/")+1,length("`data'"))
	di "`c(filename)'","`data'"
}
cap qui save "`namelist'`c(dirsep)'datasets`c(dirsep)'`data'", replace
if _rc == 0 di as txt "Replication dataset: `c(filename)'"
if _rc != 0 {
	di as err "Dataset error", _rc
	di as err "Please run -repl- at the end of a course do-file."
	di as err "Alternatively, load the data in memory before running."
	cap cd "`pwd'"
	exit 198
}

qui cd Replication // will fail if trying to run repl recursively


gr drop _all

// --- SAVE --------------------------------------------------------------------


qui copy `namelist'.do `namelist'`c(dirsep)'temp.do, replace

cap log close `namelist'.log
cap log using `namelist'.log, name(`namelist') replace

gr drop _all
run temp.do, nostop
if _rc != 606 di as err "Do-file ended with error",_rc

cap log close `namelist' // will contain a few extra error messages

// --- CLEAN -------------------------------------------------------------------

cap rm `namelist'.do
copy temp.do `namelist'.do
rm temp.do

rm "datasets/`data'"
rmdir datasets

noi ls, w

tempname fh
cap file open fh using README.txt, write replace
cap file write fh ///
	"What: `namelist'" _n ///
	"When: `c(current_date)'" _n _n "Files:" _n _n

confirm file "`namelist'.do"
if _rc == 0 cap file write fh "- `namelist'.do" _n

confirm file "`namelist'.log"
if _rc == 0 cap file write fh "- `namelist'.log" _n

// --- PLOTS -------------------------------------------------------------------

qui gr dir
local plots = r(list)
*! - copy of saved plots
if r(list) != " " & r(list) != "Graph " { // skip if no plot or just one unnamed
	file write fh _n "Graphs:" _n _n
	local ext = "pdf"
	if "`png'" != "" local ext = "png"
	foreach plot of local plots {
		gr di `plot', margin(small)
		if "`plot'" != "Graph" {
			cap qui gr export ///
				"`namelist'_`plot'.`ext'" ///
				, replace
	
			if _rc == 0 cap file write fh "- `namelist'_`plot'.`ext'" _n
		}
	}
}

// --- DONE --------------------------------------------------------------------

file write fh _n "Generated at `c(current_time)'." _n
file close fh

di _n as txt "Replication material exported to folder", as inp "`namelist'"
di "{browse `c(pwd)'}" _n
type README.txt

qui cd "`pwd'"
exit 0

end

// ttyl
