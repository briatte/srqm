*! srqm_pkgs: install selected packages
*! use option 'force' to force the installation
*! use option 'clean' to uninstall the packages
*! use option 's2color' to restore the default color scheme
*! use option 'quiet' to run silently
*! use option 'extra' to install extra packages
cap pr drop srqm_pkgs
program srqm_pkgs
  syntax [anything] [, force clean s2color quiet extra]

global srqm_packages = "lookfor_all fre spineplot tab_chi mkcorr tabout estout leanout plotbeta kountry wbopendata spmap scheme-burd _gstd01 renvars clarify"
if "`extra'" != "" global srqm_packages = "$srqm_packages catplot ciplot distplot log2do2 outreg2 revrs schemes scheme_tufte gr0002_3 qog qogbook"

if "`anything'" == "" loc anything = "$srqm_packages"
tokenize `anything'

local force = ("`force'" != "")

if "`clean'" != "" {
  while "`*'" != "" {
      loc t = "`1'"
      if "`t'" == "renvars" loc t "dm88_1"
      * cannot use -ssc uninstall- because of a bug with dash in 'scheme-burd'
      cap qui ado uninstall "`t'"
      if _rc loc x "already "
      if "`quiet'" == "" di as inp "`t'", as txt "was `x'uninstalled"
      macro shift
  }
  if "`s2color'" != "" set scheme s2color // set scheme back to default
}
else {
  loc i = 0
  loc s = `:word count `anything''
  while "`*'" != "" {
      loc i = `++i'
      loc t = "`1'"

      cap which `t'

      // tab_chi and tabchi
      if "`t'"=="tab_chi" cap which tabchi

      // qog and qoguse
      if "`t'"=="qog" cap which qoguse
    
      // clarify
      if "`t'"=="clarify" cap which simqi
    
      // schemes
      if "`t'"=="scheme-burd" cap which scheme-burd.scheme
      if "`t'"=="scheme_tufte" cap which scheme-tufte.scheme
      if "`t'"=="schemes" cap which scheme-bw.scheme
      if "`t'"=="gr0002_3" cap which scheme-lean2.scheme
      
      if _rc==111 | `force' {

          if "`quiet'" == "" di as txt "[`i'/`s'] installing:", as inp, "`t'"
          // note: keep special cases at end of local list for the 699 hack to work with them

          if "`t'"=="spmap" {
            cap noi ssc inst spmap, replace
  					local maps "world-c.dta world-d.dta"
  					foreach y of local maps {
              ssc cp `y'
  						cap copy `y' data/`y'
  						cap rm `y'
  					}
            if !_rc di as txt "(moved to data folder: `maps')"
          }
          else if "`t'"=="renvars" {
              cap noi net ins dm88_1, from ("http://www.stata-journal.com/software/sj5-4/")
          }
          else if "`t'"=="clarify" {
              cap noi net ins `t', from("http://gking.harvard.edu/clarify")
          }
          else if "`t'"=="gr0002_3" {
              cap noi net ins `t', from("http://www.stata-journal.com/software/sj4-3")
          }
          else if "`t'"=="schemes" {
              cap noi net ins `t', from("http://leuven.economists.nl/stata/") 
          }
          else if "`t'"=="_gstd01" {
              cap noi net ins `t', from("http://web.missouri.edu/~kolenikovs/stata")
          }
          else {
              cap noi ssc inst "`t'", replace
  						if _rc==631 di as err "Could not connect to the SSC archive to look for package " as inp "`1'"
  						if _rc==601 di as err "Could not find package " as inp "`1'" as err " at the SSC archive"
          }
          if _rc==699 {

              /* issue: admin privileges required to modify stata.trk
                 workaround: install to personal folder (create if necessary)
               
                 on Sciences Po computers, path will be c:\ado\personal

                 blindly iterative so probably slow and desperate
                 but actually works and gets everything installed */

              local here = c(pwd)
              qui cd "`c(sysdir_plus)'"
              qui cd ..
              cap mkdir personal
              if !_rc noi di as txt "Could not install to the PLUS folder:" ///
                  _n "`c(sysdir_plus)'" _n ///
                  "Installing to the PERSONAL folder instead:" _n ///
                  "`c(pwd)'/personal"
              cap cd personal
              cap sysdir set PLUS "`c(pwd)'" // shouldn't ever fail
              qui cd "`here'"

              // shoot again at SSC server; should now install fine

              cap qui ssc install `t', replace
          }
      }
      else {
       if "`quiet'" == "" di as txt "[`i'/`s'] already installed:", as inp, "`t'"
      }
      if _rc di as err "Error: installation of `t' failed with error code", _rc
      macro shift
  }
}

end

// the end
