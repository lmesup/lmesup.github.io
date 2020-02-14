* SPSS-syntax to read and label ../../Website/kri_eed.dat

DATA LIST FILE = "../../Website/kri_eed.dat" FREE / 
iso3166   ctrname   eldate    year      Wparty    Rparty    turnout  
L         kri       Rp        fdabs     fdrel     terms      .
VARIABLE LABELS
ISO3166 "Country ISO code" 
CTRNAME "Country name" 
ELDATE "Election date" 
YEAR "Election year" 
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
