* Fehlerscheck 1 in den *peigen Datens"atzen: Nonmatchs korrekt?
version 6.0
clear
set memory 60m

use eigen1, clear

* Nonmatchs
* ---------

capture program drop nonmatch
program define nonmatch
        version 6.0
        local i 84
        while `i' <=97 {
                tokenize `0'
                while "`1'" ~= "" {
                        capture assert `1'`i' == . if netto`i' ~= 1
                        if _rc ~= 0 {
                                quietly count if `1'`i' ~= . & netto`i' ~= 1
                                di r(N) "Unzulaessige Werte in `1'`i'"
                                list persnr if `1'`i' ~= . & netto`i' ~= 1
                        }
                        capture assert `1'`i' ~= . if netto`i' == 1
                        if _rc ~= 0 {
                                quietly count if `1'`i' == . & netto`i' == 1
                                di r(N) "Unzulaessige Missings in `1'`i'"
                                list persnr if `1'`i' == . & netto`i' == 1
                        }
                        mac shift
                }
                local i = `i' + 1
        }
end

nonmatch bil bbil bdauer est nie bstb iscb bsth isch bstp iscp bstt isct /*
*/ aus hhein ein
exit

Bemerkung: Korrektur in crkorr2.do


* Verteilungen
exit