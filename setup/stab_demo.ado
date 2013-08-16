*! a demo of the -stab- command
cap pr drop stab_demo
pr stab_demo
    webuse nhanes2, clear
    la var sex "Gender"
    la var race "Race"
    stab using stab_demo.txt, m(age height weight bmi) p(sex race) replace
end
