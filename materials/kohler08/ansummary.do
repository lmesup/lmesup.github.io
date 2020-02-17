	// Table for summary
version 9
	clear

	input str10 survey document method extern intern
	"ESS 2002"     3.9   1.8  1.33   1.28  
	"EVS 1999"     3.4   0.6  1.02   1.03  
	"EQLS 2003"    3.0   1.5  0.21   0.61  
	"ISSP 2002"    2.3   1.0  0.54   1.03  
	"EB 62.1"      2.0   0.2  0.48   0.61  
	"Euromodule"   1.4   0.1  0.86   0.96  
end

	// rescale
	sum document, meanonly
	gen documentr = document/4
	sum method, meanonly
	gen methodr = method/3
	sum extern, meanonly
	gen externr = extern/2
	sum intern, meanonly
	gen internr = intern/2


	gen sum = documentr + methodr + externr + internr
	format document method extern intern sum  %03.2f

	gsort - sum
	listtex survey document method extern intern sum  using ansummary.tex, rstyle(tabular) replace


	exit
	
