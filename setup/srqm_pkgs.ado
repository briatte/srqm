*! srqm_pkgs : install selected packages
*!
*! ARGUMENTS
*!
*! , c , clean    : uninstall the packages
*!
*! , f , force    : force the installation
*!
*! , s , s2color  : restore the default color scheme
*!
*! , q , quiet    : run silently
*!
cap pr drop srqm_pkgs
pr srqm_pkgs

  syntax [anything] [, Clean Force Quiet S2color]

  loc pid "[PKGS]"

  * Restricted systems can fail to write to the PLUS folder (see why and
  * possible fixes in Lembcke's "Introduction to Stata" at page 48); the
  * next bit of code tries hard to avoid the issue, and will resort to a
  * local package installation in setup/pkg if everything fails.

  * prepare to fall back to adopath alternatives (Win/UNIX)
  if "`c(os)'" != "MacOSX" cap mkdir "`c(sysdir_oldplace)'", public

  * test writing to stata.trk in PLUS codename directory
  cap pkgs, quiet
  if _rc {

    * switch path to PERSONAL (at Sciences Po, c:\ado\personal)
    cap pkgs using "`c(sysdir_personal)'", quiet

    * fall back to local install (for fully restricted systems)
    if _rc cap pkgs using "setup/pkg", quiet

  }

  * complain if it all fails (breaks executability of do-files)
  if _rc {

    di ///
      as err "`pid' ERROR:"            , ///
  	  as txt "could not find a way to" , ///
      as txt "install packages"        , ///
             "(code", _rc ")"

    exit _rc

  }

  * ----------------------------------------------------------------------------
  * by default, cycle through all course packages
  * ----------------------------------------------------------------------------

  if "`anything'" == "" {

    loc anything = "$SRQM_PACKAGES"

  }

  tokenize `anything'

  loc force = ("`force'" != "")

  if "`clean'" != "" {

    while "`*'" != "" {

        loc t = "`1'"
        if "`t'" == "renvars" loc t "dm88_1"

        * cannot use -ssc uninstall- because of a bug with dash in 'scheme-burd'
        cap qui ado uninstall "`t'"

        if _rc loc x "already " // assuming errors mean that
        if "`quiet'" == "" {
          
          di ///
            as txt "`pid'" , ///
            as inp "`t'"   , ///
            as txt "was `x'uninstalled"
          
        }

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

        // clarify
        if "`t'"=="clarify" cap which simqi

        // qog and qoguse (deprecated, the packages are outdated )
        // if "`t'"=="qog" cap which qoguse

        // schemes
        if "`t'"=="scheme-burd" cap which scheme-burd.scheme
        if "`t'"=="scheme_tufte" cap which scheme-tufte.scheme
        if "`t'"=="schemes" cap which scheme-bw.scheme
        if "`t'"=="gr0002_3" cap which scheme-lean2.scheme

        if _rc==111 | `force' {

            noi di as txt _n "`pid' installing required package", as inp "`t'"

            // note: keep special cases at end of local list for
            // the 699 hack to work with them

            if "`t'" == "wbopendata" {

              cap noi ssc inst `t', all replace
              loc maps "world-c.dta world-d.dta"

              foreach y of loc maps {

                cap copy `y' data/`y'

                if !_rc {

                  di ///
                    as txt "`pid' file" , ///
                    as inp "`y'"        , ///
                    as txt "moved to"   , ///
                    as inp "data"       , ///
                    as txt "folder"

                cap erase `y'

                } // fi error

              } // fi foreach

            }
            else if "`t'"=="renvars" {
                cap noi net ins dm88_1, ///
                    from ("http://www.stata-journal.com/software/sj5-4")
            }
            else if "`t'"=="clarify" {
            	  cap noi net ins `t', ///
            	      from("http://gking.harvard.edu/clarify")
            }
            else if "`t'"=="gr0002_3" {
                cap noi net ins `t', ///
                    from("http://www.stata-journal.com/software/sj4-3")
            }
            // else if "`t'"=="schemes" {
            //    cap noi net ins `t', ///
            //        from("http://leuven.economists.nl/stata")
            // }
            else if "`t'"=="_gstd01" {
                cap noi net ins `t', ///
                    from("http://staskolenikov.net/stata")
            }
            else {

                cap noi ssc inst "`t'", replace

                if _rc == 631 {

                  di ///
                    as err "`pid' ERROR:"                         , ///
                	  as txt "could not connect to the SSC archive" , ///
                	         "to look for package"                  , ///
                	  as inp "`1'"                                  , ///
                    as txt "(code 631)"

                }
                else if _rc == 601 {

                  di ///
                    as err "`pid' ERROR:"           , ///
                	  as txt "could not find package" , ///
                	  as inp "`1'"                    , ///
                    as txt "at the SSC archive"     , ///
                           "(code 601)"

                }
                else if _rc {

                  di ///
                    as err "`pid' ERROR:"         , ///
                	  as txt "failed to install "   , ///
                	  as inp "`1'"                  , ///
                    as txt "from the SSC archive" , ///
                           "(code", _rc ")"

                } // fi _rc

            } // fi ssc inst

        } // fi _rc == 111
        else {

        	if "`quiet'" == "" {

            di ///
              as txt "`pid' [`i'/`s'] already installed:", ///
         	    as inp, "`t'"

          }

        }

        if _rc {

          di ///
            as err "`pid' ERROR:"      , ///
            as txt "failed to install" , ///
            as inp "`t'"               , ///
            as txt "(code", _rc ")"

        }

        macro shift
    }

  }

end

// ------------------------------------------------------------------ the end --
