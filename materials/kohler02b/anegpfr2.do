* Ermittelt die Anzahl der Klassenpositionen, die ohne Kenntnis von ISC
* oder BST zugewiesen wurden.
* Zusatz zu anegpfre.do

version 6.0
clear
set memory 60m

mkdat                       /*
*/ iscb84 iscb85 iscb86 iscb87 iscb88 iscb89 iscb90 iscb91 iscb92 iscb93 /*
*/ iscb94 iscb95 iscb96 iscb97 /*
*/ bstb84 bstb85 bstb86 bstb87 bstb88 bstb89 bstb90 bstb91 bstb92 bstb93 /*
*/ bstb94 bstb95 bstb96 bstb97/*
*/ egpb84 egpb85 egpb86 egpb87 egpb88 egpb89 egpb90 egpb91 egpb92 egpb93 /*
*/ egpb94 egpb95 egpb96 egpb97/*
*/ using $soepdir, /*
*/ files(peigen) waves(a b c d e f g h i j k l m n) /*
*/ netto(-3,-2,-1,0,1,2,3,4,5)

keep persnr iscb* bstb* egpb*

local i 84
local insg 0
local valid 0
quietly {
    while `i' <= 97 {
        count if egpb`i' ~= .
        local insg = r(N) + `insg'
        count if egpb`i' > 0 & (bstb`i' < 0 | iscb`i' < 0 )
        local valid = r(N)  + `valid'
        local i = `i' + 1
    }
}
di "% Klassen mit halber Information: " (`valid')/`insg' * 100

exit
