*! sbar: simple bar plots with color gradients
*! type -sbar_demo- for examples with NHANES data
*! 0.3 F. Briatte 1jun2013
cap pr drop sbar
program sbar
	syntax varlist(max=3) [if] [in] [aweight fweight iweight/] ///
		[, Reds Blues Greens Purples Ascending Descending Horizontal ///
		Ymax(int 100) Float(int 0) Size(real 3.5) ANGLE(int 0) NOPercent XLAb *]

	// parse options

	local plot = cond("`horizontal'" != "", "hbar", "bar") // bars by default	

	if strpos("`options'", "stack") > 0 local pos = "position(center)"

	if "`nopercents'" == "" local b = "blabel(bar, `pos' size(`size') format(%3.`float'f))"

	local red = ("`reds'"    != "")
	local blu = ("`blues'"   != "")
	local grn = ("`greens'"  != "")
	local pur = ("`purples'" != "")
	local colorsum = `red' + `blu' + `grn' + `pur'
	if `colorsum' > 1 {
		di as err "only one color option allowed"
		exit 198
	}
	else {
		// colors taken from Cynthia Brewer's ColorBrewer,
		// using the extreme values from RdBu-7 and PRGn-7
		if `red' local col = "178 24 43"
		if `blu' local col = "33 102 172"
		if `grn' local col = "27 120 55"
		if `pur' local col = "118 42 131"
	}

	local asc = ("`ascending'" != "")
	local des = ("`descending'"!= "")
	if `asc' + `des' > 1 {
		di as err "only one sort option allowed"
		exit 198
	}
	else {
		local rev = cond(`des' == 1, 1, 0) // ascending order by default
		if `asc' + `des' > 0 local y "`y' asyvars"
		if `asc' + `des' > 0 & `colorsum' < 1 di as txt ///
			"Warning: no color option specified; " ///
			"sort option ignored"
	}

	// parse variables
		
	tokenize `varlist'
	
	if "`2'" != "" loc stat ", chi2"
	tab `1' `2' `if' `in' `stat'
	local ycat = r(r)
	
	local angle "lab(angle(`angle'))"
	
	if `: word count `varlist'' > 1 {
		local p = cond("`3'" == "", "`2' `by'", "`2' `3' `by'")
		local y = "`y' percent(`p') over(`2', `angle')"
		if `: word count `varlist'' > 2 local y = "`y' over(`3', `angle')"
	}
	else {
		local y = "`y' percent"
	}
	
	local t1: variable l `1'
	if "`xlab'" != "" {
		local t2: variable l `2'
		local b1 = cond("`horizontal'" != "", "", "`t2'")
		local l1 = cond("`horizontal'" != "", "`t2'", "")
	}
		
	if "`col'" != "" {
		local gradient ""
		qui levelsof `1' `if' `in', local(n)
		local i = 1
		foreach l of local n {
			local d = round((`i' + 1) / (`ycat' + 1), .01)
			if `rev' == 1 local d = round((`ycat' + 2  -`i') / (`ycat' + 1), .01)
			local gradient "`gradient' bar(`i++', blc(`col'*0) bfc(`col'*`d'))"
		}
	}
	
	// debug catplot command
	// di as err "`gradient'"
	
	cap which catplot
	if _rc == 111 qui ssc install catplot, replace

	catplot `1' `if' `in', `y' `b' recast(`plot') yla(0(20)`ymax', angle(h)) ///
		legend(bmargin(bottom) row(1)) ///
		ti("`t1'", margin(bottom)) yti("") b1ti("`b1'") l1ti("`l1'") ///
		`gradient' `options' inten(100)
end

// work in progress
