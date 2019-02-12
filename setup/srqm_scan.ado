*! check integrity of the code/ and data/ folders
*! returns error -1 if anything is missing and cannot be restored
*!
*! ARGUMENTS
*!
*! , f , force  : force-restore all course datasets from the ZIP files
*!
cap pr drop srqm_scan
program srqm_scan
  syntax [anything] [, Force]

  loc pid   = "[SCAN]"
  loc force = ("`force'" != "")

  di as txt _n "[SRQM] working directory:" as txt _n "{browse `c(pwd)'}"
  ls, w

  if "`anything'" == "" loc anything = "$SRQM_CODE $SRQM_DATA"
  tokenize `anything'

  while "`*'" != "" {

      if !inlist("`1'", "$SRQM_CODE", "$SRQM_DATA", "$SRQM_SETUP") {

        di as err _n "`pid' ERROR:"        , ///
          as txt "invalid folder name"     , ///
          as inp  "`1'"                   _n ///
          as txt "`pid' supported names:"  , ///
          as inp "$SRQM_FOLDERS"

        exit 198

      }

      * ------------------------------------------------------------------------
      * quit if folder does not exist
      * ------------------------------------------------------------------------

      cap cd "`1'"
      if _rc {

          di as err _n "`pid' ERROR:" , ///
            as txt "missing"          , ///
            as inp "`1'"              , ///
            as txt "folder"

          exit -1 // bogus error code

      }

      di as txt _n "[SRQM] {browse `1'}" " folder:" _n c(pwd)

      * ------------------------------------------------------------------------
      * CHECK COURSE DATASETS
      * ------------------------------------------------------------------------

      if "`1'" == "$SRQM_DATA" {

          foreach d of glo SRQM_DATASETS {

              * ----------------------------------------------------------------
              * force-refresh dataset if -force- option
              * ----------------------------------------------------------------

              if `force' {

                cap erase "`d'.dta"

              }

              * ----------------------------------------------------------------
              * check for existence of dta file
              * ----------------------------------------------------------------

              cap confirm f `d'.dta

              * ----------------------------------------------------------------
              * if not (1): try restoring from zip
              * ----------------------------------------------------------------

              if _rc == 601 {

                  di _n ///
                    as txt "`pid' course dataset" , ///
                    as inp "`d'.dta"                , ///
                    as txt "not found in"           , ///
                    as inp "`1'"                    , ///
                    as txt "folder"

                  di ///
                    as txt "`pid' trying to restore" , ///
                    as inp "`d'.dta"                   , ///
                    as txt "from"                      , ///
                    as inp "`d'.zip"                   , ///
                    as txt "archive"

                  * check for existence of ZIP file
                  cap unzipfile "`d'", replace

                  if _rc == 601 {

                    di ///
                      as txt "`pid' course dataset archive"   , ///
                      as inp "`d'.zip"                        , ///
                      as txt "not found in"                   , ///
                      as inp "`1'"                            , ///
                      as txt "folder"

                  }
                  else if _rc {

                    di ///
                      as err "`pid' ERROR:"    , ///
                      as txt "failed to unzip (code", _rc ")"

                  }
                  else {

                    di ///
                      as txt "`pid'"                 , ///
                      as inp "`d'.zip"               , ///
                      as txt "successfully unzipped"

                    * check whether -unzipfile- created an unwanted subfolder,
                    * and if so, try to move its contents back to data folder.
                    * the issue was reported by student in Feb. 2019, using
                    * Stata 13 on macOS 10.14
                    cap cd `d'
                    if !_rc {

                      di ///
                        as txt "`pid' unzipping created a" , ///
                        as inp "`d'"                       , ///
                        as txt "subfolder"

                      loc f: dir "." files "*"

                      di ///
                        as txt "`pid' trying to move `:word count `f''" , ///
                        "files from it to"                              , ///
                        as inp "`1'"                                    , ///
                        as txt "folder"

                      foreach i in `f' {

                        * no replace option, in order to detect error 602
                        cap copy "`i'" "../`i'"

                        if _rc == 602 {

                          di ///
                            as err "`pid' WARNING:"     , ///
                            as inp "`i'"                , ///
                            as txt "already existed in" , ///
                            as inp "`1'"                , ///
                            as txt "folder"

                        }
                        else if _rc {

                          di ///
                            as err "`pid' ERROR:"          , ///
                            as txt "failed to move"        , ///
                            as inp "`i'"                   , ///
                            as txt "to"                    , ///
                            as inp "`1'"                   , ///
                            as txt "folder (code", _rc ")"

                        }

                        cap erase "`i'"

                      }

                      * remove subfolder (might fail because of e.g. .DS_Store)
                      qui cd ..
                      cap erase `d'

                      if _rc {

                        di ///
                          as err "`pid' WARNING:"            , ///
                          as txt "failed to erase subfolder" , ///
                          as inp "`d'"                       , ///
                          as txt "(code", _rc ")"

                      }

                    }
                    else {

                      * good, carry on

                    }

                  }

              }

              // check whether the zip successfully unpacked the dta file
              cap confirm f `d'.dta

              * ----------------------------------------------------------------
              * if not (2): try restoring from sources
              * ----------------------------------------------------------------

              if _rc {

                di ///
                  as txt "`pid' trying to restore" , ///
                  as inp "`d'.dta"                   , ///
                  as txt "from source files"

                  * run data preparation do-file
                  noi srqm_data "`d'", log

                  // silently cancel the return to working directory
                  // caused by running srqm_datamake (via srqm_data)
                  cap qui cd data

              }

              // check whether the source files created the dta file
              cap confirm f `d'.dta

              * ----------------------------------------------------------------
              * if both fallback options failed, exit
              * ----------------------------------------------------------------

              if _rc {

                  di ///
                    as err "`pid' ERROR:"      , ///
                    as txt "failed to restore" , ///
                    as inp "`d'.dta (code", _rc ")"

                  // return to working directory (does not modify _rc)
                  qui cd ..

                  exit _rc

              }

          }

          // show course datasets after they were either found or restored
          cap noi ls *.dta, w

      }

      * ------------------------------------------------------------------------
      * CHECK COURSE DO-FILES
      * ------------------------------------------------------------------------

      if "`1'" == "$SRQM_CODE" {

        * ----------------------------------------------------------------------
        * check each weekly do-file exists
        * ----------------------------------------------------------------------

        foreach i of numlist 1/12 {

          cap confirm f week`i'.do

          * --------------------------------------------------------------------
          * if not: try restoring from remote source
          * --------------------------------------------------------------------

          if _rc == 601 {

            di _n ///
              as txt "`pid' course do-file" , ///
              as inp "week`i'.do"             , ///
              as txt "not found in"           , ///
              as inp "`1'"                    , ///
              as txt "folder"

            di ///
              as txt "`pid' trying to restore"  , ///
              as inp "week`i'.do"                 , ///
              as txt "from remote repository"

            noi srqm_copy week`i'.do

            // silently cancel the return to working directory
            // caused by running srqm_copy
            cap qui cd code

          }

          * --------------------------------------------------------------------
          * if failed, exit
          * --------------------------------------------------------------------

          cap confirm f week`i'.do

          if _rc == 601 {

            di ///
              as err "`pid' ERROR:"      , ///
              as txt "failed to restore" , ///
              as inp "week`i'.do"

            // return from code/ to working directory (does not modify _rc)
            qui cd ..

            exit -1 // bogus error code

          }

        }

        // show course datasets after they were either found or restored
        cap noi ls *.do, w

      }

      * ------------------------------------------------------------------------
      * CHECK COURSE UTILITIES (NOT USED)
      * ------------------------------------------------------------------------

      if "`1'" == "$SRQM_SETUP" {

        // nothing
        cap noi ls

      }

      // return to working directory
      qui cd ..

      // next folder
      macro shift

  }

end

// cheers
