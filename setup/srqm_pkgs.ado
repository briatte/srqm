*! srqm_pkgs: install selected packages
*! use option 'force' to force the installation
*! use option 'clean' to uninstall the packages
*! use option 'quiet' to run silently
cap pr drop srqm_pkgs
program srqm_pkgs
  syntax [, force clean quiet]

global srqm_packages = "lookfor_all fre spineplot tab_chi mkcorr tabout estout leanout plotbeta kountry wbopendata spmap scheme-burd schemes _gstd01 clarify"
local force = ("`force'" != "")

* catplot ciplot distplot log2do2 outreg2 revrs
* tufte lean2
* qog qogbook

if "`clean'" != "" {
  foreach t of global srqm_packages {
      cap noi ssc uninstall "`t'"
      if !_rc di as txt "uninstalled", as inp "`t'"
  }
  cap ssc uninstall clarify
  cap ssc uninstall _gstd01
  set scheme s2color // set scheme back to default
  di as txt "Uninstalled course packages."
}
else {
  local i = 0
  foreach t of global srqm_packages {
      local i = `i++'

      cap which `t'

      // tab_chi and tabchi
      if "`t'"=="tab_chi" cap which tabchi

      // qog and qoguse
      if "`t'"=="qog" cap which qoguse
    
      // scheme-burd
      if "`t'"=="scheme-burd" cap which scheme-burd.scheme

      if _rc==111 | `force' {

          // note: keep special cases at end of local list for the 699 hack to work with them

          if "`t'"=="spmap" {
            cap noi ssc inst spmap, replace
  					local maps "world-c.dta world-d.dta"
  					foreach y of local maps {
              ssc cp `y'
  						cap copy `y' data/`y'
  						cap rm `y'
  					}
          }
          else if "`t'"=="clarify" {
              cap which simqi
              if (_rc==111 | `force') cap noi net install clarify, from("http://gking.harvard.edu/clarify")
          }
          else if "`t'"=="_gstd01" {
              cap which _gstd01
              if (_rc==111 | `force') cap noi net install _gstd01, from("http://web.missouri.edu/~kolenikovs/stata")
          }
          else if "`t'"=="schemes" {
              cap which scheme-bw.scheme
              if (_rc==111 | `force') cap noi net install schemes, from("http://leuven.economists.nl/stata/")
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
       if "`quiet'" == "" di as inp "`t'", as txt "is already installed"
      }
      if _rc di as err "Error: installation of `t' failed with error code", _rc
  }
}

end

// the end
