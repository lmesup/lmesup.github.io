insheet year state vap vep votes using "~/data/agg/Turnout 1980-2006.csv"

gen turnout = 100*(votes/vep)
drop if strpos(state,"United States")>0

keep if mod(year,4)==0

sort state
tempfile turnout
save `turnout'







