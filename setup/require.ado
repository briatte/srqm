
// require: SSC package checker

cap pr drop require
program require
	syntax anything
	tokenize `anything'

	while "`*'" != "" {
		cap which `1'
		if _rc==0 di as txt "Package " as inp "`1'" as txt " is installed."
		if _rc==111 cap noi ssc install `1', replace
		if _rc==631 di as err "Could not connect to the SSC archive to look for package " as inp "`1'"
		if _rc==601 di as err "Could not find package " as inp "`1'" as err " at the SSC archive"
		macro shift
	}
end
