*! srqm_scan: check integrity of the SRQM folder
*! use option 'force' to force-unzip datasets
cap pr drop srqm_scan
program srqm_scan
  syntax [anything] [, force]
  glo srqm_datasets = "ess0810 gss0012 nhis9711 qog2013 wvs2000"
  glo srqm_folders = "code data"

  di as txt _n "Working directory:" as txt _n "{browse `c(pwd)'}"
  ls, w

  if "`anything'" == "" loc anything = "$srqm_folders"
  tokenize `anything'

  while "`*'" != "" {
      cap cd "`1'"
      if _rc {
          di as err _n "Error: missing `1' folder"
          exit -1
      }
      di as txt _n "{browse `1'}" " folder:" _n c(pwd)
      if "`1'" == "data" {
          // exhaustive check
          foreach d of global srqm_datasets {
              cap confirm file `d'.dta
              if _rc | "`force'" != "" {
                  di as txt "Unzipping " as inp "`d'.dta", as txt "..."
                  cap unzipfile "`d'", replace
              }
              if _rc==601 {
                  di as err _n "Error: neither `d'.dta or `d'.zip", ///
                      "could be located" _n "in the `1' folder"
                  qui cd ..
                  exit -2
              }
          }
          cap noi ls *.dta, w
      }
      if "`1'" == "code" cap noi ls *.do, w
      qui cd ..
      macro shift
  }

end

// cheers
