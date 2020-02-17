use ess04

corr voter polint pi [aw=nweight]

tempfile temp
postfile myfile str2 cntry  votpolint votpi polintpi using `temp', replace
levelsof cntry, local(K)
foreach k of local K  {
	corr voter polint [aw=nweight] if cntry == "`k'"
	local votpolint = r(rho)
	corr voter pi [aw=nweight] if cntry == "`k'"
	local votpi = r(rho)
	corr polint pi [aw=nweight] if cntry == "`k'"
	local polintpi = r(rho)
	post myfile ("`k'") (`votpolint'*100) (`votpi'*100) (`polintpi'*100)
}

postclose myfile

use `temp'
format votpolint votpi polintpi %3.1f

list, noobs clean

