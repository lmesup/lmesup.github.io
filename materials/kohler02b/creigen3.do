* Erzeugt Datensatz aller generierten Variablen aller Wellen, brutto
version 6.0
clear
set memory 60m

#delimit ;
mkdat
egpb84 egpb85 egpb86 egpb87 egpb88 egpb89 egpb90 egpb91
 egpb92 egpb93 egpb94 egpb95 egpb96 egpb97
egph84 egph85 egph86 egph87 egph88 egph89 egph90 egph91
 egph92 egph93 egph94 egph95 egph96 egph97
egpp84 egpp85 egpp86 egpp87 egpp88 egpp89 egpp90 egpp91
 egpp92 egpp93 egpp94 egpp95 egpp96 egpp97
egpt84 egpt85 egpt86 egpt87 egpt88 egpt89 egpt90 egpt91
 egpt92 egpt93 egpt94 egpt95 egpt96 egpt97
using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)
netto(-3,-2,-1,0,1,2,3,4,5) keep(gebjahr sex);
#delimit cr

* Zur Arbeitserleichterung
capture program drop umben
program define umben
        version 6.0
        local i 84
        while "`1'" ~= "" {
                ren `1'netto netto`i'
                local i = `i' + 1
                mac shift
        }
end

umben a b c d e f g h i j k l m n

save eigen3, replace

exit