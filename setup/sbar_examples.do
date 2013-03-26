use data/gss2010 if year == 2008, clear
set scheme burd
gr drop _all

* unstacked

sbar health    , name(f1, replace)  ymax(50)
sbar health sex, name(f2a, replace) ymax(50)
sbar health sex, name(f2b, replace) ymax(50) asc red
sbar health sex, name(f2c, replace) red
sbar health sex, name(f2d, replace) blu

