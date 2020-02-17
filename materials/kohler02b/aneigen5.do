* Fehlerscheck 2 in EGP nach crkorr4: Nochmal aneigen4
version 6.0
clear
set memory 60m

use eigen5, clear

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
                        capture assert `1'`i' < -2 if netto`i' == 1
                        if _rc ~= 0 {
                                quietly count if `1'`i' < -2 & netto`i' == 1
                                di r(N) "Unzulaessige Werte in `1'`i'"
                                list persnr if `1'`i' < -2 & netto`i' == 1
                        }
                        mac shift
                }
                local i = `i' + 1
        }
end

nonmatch egpb egph egpp egpt
exit

Bemerkung: Korrektur in creigen1.do


