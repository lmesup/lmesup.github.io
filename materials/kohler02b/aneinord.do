* Vergleich der Einordnungsberufe
* eta^2 Klasse mit Haushaltsnettoeinkommen
* Cramers V Klasse mit Parteiidentifikation

version 6.0
clear
set memory 60m

* Retrival
* --------

* EGP und PID
#delimit ;
mkdat
egpb84 egpb85 egpb86 egpb87 egpb88 egpb89 egpb90 egpb91 egpb92
 egpb93 egpb94 egpb95 egpb96 egpb97
egpp84 egpp85 egpp86 egpp87 egpp88 egpp89 egpp90 egpp91 egpp92
 egpp93 egpp94 egpp95 egpp96 egpp97
egpt84 egpt85 egpt86 egpt87 egpt88 egpt89 egpt90 egpt91 egpt92
 egpt93 egpt94 egpt95 egpt96 egpt97
egph84 egph85 egph86 egph87 egph88 egph89 egph90 egph91 egph92
 egph93 egph94 egph95 egph96 egph97
pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92
 pid93 pid94 pid95 pid96 pid97
using $soepdir,
netto(-3,-2,-1,0,1,2,3,4,5)
files(peigen) waves(a b c d e f g h i j k l m n) ;

* Hauhaltsnettoeinkommen ;
holrein
ah46 bh39 ch51 dh51 eh42 fh42 gh42 hh48 ih49 jh49 kh49 lh50 mh50 nh50
using $soepdir, files(h) waves(a b c d e f g h i j k l m n) ;
#delimit cr

* Querschnittsgewichte
sort persnr
save 11, replace
use persnr aphrf bphrf cphrf dphrf ephrf fphrf gphrf hphrf iphrf jphrf kphrf /*
*/ lphrf mphrf nphrf using $soepdir/phrf
sort persnr
save 12, replace
use 11
merge persnr using 12, nokeep

drop ahhnr - nnetto

* Rekodierungen
* -------------

for any a b c d e f g h i j k l m n \\ num 84/97: /*
*/ ren Xphrf phrfY

for var /*
*/ ah bh ch dh eh fh gh hh4 ih jh kh lh mh nh \\ num 84/97: /*
*/ ren X hheinY


* Analyse
* -------

postfile einord welle /*
*/ e1_b e1_p e1_t e1_h e2_b e2_p e2_t e2_h /*
*/ v1_b v1_p v1_t v1_h v2_b v2_p v2_t v2_h using einord, replace
gen gr1 = .
gen gr2 = .
local i 84
while `i' <= 97 {
    * Recodierungen
    replace gr1 = egpb`i'>0 & egpp`i'>0 & egpt`i'>0 & egph`i'>0
    replace gr2 = egpp`i'>0 & egpt`i'>0 & egph`i'>0
    replace hhein`i' = . if hhein`i' <= 0
    replace pid`i' = . if pid`i' <= 0
    * Eta^2, Gruppe 1
    oneway hhein`i' egpb`i' if gr1 == 1
    local e1_b = r(mss) / (r(mss) + r(rss))
    oneway hhein`i' egpp`i' [aweight = phrf`i'] if gr1 == 1
    local e1_p = r(mss) / (r(mss) + r(rss))
    oneway hhein`i' egpt`i' [aweight = phrf`i'] if gr1 == 1
    local e1_t = r(mss) / (r(mss) + r(rss))
    oneway hhein`i' egph`i' [aweight = phrf`i'] if gr1 == 1
    local e1_h = r(mss) / (r(mss) + r(rss))
    * Eta^2, Gruppe 2
    oneway hhein`i' egpb`i' [aweight = phrf`i'] if gr2 == 1
    local e2_b = r(mss) / (r(mss) + r(rss))
    oneway hhein`i' egpp`i' [aweight = phrf`i'] if gr2 == 1
    local e2_p = r(mss) / (r(mss) + r(rss))
    oneway hhein`i' egpt`i' [aweight = phrf`i'] if gr2 == 1
    local e2_t = r(mss) / (r(mss) + r(rss))
    oneway hhein`i' egph`i' [aweight = phrf`i'] if gr2 == 1
    local e2_h = r(mss) / (r(mss) + r(rss))
    * Cramer's V, Gruppe 1
    tab pid`i' egpb`i' if gr1 == 1, V
    local v1_b = r(CramersV)
    tab pid`i' egpp`i' if gr1 == 1, V
    local v1_p = r(CramersV)
    tab pid`i' egpt`i' if gr1 == 1, V
    local v1_t = r(CramersV)
    tab pid`i' egph`i' if gr1 == 1, V
    local v1_h = r(CramersV)
    * Cramer's V, Gruppe 2
    tab pid`i' egpb`i' if gr2 == 1, V
    local v2_b = r(CramersV)
    tab pid`i' egpp`i' if gr2 == 1, V
    local v2_p = r(CramersV)
    tab pid`i' egpt`i' if gr2 == 1, V
    local v2_t = r(CramersV)
    tab pid`i' egph`i' if gr2 == 1, V
    local v2_h = r(CramersV)
    #delimit ;
    post einord `i' `e1_b' `e1_p' `e1_t' `e1_h' `e2_b' `e2_p' `e2_t'
    `e2_h' `v1_b' `v1_p' `v1_t' `v1_h' `v2_b' `v2_p' `v2_t'  `v2_h' ;
    #delimit cr
    local i = `i' + 1
}
postclose einord

use einord, clear
sum

* Graphische Dartellung

lab var e2_p "nach Pappi"
lab var e2_t "nach Terwey"
lab var e2_h "ueber Hauptverdiener"

* Graphische Darstellung
* ----------------------

capture program drop greinord
    program define greinord
        local xtics "84,85,86,87,88,89,90,91,92,93,94,95,96,97"
        local xlabs "84,86,88,90,92,94,96"
        local ylabs "0,10,20,30"
        local noxlab "xlab(85)"
        label value welle welle
        label define welle 85 " "
        label variable welle " "
        gph open, saving(aneinord, replace)
        * eta^2, Haushaltseinkommen
       graph e2_p e2_t e2_h welle, bor s(OTp) c(lll) /*
       */ xtick(`xtics') ttick(`xtics') /*
       */ `noxlab' ylab(.025,.05,.075,.1,.125,.15,.175) /*
       */ l1title("eta^2_(EGP - HHEink)") /*
       */ bbox(0,0,12433,31900,600,300,0)
       * Cramer's V, Parteiidentifikation
       graph v2_p v2_t v2_h welle, bor s(OTp) c(lll) /*
       */ xtick(`xtics') ttick(`xtics') /*
       */ xlab(`xlabs') ylab(.10,.125,.15,.175) /*
       */ l1title("Cramer's V_(EGP - PID)") /*
       */ t1title(" ") t2title(" ") /*
       */ bbox(10630,0,23063,31900,600,300,0)
       gph close
    end
greinord
graph using aneinord, b2title(Erhebungswelle) saving(einord, replace)

erase aneinord.gph
exit