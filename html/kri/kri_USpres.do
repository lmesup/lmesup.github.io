* Stata-commands to read and label ../../Website/kri_USpres.dat

infile /*
*/str20 area      str10 eldatestr str7 Wparty    str7 Rparty    float turnout   float L         float kri      /*
*/float Rp        float fdabs     float fdrel     using ../../Website/kri_USpres.dat

label variable area "" 
label variable eldatestr "eldatestr" 
label variable Wparty "Name of winner" 
label variable Rparty "Name of runner up" 
label variable turnout "Valid votes/electoral" 
label variable L "Leverage" 
label variable kri "Vote share required to reach tipping point (Kohler/Rose-Index)" 
label variable Rp "Vote share actual" 
label variable fdabs "Vote share required minus vote share actual" 
label variable fdrel "Difference in percent of actual vote share" 
label define _merge 1 `"master only (1)"', modify
label define _merge 2 `"using only (2)"', modify
label define _merge 3 `"matched (3)"', modify
label define _merge 4 `"missing updated (4)"', modify
label define _merge 5 `"nonmissing conflict (5)"', modify