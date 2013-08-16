*! srqm_scan: check integrity of the SRQM folder
*! requires the 'code' and 'data' folders
cap pr drop srqm_scan
program srqm_scan
  global srqm_datasets = "ess2008 gss0012 nhis2009 qog2013 wvs2000"

  di as txt _n "Working directory:" as txt _n "{browse `c(pwd)'}"
  ls, w

  foreach f in  "data" "code" {
      cap cd "`f'"
      if _rc {
          di as err _n "Error: missing `f' folder"
          exit -1
      }
      di as txt _n "{browse `f'}" " folder:" _n c(pwd)
      if "`f'" == "data" {
          // exhaustive check
          foreach d of global srqm_datasets {
              cap confirm file `d'.dta
              if _rc {
                  di as txt "Unzipping " as inp "`d'.dta", as txt "..."
                  cap unzipfile "`d'", replace
              }
              if _rc==601 {
                  di as err _n "Error: neither `d'.dta or `d'.zip", ///
                      "could be located" _n "in the `f' folder"
                  qui cd ..
                  exit -1
              }
          }
          cap noi ls *.dta, w
      }
      if "`f'" == "code" cap noi ls *.do, w
      qui cd ..
  }

end

// cheers
