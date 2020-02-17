// Merge Election System to Metadata
// ---------------------------------
// kohler@wzb.eu

version 10
clear

// Input Data from International IDEA
input str2 iso3166 str11 es 
AT "List PR"  
BE "List PR"  
BG "List PR"  
CH "List PR"  
CY "List PR"  
CZ "List PR"  
DE "MMP"      
DK "List PR"  
EE "List PR"  
ES "List PR"  
FI "List PR"  
FR "TRS"      
GB "FPTP"     
GR "List PR"  
HU "MMP"      
IE "STV"      
IT "List PR"  
LT "Parallel" 
LU "List PR"  
LV "List PR"  
MT "STV"      
NL "List PR"  
NO "List PR"  
PL "List PR"  
PT "List PR"  
RO "List PR"  
SE "List PR"  
SI "List PR"  
SK "List PR"  
US "FPTP"     
end

// Prepare for Merging
label variable es "Election System"
sort iso3166
tempfile using
save `using'

// Merge to Metadata
use elections
sort iso3166
merge iso3166 using `using'
assert _merge==3
drop _merge

// Save new data
compress
save elections2, replace
exit



