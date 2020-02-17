* Erzeugt langen Datensatz mit EGP, Einkommen, Prestige f"ur
* Analysen im Anhang (Unbalanced Panel-Design)

* RETRIVAL
version 6.0
set more off
clear
set memory 60m
#delimit ;
mkdat
egpb84 egpb85 egpb86 egpb87 egpb88 egpb89 egpb90 egpb91 egpb92 egpb93
 egpb94 egpb95 egpb96 egpb97
ein84 ein85 ein86 ein87 ein88 ein89 ein90 ein91 ein92 ein93 ein94 ein95
 ein96 ein97
using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)
netto(-3,-2,-1,0,1,2,3,4,5);

holrein
treim84 treim85 treim86 treim87 treim88 treim89 treim90 treim91 treim92
 treim93 treim94 treim95 treim96 treim97
wegen84 wegen85 wegen86 wegen87 wegen88 wegen89 wegen90 wegen91 wegen92
 wegen93 wegen94 wegen95 wegen96 wegen97
using $soepdir, files(pgen) waves(a b c d e f g h i j k l m n) ;
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

for any a b c d e f g h i j k l m n \\ num 84/97: /*
*/ ren Xphrf phrfY

keep persnr egp* ein* trei* wegen* phrf*

for num 84/97: replace wegenX=round(wegenX,1)
for num 84/97: replace treimX=round(treimX,1)
compress
reshape long egpb ein treim wegen phrf, i(persnr) j(welle)
save egpanh, replace
exit
