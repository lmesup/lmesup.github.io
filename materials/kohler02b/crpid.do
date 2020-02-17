* Parteiidentifikation
version 6.0
set more off
clear
set memory 60m


* Retrival
* --------
#delimit ;
mkdat
ap5601 bp7901 cp7901 dp8801 ep7701 fp9301 gp8501 hp9001 ip9001 jp9001 kp9201
       lp9801 mp8401 np9401
ap5602 bp7902 cp7902 dp8802 ep7702 fp9302 gp8502 hp9002 ip9002 jp9002 kp9202
       lp9802 mp8402 np9402
ap5603 bp7903 cp7903 dp8803 ep7703 fp9303 gp8503 hp9003 ip9003 jp9003 kp9203
       lp9803 mp8403 np9403
using $soepdir, netto(-3,-2,-1,0,1,2,3,4,5) files(p)
waves(a b c d e f g h i j k l m n) ;
#delimit cr

lab def pid 1 "Keine" 2 "SPD" 3 "CDU/CSU" 4 "FDP" 5 "B90/Gr" /*
*/ 6 "Andere P"

* Wellen a - g
capture program drop pid
    program define pid
        local i 84
        while "`1'" ~= "" {
            gen pid`i' = 1 if `1'01 == 2
            replace pid`i' = 2 if `1'02==1
            replace pid`i' = 3 if `1'02>=2 & `1'02<=4
            replace pid`i' = 4 if `1'02==5
            replace pid`i' = 5 if `1'02==6
            replace pid`i' = 6 if `1'02==7 | `1'02==8
            lab var pid`i' "Parteiidentifikation"
            lab val pid`i' pid
            mac shift
            local i = `i' + 1
        }
    end
pid ap56 bp79 cp79 dp88 ep77 fp93 gp85

* Welle h
gen pid91 = 1 if hp9001 == 2
replace pid91 = 2 if hp9002==1
replace pid91 = 3 if hp9002==2
replace pid91 = 4 if hp9002==3
replace pid91 = 5 if hp9002==4 | hp9002==5
replace pid91 = 6 if hp9002>=6 & hp9002<=8
lab var pid91 "Parteiidentifikation"
lab val pid91 pid

* Wellen i,j,
capture program drop pid
    program define pid
        local i 92
        while "`1'" ~= "" {
            gen pid`i' = 1 if `1'01 == 2
            replace pid`i' = 2 if `1'02==1
            replace pid`i' = 3 if `1'02>=2 & `1'02<=3
            replace pid`i' = 4 if `1'02==4
            replace pid`i' = 5 if `1'02==5 | `1'02==6
            replace pid`i' = 6 if `1'02==7 | `1'02==8 | `1'02==9
            lab var pid`i' "Parteiidentifikation"
            lab val pid`i' pid
            mac shift
            local i = `i' + 1
        }
    end
pid ip90 jp90

* Wellen k, l, m, n
capture program drop pid
    program define pid
        local i 94
        while "`1'" ~= "" {
            gen pid`i' = 1 if `1'01 == 2
            replace pid`i' = 2 if `1'02==1
            replace pid`i' = 3 if `1'02>=2 & `1'02<=3
            replace pid`i' = 4 if `1'02==4
            replace pid`i' = 5 if `1'02==5
            replace pid`i' = 6 if `1'02>=6 & `1'02<=8
            lab var pid`i' "Parteiidentifikation"
            lab val pid`i' pid
            mac shift
            local i = `i' + 1
        }
    end
pid kp92 lp98 mp84 np94

* Speichern
* ---------

save temp, replace

capture program drop svdat
program define svdat
    local i 84
    while `i'<=97 {
        use hhnr `1'hhnr `1'netto persnr pid`i' if `1'netto == 1 /*
        */ using temp, clear
        ren `1'hhnr hhnrakt
        sort hhnr hhnrakt persnr
        save 11, replace
        use $soepdir/`1'peigen
        sort hhnr hhnrakt persnr
        capture drop pid`i'
        merge hhnr hhnrakt persnr using 11
        assert _merge==3
        drop `1'netto _merge
        compress
        sort hhnr hhnrakt persnr
        order hhnr hhnrakt persnr bul`i' hst`i' fam`i' bil`i' bbil`i' /*
        */ bdauer`i' est`i' nie`i' bstb`i' iscb`i' bsth`i' isch`i' /*
        */ bstp`i' iscp`i' bstt`i' isct`i' bstbex`i' iscbex`i' bstpar`i' /*
        */ iscpar`i' bstvpa`i' iscvpa`i' aus`i' hhein`i' ein`i' /*
        */ egpb`i' egph`i' egpp`i' egpt`i' rl`i' pid`i'
        save $soepdir/`1'peigen, replace
        local i = `i'+1
        mac shift
    }
end
svdat a b c d e f g h i j k l m n

erase temp.dta
erase 11.dta

exit
