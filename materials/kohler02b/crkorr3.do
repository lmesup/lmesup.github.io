* Korrektur der fehlerhaften Nonmatchs aus xxxx.do

version 6.0
clear
set memory 60m
capture program drop korr2
program define korr2
local i 84
while "`1'" ~= "" {
        use $soepdir/`1'peigen

        * A: Noch nicht zugewiesen
        * ------------------------

       replace egpb`i' =  2 if bstb`i' == 51 & iscb`i' == 51
       replace egph`i' =  2 if bsth`i' == 51 & isch`i' == 51
       replace egpp`i' =  2 if bstp`i' == 51 & iscp`i' == 51
       replace egpt`i' =  2 if bstt`i' == 51 & isct`i' == 51
       replace egpb`i' = -1 if bstb`i' == -1 & iscb`i' == 75
       replace egph`i' = -1 if bsth`i' == -1 & isch`i' == 75
       replace egpp`i' = -1 if bstp`i' == -1 & iscp`i' == 75
       replace egpt`i' = -1 if bstt`i' == -1 & isct`i' == 75
       replace egpb`i' = -1 if bstb`i' == -1 & iscb`i' == 180
       replace egph`i' = -1 if bsth`i' == -1 & isch`i' == 180
       replace egpp`i' = -1 if bstp`i' == -1 & iscp`i' == 180
       replace egpt`i' = -1 if bstt`i' == -1 & isct`i' == 180
       replace egpb`i' = -7 if bstb`i' == 52 & iscb`i' == 901
       replace egph`i' = -7 if bsth`i' == 52 & isch`i' == 901
       replace egpp`i' = -7 if bstp`i' == 52 & iscp`i' == 901
       replace egpt`i' = -7 if bstt`i' == 52 & isct`i' == 901


        * B: Unzulaessige Missings in egpt
        * ---------------------------------

        replace egpt = -2 if nie == 1 & aus == 0 & egpt == .

        * C: Unzul"assigen Missings in egp aufgrund isco 0 bzw. -3
        * --------------------------------------------------------
        * Zuordnungsregel wie in cregp1.do: Zuweisung zur
        * Modalkategorie, falls 1984 mit mehr als 70 %  besetzt
        *Befragter
        replace egpb = -1 if (iscb`i' == 0 | iscb`i'==-3) & bstb`i' == -1
        replace egpb = -1 if (iscb`i' == 0 | iscb`i'==-3) & bstb`i' == 41
        replace egpb = -1 if (iscb`i' == 0 | iscb`i'==-3) & bstb`i' == 51
        replace egpb = -1 if (iscb`i' == 0 | iscb`i'==-3) & bstb`i' == 52
        replace egpb = -1 if (iscb`i' == 0 | iscb`i'==-3) & bstb`i' == 53
        * HV
        replace egph = -1 if (isch == 0 | isch==-3) & bsth == -1
        replace egph = -1 if (isch == 0 | isch==-3) & bsth == 41
        replace egph = -1 if (isch == 0 | isch==-3) & bsth == 51
        replace egph = -1 if (isch == 0 | isch==-3) & bsth == 52
        replace egph = -1 if (isch == 0 | isch==-3) & bsth == 53
        * Terwey
        replace egpt = -1 if (isct == 0 | isct==-3) & bstt == -1
        replace egpt = -1 if (isct == 0 | isct==-3) & bstt == 41
        replace egpt = -1 if (isct == 0 | isct==-3) & bstt == 51
        replace egpt = -1 if (isct == 0 | isct==-3) & bstt == 52
        replace egpt = -1 if (isct == 0 | isct==-3) & bstt == 53
        * Pappi
        replace egpp = -1 if (iscp`i'== 0 | iscp`i'==-3) & bstp`i' == -1
        replace egpp = -1 if (iscp`i' == 0 | iscp`i'==-3) & bstp`i' == 41
        replace egpp = -1 if (iscp`i' == 0 | iscp`i'==-3) & bstp`i' == 51
        replace egpp = -1 if (iscp`i' == 0 | iscp`i'==-3) & bstp`i' == 52
        replace egpp = -1 if (iscp`i' == 0 | iscp`i'==-3) & bstp`i' == 53
        save, replace
        local i = `i'+1
        mac shift
}
end

korr2 a b c d e f g h i j k l m n
exit