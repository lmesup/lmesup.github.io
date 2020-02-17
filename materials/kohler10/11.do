local p1 = uniform()
local p2 = uniform()
local L = (`p1'-`p2')/(`p1'-`p2'+1)

di "Big Party has " `p1'*(1-`L')
di "Small Party has "`p2'*(1-`L') + `L' 



	







