* Stata-commands to read and label ../../Website/kri_eed.dat

infile /*
*/str2 iso3166   str15 ctrname   int eldate    int year      str44 Wparty    str34 Rparty    float turnout  /*
*/float L         float kri       float Rp        float fdabs     float fdrel     str17 terms     using ../../Website/kri_eed.dat

label variable iso3166 "Country ISO code" 
label variable ctrname "Country name" 
label variable eldate "Election date" 
label variable year "Election year" 
label variable Wparty "Name of winner" 
label variable Rparty "Name of runner up" 
label variable turnout "Valid votes/electoral" 
label variable L "Leverage" 
label variable kri "Vote share required to reach tipping point (Kohler/Rose-Index)" 
label variable Rp "Vote share actual" 
label variable fdabs "Vote share required minus vote share actual" 
label variable fdrel "Difference in percent of actual vote share" 
label variable terms "Proper words for possiblity of cange" 