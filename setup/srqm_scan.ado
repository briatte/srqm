*! srqm_scan: check integrity of the SRQM folder
*! use option 'force' to force the installation
*! use option 'clean' to uninstall the link
cap pr drop srqm_scan
program srqm_scan
  syntax [, force clean]

global srqm_datasets = "ess2008 gss0012 nhis2009 qog2013 wvs2000"

di as inp _n "Working directory:" as txt _n "{browse `c(pwd)'}"
ls, w

foreach f in  "data" "code" {
    cap cd "`f'"
    if _rc {
        di as err _n "ERROR: missing `f' folder"
        exit -1
    }
    di as txt _n "{browse `f'}" " folder:" _n c(pwd)
    if "`f'" == "data" {
        // exhaustive check
        foreach d in $srqm_datasets {
            cap confirm file `d'.dta
            if _rc {
                di as txt "SETUP: unzipping " as inp "`d'.dta", as txt "..."
                cap unzipfile "`d'", replace
            }
            if _rc==601 {
                di as err _n "ERROR: neither `d'.dta or `d'.zip", ///
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

