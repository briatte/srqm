*! srqm_demo: run SRQM do-files
*! type -srqm_demo, s(1/12)- to run the whole course
*! use 'test' option to perform a clean code run
*! use 'wipe' option to run sqrm_wipe afterwards
*! you can log this command with [using]
cap pr drop srqm_demo
program srqm_demo
  syntax [using/] [, test wipe replace Sessions(numlist > 0 < 13 ascending integer)]

  cap log close _all
  local start = c(current_time)

  if "`using'" != "" {
    log using `using', `replace' name(srqm_demo)
  }
  
  if "`sessions'" == "" {
    di as err "Error: no session numlist was provided"
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

// done
