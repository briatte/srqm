*! SRQM setup utilities
*! version 4.0 (split to parts and utils)
cap pr drop srqm
program srqm

  di as txt "Date:", as res c(current_date), c(current_time)
  di as txt "Software: Stata", as res c(stata_version)
  di as txt "OS:", as res c(os), c(osdtl)
  di as txt "Computer:", as res c(machine_type)
  di as txt "Working directory:", as res c(pwd)
  di as txt "Stata directories:"
  adopath

end
