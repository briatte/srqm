*! srqm_demo: run SRQM do-files
*! type -srqm_demo, s(1/12)- for the whole course
cap pr drop srqm_demo
program srqm_demo
  syntax [using/] [, replace Sessions(numlist > 0 < 13 ascending integer)]

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
    clear all

    do code/week`y'.do
  }
  
  
  gr drop _all
  win man close viewer _all
  clear all

  cap log close srqm_demo
  di as txt _n "launched: `start'", _n "finished:", c(current_time)
end

// done
