
/* -----------------------------------------------------------------------------
   
   DEBUG DO-FILE
   
   Execute this do-file if you need me to help you debug your system:
   
   1. Open Stata
   2. Select the 'File > Set working directory...' menu item
   3. Select the SRQM folder - which should be on your Desktop
   4. Type the following command to run the script:

   do setup/debug

   Send me the debug.log file that it will create in the SRQM folder.
   
----------------------------------------------------------------------------- */

cap log close
log using debug.log, name(srqm_debug) replace

* cd /Users/fr/Desktop/SRQM // uncomment that line only if asked to

* ------------------------------------------------------------------------------
* 1. List available files
* ------------------------------------------------------------------------------

ls
ls code
ls data
ls setup

ls setup/pkgs
ls setup/pkgs/ado
ls setup/pkgs/ado/f
ls setup/pkgs/ado/plus
ls setup/pkgs/ado/plus/f

* ------------------------------------------------------------------------------
* 2. Try to find course paths
* ------------------------------------------------------------------------------

cap noi which srqm
cap noi srqm

* ------------------------------------------------------------------------------
* 3. If fails, list default paths
* ------------------------------------------------------------------------------

if _rc {

	adopath   // paths
	* sysdir  // shorter version of -adopath-
	macro dir // system details
	
}

* ------------------------------------------------------------------------------
* 4. List packages
* ------------------------------------------------------------------------------

ado

* ------------------------------------------------------------------------------
* 5. Full Stata settings
* ------------------------------------------------------------------------------

creturn li

log close srqm_debug

* see you later
