* Graphik zur Darstellung der Ergebnisse von Berelson (1954: 117-122)

* Dateneingabe
clear
input str20 kontakt discuss family friend collegue
 gleichdenkend      1   6  5   6 
 unentschlossen     2  17 14  11
 andersdenkend     13  25  9  11
end

lab var discuss "Diskussionspartner"
lab var family "Familie"
lab var friend "Freunde"
lab var collegue "Kollegen"

set textsize 150
hplot discuss, legend(kontakt) border grid /*
*/ t1title(Diskussionspartner) saving(11.gph, replace)
hplot family, legend(kontakt) border grid /*
*/ t1title(Familie) saving(12.gph, replace)
hplot friend, legend(kontakt) border grid /*
*/ t1title(Freunde) saving(13.gph, replace)
hplot collegue, legend(kontakt) border grid /*
*/ t1title(Kollegen) saving(14.gph, replace)
set textsize 100

graph using 11 12 13 13, saving(berel1, replace)
exit







exit
