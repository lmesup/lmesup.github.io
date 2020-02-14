* Stata-commands to read and label ../../Website/kri_btw.dat

infile /*
*/str2 area      str9 eldatestr int year      str7 Wparty    str7 Rparty    float turnout   float L        /*
*/float kri       float Rp        float fdabs     float fdrel     str17 terms     using ../../Website/kri_btw.dat

label variable area "Area area" 
label variable eldatestr "Election date (string)" 
label variable year "" 
label variable Wparty "Name of winner" 
label variable Rparty "Name of runner up" 
label variable turnout "Valid votes/electoral" 
label variable L "Leverage" 
label variable kri "Vote share required to reach tipping point (Kohler/Rose-Index)" 
label variable Rp "Vote share actual" 
label variable fdabs "Vote share required minus vote share actual" 
label variable fdrel "Difference in percent of actual vote share" 
label variable terms "Proper words for possiblity of cange" 