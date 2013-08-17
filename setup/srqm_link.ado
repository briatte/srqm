*! srqm_link: point Stata to the SRQM folder
*! use option 'force' to force the installation
*! use option 'clean' to uninstall the link
cap pr drop srqm_link
program srqm_link
  syntax [, force clean]

cap confirm file "`c(sysdir_stata)'profile.do"
if "`clean'" != "" {
  cap rm "`c(sysdir_stata)'profile.do"
  if _rc ==0 di as txt "Successfully removed", "`c(sysdir_stata)'profile.do" _n "Farewell, enjoy life and Stata."
  if _rc !=0 di as txt "Nothing to remove at", "`c(sysdir_stata)'profile.do" _n "You have already left. Be well."
  cd "`c(sysdir_stata)'" // to avoid profile.do re-setting up on Macs
}
else if _rc | "$srqm_wd" != "`c(pwd)'" | "`force'" != "" {
  tempname fh
  di as txt _n "Linking from the Stata application folder:" _n as res "`c(sysdir_stata)'profile.do"
  cap file open fh using "`c(sysdir_stata)'profile.do", write replace
  if _rc == 0 {
      file write fh _n "*! This do-file automatically sets the working directory to the SRQM folder:" _n
      file write fh "*! `c(pwd)'" _n _n
      file write fh "global srqm_wd " _char(34) "`c(pwd)'" _char(34) _n
      file write fh "cap confirm file " _char(34) _char(36) "srqm_wd`c(dirsep)'setup`c(dirsep)'srqm.ado" _char(34) _n _n
      file write fh "if _rc { // cannot load utilities" _n _tab "noi di as err _n ///" _n
      file write fh _tab _tab _char(34) "ERROR: The SRQM folder is no longer available at its former location:" _char(34) " as txt _n ///" _n
      file write fh _tab _tab _char(34) _char(36) "srqm_wd" _char(34) " _n(2) ///" _n
      file write fh _tab _tab _char(34) "This error occurs when you rename or relocate the SRQM folder." _char(34) " _n ///" _n
      file write fh _tab _tab _char(34) "Use the 'File : Change Working Directory...' menu to manually" _char(34) " _n ///" _n
      file write fh _tab _tab _char(34) "select the SRQM folder, then execute the {stata run profile} command." _char(34) " _n ///" _n
      file write fh _tab _tab _char(34) "For more help, see the README file of the SRQM folder." _char(34) _n
      file write fh _tab "exit -1" _n "}" _n "else {" _n
      file write fh _tab "cap cd " _char(34) _char(36) "srqm_wd" _char(34) _n _n
      file write fh _tab "cap noi run profile" _n
      file write fh _tab "if !_rc noi type profile.do, starbang" _n _n
      file write fh _tab "if _rc | " _char(34) _char(36) "srqm_wd" _char(34) "==" _char(34) _char(34) " { // folder check failed" _n
      file write fh _tab _tab "noi di as txt ///" _n
      file write fh _tab _tab _tab _char(34) "Some essential course material is not available in your working directory." _char(34) " _n(2) ///" _n
      file write fh _tab _tab _tab _char(34) "This error occurs when you modify the folders or files of the SRQM folder." _char(34) " _n ///" _n
      file write fh _tab _tab _tab _char(34) "Restore the SRQM folder from a backup copy or from http://f.briatte.org/srqm" _char(34) " _n ///" _n
      file write fh _tab _tab _tab _char(34) "Then set it as the working directory and execute the {stata run profile} command." _char(34) " _n ///" _n
      file write fh _tab _tab _tab _char(34) "For further help, see the README file of the SRQM folder." _char(34) _n
      file write fh _tab _tab "exit -1" _n
      file write fh _tab "}" _n
      file write fh "}" _n
      file close fh
      di as txt _n "Linking to the current working directory:" _n as res c(pwd)
      di as inp ///
          _n "IMPORTANT: make sure that the SRQM folder stays available at this location, or" ///
          _n "Stata will not find the course material when you open it, and you will have to" ///
          _n "setup your computer again."
  }
  else {
      //
      // Windows Vista and 7 machines require the user to right-click
      // the application and run it as admin for this bit to work.
      //
      di as err ///
          _n "ERROR: The Stata application folder is not writable on your system." as txt _n(2) ///
          _n "Try again while running Stata with admin privileges. If the problem persists," ///
          _n "you will have to manually select the SRQM folder from the 'File : Change" ///
          _n "Working Directory...' menu and then execute the {stata run profile} command."
          _n "at the beginning of every course session. All apologies to Windows users."
      exit 0
  }
}

end

// done
