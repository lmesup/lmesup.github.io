* Stata-commands to read and label ../../Website/kri_ltw.dat

infile /*
*/str2 iso3166   str10 eldatestr str13 Wparty    str9 Rparty    float turnout   float L         float kri      /*
*/float Rp        float fdabs     float fdrel     str17 terms     using ../../Website/kri_ltw.dat

label variable iso3166 "Bundesland" 
label variable eldatestr "Election date (string)" 
label variable Wparty "Name of winner" 
label variable Rparty "Name of runner up" 
label variable turnout "Valid votes/electoral" 
label variable L "Leverage" 
label variable kri "Vote share required to reach tipping point (Kohler/Rose-Index)" 
label variable Rp "Vote share actual" 
label variable fdabs "Vote share required minus vote share actual" 
label variable fdrel "Difference in percent of actual vote share" 
label variable terms "Proper words for possiblity of cange" 