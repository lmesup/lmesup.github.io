* Replikation der eta^2 Werte von Holtman (1990) (Eink/Prestige)

version 6.0

* benoetigt hplot.ado.
capture which hplot
if _rc ~= 0 {
	archinst hplot
}

use eta, clear
gen str20 quelle = "EGP (SOEP)" in 1
replace quelle = "EGP (ALLBUS)" in 2
input
     .319  .487  .  17   "Mueller (1977)"
     .187  .149  .  8    "Wright (alt)"
     .237  .481  .  12   "Wright (neu)"
     .205  .193  .  7    "PKA (1973)"
     .277  .342  .  7    "IMSF (1973)"
end

hplot p1, l(quelle) grid s(4) pen(22) sort(-p1) /*
*/ bor t2title("Berufsprestige") title("eta^2") fontrb(570) fontcb(290) /*
*/ xscale(.1,.6) xlabel(.1,.2,.3,.4,.5,.6) f(%3.2f) ttick saving(holtm41, replace)

hplot ein, l(quelle) grid s(4) sort(- ein) /*
*/ bor t2title("Einkommen 1984") title("eta^2") fontrb(570) fontcb(290) /*
*/ xscale(.1,.6) xlabel(.1,.2,.3,.4,.5,.6) f(%3.2f) ttick saving(holtm42, replace)
exit