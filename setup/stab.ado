*! stab: simple tables of summary statistics
*! type -stab_demo- for examples with NHANES data
*! 0.2 F. Briatte 3jun2013
cap pr drop stab
pr stab
  syntax [using/] [if] [in] [, Mean(varlist) Prop(varlist) replace]

  if "`using'" == "" {
    di as txt "... is a wrapper for the", as inp "estout", ///
      as txt "package that produces plain text tables of summary", _n ///
      "statistics; type", as inp "stab_demo", ///
      as txt "for an example with NHANES data, which uses this syntax:", _n _n _skip(4) ///
      "stab using stab_demo.txt, m(age height weight bmi) p(sex race) replace"
    exit 0
  }

  cap qui which estout
  if _rc == 111 {
    noi di as txt "installing", as inp "estout", as txt "first..."
    ssc inst estout, replace
  }

  if strpos("`using'", ".") == 0 loc using "`using'.txt"

  // it saves simple summary statistics tables in plain text

  loc fmt "noobs nonum nomti noli lab"
  loc dsu c("mean(fmt(1)) sd(fmt(1)) min(fmt(0)) max(fmt(0))")
  loc dfr c("pct(fmt(0))")
  loc out `using'
  
  tempname fh
  file open `fh' using `out', write `replace'
  file write `fh' "Descriptive statistics" _n
  file close `fh'

  // continuous variables passed to summarize() get a mean, sd and min-max
  
  qui estpost summarize `mean' `if' `in'
  esttab, `dsu' `fmt' collabels(, lhs("Variable"))
  qui esttab using `out', tab append `dsu' `fmt' collabels(, lhs("Variable"))

  // categorical variables passed to frequencies() get percentages
  
  if "`prop'" != "" {
    foreach v of varlist `prop' {
      local l: var l `v'
      qui estpost tabulate `v' `if' `in', nototal
      esttab, `dfr' `fmt' collabels("%", lhs("`l'"))
      qui esttab using `out', tab append `dfr' `fmt' collabels("%", lhs("`l'"))
    }
  }

  qui misstable pat `mean' `prop' `if' `in'
  loc n `r(N_complete)'
  loc m `r(N_incomplete)'
  if `m' > 0 loc m " (excluding `r(N_incomplete)' incomplete observations)"
  
  file open `fh' using `out', write append
  file write `fh' "N = `n'`m'"
  file close `fh'

  di as txt _n "N = `n'`m'" _n "File: {browse `out'}"
end

cap pr drop stab_hello
pr stab_hello
di "hello subworld"
end

// enjoy
