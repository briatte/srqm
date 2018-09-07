*! where is the SRQM folder?
*! 2017-06-09
cap pr drop srqm_find
program srqm_find

if !regexm("`c(os)'", "Win") {

  // confirm f ~
  cap qui cd ~

  if _rc {
  
    di as err "ERROR:", as txt "could not find home folder"
	exit 601

  }
  
  di as txt "Looking for the", as inp "SRQM", ///
    as txt "folder in the home folder:", ///
	as inp "`c(pwd)'"

  // shell command
  !find ~ -type d -name "*SRQM"
 
 }
 else {
 
  di as txt "SORRY, this utility does not work on Windows."
  exit 0

}

end

// work in progress
srqm_find
