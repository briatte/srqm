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

* prepare to fall back to adopath alternatives (Win/UNIX)
if "`c(os)'" != "MacOSX" cap mkdir "`c(sysdir_oldplace)'", public
* use -pkgs- to test writing to stata.trk in PLUS codename directory
cap pkgs, quiet
if _rc {
  * switch path to PERSONAL (at Sciences Po, c:\ado\personal)
  cap pkgs using "`c(sysdir_personal)'", quiet
  * fall back to local install (for fully restricted systems)
  if _rc cap pkgs using "setup/pkg", quiet
}
* complain if it all fail (breaks executability of course do-files)
if _rc {
  di as err _n "Warning: could not find a way to install packages"
  exit -1
}

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

          if "`t'"=="wbopendata" {
            cap noi ssc inst `t', all replace
            local maps "world-c.dta world-d.dta"
            foreach y of local maps {
              cap copy `y' data/`y'
              if !_rc di as txt "(file `y' moved to data folder)"
              cap erase `y'
            }
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
              if _rc==631 di as err "Error 631: could not connect to the SSC archive to look for package " as inp "`1'"
              if _rc==601 di as err "Error 601: could not find package " as inp "`1'" as err " at the SSC archive"
          }
          * Restricted systems fail here with error 699 (see explanation and
          * possible fixes in Lembcke's "Introduction to Stata" at page 48);
          * this should be fixed by the initial calls to the -pkgs- utility.
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
