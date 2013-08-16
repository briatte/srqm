*! srqm_wipe: clean up weekly work files
*! uses the -wipe- utility to remove .log and .txt 'week*' files
cap pr drop srqm_wipe
pr srqm_wipe
  wipe "code", pre("week") pwd
  wipe, ext("txt") pre("week") pwd
end

// careful with that axe
