* Label f"ur bsth in allen Datens"atzen vergessen, -> Korrektur

version 6.0
clear
set memory 60m
capture program drop korr2
program define korr2
local i 84
while "`1'" ~= "" {
        use $soepdir/`1'peigen
        label val bsth`i' bst
        save, replace
        local i = `i'+1
        mac shift
}
end

korr2 a b c d e f g h i j k l m n

exit

