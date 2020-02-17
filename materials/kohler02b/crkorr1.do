* Korrektur der fehlerhaften Nonmatchs aus aneigen1.do

version 6.0
clear
set memory 60m
capture program drop korr2
program define korr2
local i 84
while "`1'" ~= "" {
        use $soepdir/`1'peigen

        * A: Unzulaessige Missings bei "Terwey"
        * -------------------------------------
        * (Alle nicht und nie erwerbst"atige in Ausbildung)

        *0) geschiedener "HVors"  -> HV Beruf
        replace bstt = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==0
        replace isct = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==0

        *1) geschiedener "Lebenpartner"  -> HV Beruf
        replace bstt = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==2
        replace isct = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==2

        *2) geschiedenes "Kind"  -> HV Beruf
        replace bstt = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==3
        replace isct = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==3

        *2a) geschieden Geschwister -> -2
        replace bstt = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==8
        replace isct = bsth if est==7 & nie==1 & aus==1 & fam==2 & hst==8

        *3) ledige HVors.  -> HV Beruf
        replace bstt = bsth if est==7 & nie==1 & aus==1 & fam==3 & hst==0
        replace isct = bsth if est==7 & nie==1 & aus==1 & fam==3 & hst==0

        *4) ledige Lebenspartner  -> HV Beruf
        replace bstt = bsth if est==7 & nie == 1 & aus==1 & fam==3 & hst == 2
        replace isct = bsth if est==7 & nie == 1 & aus==1 & fam==3 & hst == 2

        *5) ledige Geschwister -> HV Beruf
        replace bstt = bsth if est==7 & nie == 1 & aus==1 & fam==3 & hst == 8
        replace isct = bsth if est==7 & nie == 1 & aus==1 & fam==3 & hst == 8

        *6) ledige Sonstige Verwandte -> HV Beruf
        replace bstt = bsth if est==7 & nie == 1 & aus==1 & fam==3 & hst == 10
        replace isct = bsth if est==7 & nie == 1 & aus==1 & fam==3 & hst == 10

        *7) ledige Nicht Verwandte  -> -2
        replace bstt = -2 if est==7 & nie == 1 & aus==1 & fam==3 & hst == 11
        replace isct = -2 if est==7 & nie == 1 & aus==1 & fam==3 & hst == 11

        *7aa) getrennt Lebende HVors -> -2
        replace bstt = -2 if est==7 & nie == 1 & aus==1 & fam==4 & hst == 0
        replace isct = -2 if est==7 & nie == 1 & aus==1 & fam==4 & hst == 0

        *7a) getrennt Lebende Lebenspartner -> -2
        replace bstt = -2 if est==7 & nie == 1 & aus==1 & fam==4 & hst == 2
        replace isct = -2 if est==7 & nie == 1 & aus==1 & fam==4 & hst == 2

        *8) Lebenspartner im Heimatland, Kind (1 Fall) -> -2
        replace bstt = -2 if est==7 & nie == 1 & aus==1 & fam==6 & hst == 3
        replace isct = -2 if est==7 & nie == 1 & aus==1 & fam==6 & hst == 3

        * (In Ausbildung unbekannt)

        *9) -> - 2
        replace bstt = -2 if est==7 & nie == 1 & aus== -1 & fam==3 & hst == 2
        replace isct = -2 if est==7 & nie == 1 & aus== -1 & fam==3 & hst == 2
        save, replace
        local i = `i'+1
        mac shift
}
end

korr2 a b c d e f g h i j k l m n

use $soepdir/gpeigen, replace
replace aus = -2 if aus == .
replace bstb90 = -2 if aus == -2
replace bsth90 = -2 if aus == -2
replace bstt90 = -2 if aus == -2
replace bstp90 = -2 if aus == -2
replace iscb90 = -2 if aus == -2
replace isch90 = -2 if aus == -2
replace isct90 = -2 if aus == -2
replace iscp90 = -2 if aus == -2
replace hhein90 = -2 if hhein90 == .
replace ein90 = -2 if ein90 == .
save, replace

use $soepdir/hpeigen, replace
replace ein91 = -2 if ein91 == .

* Missings bei Pappi wegen Frauen mit unbek. Familienstand -> HV Beruf
* (13 Faelle)
replace bstp9 = bsth9 if bstp9 ==. & fam9 == -1
replace iscp9 = isch9 if iscp9 ==. & fam9 == -1
save, replace

use $soepdir/ipeigen, replace
* Missings bei Pappi wegen Frauen mit unbek. Familienstand -> HV Beruf
* (12 Faelle)
replace bstp9 = bsth9 if bstp9 ==. & fam9 == -1
replace iscp9 = isch9 if iscp9 ==. & fam9 == -1
save, replace

use $soepdir/jpeigen, replace
* Missings bei Pappi wegen Frauen mit unbek. Familienstand -> HV Beruf
* (4 Faelle)
replace bstp9 = bsth9 if bstp9 ==. & fam9 == -1
replace iscp9 = isch9 if iscp9 ==. & fam9 == -1
* Ein Fall mit Missing bei hheink -> -1
replace hhein = -1 if hhein ==.
save, replace

use $soepdir/kpeigen, replace
* (3 Faelle)
* Missings bei Pappi wegen Frauen mit unbek. Familienstand -> HV Beruf
replace bstp9 = bsth9 if bstp9 ==. & fam9 == -1
replace iscp9 = isch9 if iscp9 ==. & fam9 == -1
* Ein Fall mit Missing bei hheink -> -1
replace hhein = -1 if hhein ==.
save, replace

use $soepdir/lpeigen, replace
* (5 Faelle)
* Missings bei Pappi wegen Frauen mit unbek. Familienstand -> HV Beruf
replace bstp9 = bsth9 if bstp9 ==. & fam9 == -1
replace iscp9 = isch9 if iscp9 ==. & fam9 == -1
* 2 Faelle mit Missing bei hheink -> -1
replace hhein = -1 if hhein ==.
save, replace

use $soepdir/mpeigen, replace
* (2 Faelle)
* Missings bei Pappi wegen Frauen mit unbek. Familienstand -> HV Beruf
replace bstp9 = bsth9 if bstp9 ==. & fam9 == -1
replace iscp9 = isch9 if iscp9 ==. & fam9 == -1
* 1 Fall mit Missing bei hheink -> -1
replace hhein = -1 if hhein ==.
save, replace

exit

Anzahl der Korrekturen im Program korr1
    A0 A1  A2 A2a  A3  A4  A5  A6  A7 A7aa A7a  A8  A9
84:  -  1   1   -  40   3   2   1  14    -   -   1   0
85:  1  -   1   1  31   1   1   -   7    -   1   0   1
86:  -  -   -   -  27   -   2   -   6    -   -   -   -
87:  -  -   -   -  19   -   2   -   1    -   -   -   -
88:  1  -   -   -  11   -   1   -   1    -   -   -   -
89:  -  -   -   -   8   -   -   -   -    -   -   -   -
90:  -  -   -   -  12   -   -   -   -    -   -   -   -
91:  -  -   -   -   6   -   -   -   -    -   -   -   -
92:  -  -   -   -   4   -   -   -   -    -   -   -   -
93:  -  -   -   -   3   -   -   -   -    -   -   -   -
94:  -  -   -   -   3   -   -   -   -    -   -   -   -
95:  -  -   -   -   2   -   -   -   -    -   -   -   -
96:  -  -   -   -   -   -   -   -   -    -   -   -   -
97:  -  -   -   -   -   -   -   -   -    -   -   -   -
