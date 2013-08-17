*! SRQM setup utilities
*! version 4.0 (split to parts and utils)
cap pr drop srqm
program srqm
  syntax, [Verbose]
  di as txt "Date:", as res c(current_date), c(current_time)
  di as txt "Software: Stata", as res c(stata_version)
  di as txt "OS:", as res c(os), c(osdtl)
  di as txt "Computer:", as res c(machine_type)
  di as txt "Working directory:", as res c(pwd)
  di as txt "Stata directories:"
  adopath
  di as txt "Course material:"
  di as txt _s(2) "folders: ", as res "$srqm_folders"
  di as txt _s(2) "datasets:", as res "$srqm_datasets"
  qui tokenize "$srqm_packages"
  di as txt _s(2) "packages:", as res "`1',", "`2',", "...", "(`:word count `*'' packages)"
  if "`verbose'" == "" exit 0
  foreach x in srqm_data srqm_datamake srqm_datatrim srqm_demo srqm_get srqm_link srqm_pkgs srqm_scan srqm_wipe stab stab_demo sbar sbar_demo utils {
    loc f "setup/`x'.ado"
    di as txt _n "`f'"
    cap noi type `f', star
    if _rc di as err "Error: utility `x' is missing"
  }
end
