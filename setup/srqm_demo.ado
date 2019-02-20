*! srqm_demo : run SRQM do-files
*!
*! USAGE
*!
*! srqm_demo, s(1/12)  : run the whole course
*!
*! ARGUMENTS
*!
*! , using  : log the run
*!            defaults to srqm_demo.log
*!
*! , test   : perform a clean code run by first uninstalling packages
*!
*! , wipe   : run sqrm_wipe afterwards
*!
cap pr drop srqm_demo
pr srqm_demo

  syntax [using/] [, test wipe replace Sessions(numlist > 0 < 13 ascending integer)]

  cap log close _all
  loc start = c(current_time)

  if "`using'" != "" {
    log using `using', `replace' name(srqm_demo)
  }
  
  if "`sessions'" == "" {

    di as err "ERROR: no session numlist was provided"
    exit 198

  }
  
  foreach y of numlist `sessions' {

    gr drop _all
    win man close viewer _all

    if "`test'" != "" srqm_pkgs, clean quiet
    do code/week`y'.do

  }
  
  gr drop _all
  win man close viewer _all
  clear
  cap log close srqm_demo

  di as txt _n "launched: `start'", _n "finished:", c(current_time)

  if "`wipe'" != "" srqm_wipe

end

// --------------------------------------------------------------------- done --
