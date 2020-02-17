local p1 = 33.46859 * .81
local p2 = 26.15626 * .81
local p3 = (100 - 26.15626 - 33.46859) * .81

tempname new
tempfile newfile
postfile `new' share p1 p2 p3 using `newfile' 

forvalues i = 1/1000 {
	local share2 = uniform()
	local share1 = (1-`share2')/6
	local share3 = (1-`share2')*5/6
	
	post `new' (`share2') ///
	(`p1' + `share1' * 19) (`p2' + `share2' * 19) (`p3' + `share3' * 19)
}

postclose `new'
use `newfile', clear

line p1 p2 p3 share, lcolor(black..) lpattern(solid dash dot) sort legend(row(1))




	







