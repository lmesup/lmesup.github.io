* SPSS-syntax to read and label ../../Website/kri_btw.dat

DATA LIST FILE = "../../Website/kri_btw.dat" FREE / 
area      eldatestr year      Wparty    Rparty    turnout   L        
kri       Rp        fdabs     fdrel     terms      .
VARIABLE LABELS
AREA "Area area" 
ELDATESTR "Election date (string)" 
YEAR "" 
WPARTY "Name of winner" 
RPARTY "Name of runner up" 
TURNOUT "Valid votes/electoral" 
L "Leverage" 
KRI "Vote share required to reach tipping point (Kohler/Rose-Index)" 
RP "Vote share actual" 
FDABS "Vote share required minus vote share actual" 
FDREL "Difference in percent of actual vote share" 
TERMS "Proper words for possiblity of cange" .
VALUE LABELS.
exe.
