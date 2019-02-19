*! srqm_grab : grab SRQM course material from remote source
*!
*! USAGE
*!
*! srqm_grab [FILE] [FILE] ...
*!
*! ARGUMENTS
*!
*! , using  :  set remote source to grab [FILE] from
*!             defaults to http://f.briatte.org/stata (HTTP only)
*!
*! , backup :  keep a timestamped backup of any existing [FILE] (default)
*!
*! NOTES
*!
*! [FILE] specifies both the location of the file on the remote source and the
*! local destination, e.g.
*!
*!     srqm_grab code/week3.do
*!
*! ... will try to grab code/week3.do on the remote source, and will then save
*! it to code/week3.do on disk
*!
cap pr drop srqm_grab
pr srqm_grab

  syntax anything [using/] [, nobackup]

  tokenize `anything'

  loc pid "[GRAB]"

  * ----------------------------------------------------------------------------
  * test Internet connection
  * ----------------------------------------------------------------------------

  cap qui net
  if _rc == 631 {

      di ///
        as err "`pid' ERROR:", ///
        as txt "no active Internet connection"

      exit 631

  }

  * ----------------------------------------------------------------------------
  * set remote source
  * ----------------------------------------------------------------------------

  if "`using'" == "" {

    * [NOTE, 2019-02-16] it would be nice to allow both HTTP and HTTPS here, by
    * injecting an 's' in the http protocol when Stata (13+) supports it:
    *
    * loc s = cond(c(version) >= 13, "s", "")
    *
    * however, my Web server enforces (what I suppose to be) an AES encryption
    * protocol that is not supported by Stata (13), so I modified my .htaccess
    * instead, forcing HTTP only on the stata/ folder

    loc using "http`s'://f.briatte.org/stata" // always uses http://

  }

  * ----------------------------------------------------------------------------
  * run from SRQM folder
  * ----------------------------------------------------------------------------

  * save working directory, to be restored before exiting
  loc pwd "`c(pwd)'"

  qui cd "$SRQM_WD"

  * ----------------------------------------------------------------------------
  * cycle through arguments
  * ----------------------------------------------------------------------------

  while "`*'" != "" {

    di as txt "`pid' source:", as inp "`using'/`1'"
    di as txt "`pid' target:", as inp "`1'"

    // ------------------------------------------------------ parse filenames --

    * dirname
    loc d = regexm("`1'", "(.*)/") // greedy
    if `d' > 0 {
      loc d = regexs(1)
    }
    else {
      loc d "" // no directory, download to root (SRQM) folder
    }

    * basename
    loc f = regexm("`1'", "(.*)\.") // greedy
    if `f' > 0 {
      loc f = regexs(1)
    }
    else {
      loc f "`1'" // no file extension
    }
    if "`d'" != "" loc f = regexr("`f'", "^`d'/", "")

    * file extension
    loc e = regexr("`1'", "`f'", "")
    if "`d'" != "" loc e = regexr("`e'", "^`d'/", "")

    * quit if no file extension (e.g. '.foo')
    if "`f'" == "" {

      di ///
        as err "`pid' ERROR:", ///
        as txt "malformed filename"

      qui cd "`pwd'"
      exit -1 // bogus error code

    }

    // ------------------------------------------------- create a backup copy --

    * backup filename
    loc b = subinstr("`f' backup `c(current_date)'", " ", "_", .)
    loc b = cond("`d'" == "", "`b'`e'", "`d'/`b'`e'")

    * always create a backup
    cap qui copy "`1'" "`b'", public replace
    if !_rc {
      di as txt "`pid' backup:", as inp "`b'"
    }
    else {
      di as txt "`pid' (no backup created, file does not exist yet)"
    }

    // --------------------------------------------------- erase and download --

    * erase destination
    cap qui erase "`1'"

    * replace with remote file
    cap qui copy "`using'/`1'" "`1'", public replace

    if !_rc {

      di as txt "`pid' successfully downloaded"

      // ------------------------------ recommendations to open/load the file --

      * Stata do-files
      *
      if regexm("`e'", "\.a?do$") {
        di "`pid' {stata doedit `1':doedit `1'}"
      }
      *
      * Stata datasets
      *
      else if "`e'" == ".dta" {
        di "`pid' {stata use `1', clear:use `1', clear}"
      }
      *
      * CSV or TSV datasets (Stata 12 or 13+; might also work with Stata 11-)
      * https://www.stata.com/help12.cgi?import
      *
      else if regexm("`e'", "\.[ct]sv$") {

        loc f = cond(c(version) >= 13, "import delim", "insheet")
        di "`pid' {stata `f' `1', clear:`f' `1', clear}"

      }
      *
      * Excel spreadsheets (Stata 13+)
      *
      else if regexm("`e'", "\.xlsx?$") & c(version) >= 13 {
        di "`pid' {stata import excel `1', clear:import excel `1', clear}"
      }
      *
      * PDF files (Mac/Unix only)
      *
      else if "`e'" == ".pdf" & !regexm("`c(os)'", "Win") {
        di "`pid' {stata !open `1':open `1'}"
      }
      else {
        // not handling TXT, which can be many things
        // not handling ZIP, but could -unzipfile- in the right directory?
      }

    }
    else {

      // ----------------------------- handle download errors: restore backup --

      loc e "failed to copy file from remote source"

      if _rc == 601 {
        loc e "file does not exist on remote source"
      }

      di as err "`pid' ERROR:" , as txt "`e' (code", _rc ")"

      * restore backup file
      cap qui copy "`b'" "`1'", public replace

      if !_rc {

        cap erase "`b'"
        di as txt "`pid' (target left intact, restored from backup)"

      }
      else {
        * handle both errors and no-backup-file situations
        di as txt "`pid' (no backup to restore)"
      }

    }

    // --------------------- if [, nobackup] and backup exists, get rid of it --

    cap conf f `b'
    if !_rc & "`backup'" == "nobackup" {

      di as txt "`pid' (erasing backup)"
      cap erase "`b'"

    }

    macro shift

  }

  * ----------------------------------------------------------------------------
  * restore previous working directory
  * ----------------------------------------------------------------------------

  qui cd "`pwd'"

end

// ------------------------------------------------------------------ kthxbye --
