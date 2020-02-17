* Links--Rechts--Schema aus PID
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


* Erzeugung Rechts--Links--Schema
* -------------------------------

* Wellen a - g
capture program drop rl
    program define rl
        local i 84
        while "`1'" ~= "" {
            * Die Linken
            gen rl`i'  = (6-`1'03)+6 if (`1'02==1 | `1'02==6) & `1'03 > 0
            * Die Rechten
            replace rl`i' = `1'03 if `1'02>=2 & `1'02<=5 & `1'03 > 0
            * Keine PID
            replace rl`i'= 6 if `1'01==2
            replace rl`i'=-1 if rl`i'==. & `1'01~=.
            local i = `i'+1
            mac shift
        }
    end
rl ap56 bp79 cp79 dp88 ep77 fp93 gp85

* Welle h
* Die Linken
gen rl91 = (6-hp9003)+6 if (hp9002==1 | hp9002==4 | hp9002==5) /*
    */ & hp9003 > 0
* Die Rechten
replace rl91 = hp9003 if (hp9002==2 | hp9002==3) & hp9003 > 0
* Keine PID
replace rl91 = 6 if hp9001==2
replace rl91 =-1 if hp9001~=. & rl91==.

* Wellen i,j,
capture program drop rl
    program define rl
        local i 92
        while "`1'" ~= "" {
            * Die Linken
            gen rl`i' = (6-`1'03)+6 if (`1'02==1 | `1'02==5 | `1'02==6) /*
            */ & `1'03 > 0
            * Die Rechten
            replace rl`i' = `1'03 if `1'02>=2 & `1'02<=4 & `1'03 > 0
            * Keine PID
            replace rl`i' = 6 if `1'01==2
            replace rl`i' =-1 if rl`i'==. & `1'01~=.
            local i = `i'+1
            mac shift
           }
    end
rl ip90 jp90

* Welle k, l, m, n
capture program drop rl
    program define rl
        local i 94
        while "`1'" ~= "" {
            * Die Linken
            gen rl`i' = (6-`1'03)+6 if (`1'02==1 | `1'02==5) /*
            */ & `1'03 > 0
            * Die Rechten
            replace rl`i' = `1'03 if `1'02>=2 & `1'02<=4 & `1'03 > 0
            * Keine PID
            replace rl`i' = 6 if `1'01==2
            replace rl`i'=-1 if rl`i'==. & `1'01~=.
            local i = `i'+1
            mac shift
        }
    end
rl kp92 lp98 mp84 np94


* Labeln
* ------

capture program drop labeln
    program define labeln
        local i 84
        while `i' <= 97 {
            lab var rl`i' "Rechts-Links `i'"
            lab val rl`i' lr
            local i = `i'+1
        }
    end
labeln
lab def rl 1 "Links" 6 "Mitte" 11 "Rechts"

* Speichern
* ---------

save temp, replace

capture program drop svdat
program define svdat
    local i 84
    while `i'<=97 {
        use hhnr `1'hhnr `1'netto persnr rl`i' if `1'netto == 1 /*
        */ using temp, clear
        ren `1'hhnr hhnrakt
        sort hhnr hhnrakt persnr
        save 11, replace
        use $soepdir/`1'peigen
        sort hhnr hhnrakt persnr
        capture drop rl`i'
        merge hhnr hhnrakt persnr using 11
        assert _merge==3
        drop `1'netto _merge
        compress
        sort hhnr hhnrakt persnr
        order hhnr hhnrakt persnr bul`i' hst`i' fam`i' bil`i' bbil`i' /*
        */ bdauer`i' est`i' nie`i' bstb`i' iscb`i' bsth`i' isch`i' /*
        */ bstp`i' iscp`i' bstt`i' isct`i' bstbex`i' iscbex`i' bstpar`i' /*
        */ iscpar`i' bstvpa`i' iscvpa`i' aus`i' hhein`i' ein`i' /*
        */ egpb`i' egph`i' egpp`i' egpt`i' rl`i'
        save $soepdir/`1'peigen, replace
        local i = `i'+1
        mac shift
    }
end
svdat a b c d e f g h i j k l m n

erase temp.dta
erase 11.dta

exit
