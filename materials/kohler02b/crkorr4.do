* Fehler in crcorr3.do -> hier korrigiert

version 6.0
clear
set memory 60m
capture program drop korr2
program define korr2
local i 84
while "`1'" ~= "" {
        use $soepdir/`1'peigen
        replace egpb`i' =  7 if bstb`i' == 52 & iscb`i' == 901
        replace egph`i' =  7 if bsth`i' == 52 & isch`i' == 901
        replace egpp`i' =  7 if bstp`i' == 52 & iscp`i' == 901
        replace egpt`i' =  7 if bstt`i' == 52 & isct`i' == 901
        save, replace
        local i = `i'+1
        mac shift
}
end

korr2 a b c d e f g h i j k l m n

use $soepdir/npeigen

replace egpb97 =  3 if bstb97 == 52 & iscb97 == 592
replace egph97 =  3 if bsth97 == 52 & isch97 == 592
replace egpp97 =  3 if bstp97 == 52 & iscp97 == 592
replace egpt97 =  3 if bstt97 == 52 & isct97 == 592
save, replace


exit