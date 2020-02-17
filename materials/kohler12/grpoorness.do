// Proportion or Persons being poor
// kohler@wzb.eu

cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m
set scheme s1mono


// Official Data
// --------------
// Source DE: 1981-1994 + 2004: LIS; 1995-2009: Eurostat
// Source US: 

input wave str2 cntry poor
	1981 DE 10.579 
	1983 DE 11.688 
	1984 DE 14.057 
	1989 DE 11.391 
	1994 DE 13.558 
	1995 DE 15 
	1996 DE 14 
	1997 DE 12 
	1998 DE 11 
	1999 DE 11 
	2000 DE 10 
	2001 DE 11 
	2003 DE 13.6 
	2004 DE 14.342
	2005 DE 12.2 
	2006 DE 12.5 
	2007 DE 15.2 
	2008 DE 15.2 
	2009 DE 15.5 
	2009 US 14.3 
	2008 US 13.2 
	2007 US 12.5 
	2006 US 12.3 
	2005 US 12.6 
	2004 US 12.7 
	2003 US 12.5 
	2002 US 12.1 
	2001 US 11.7 
	2000 US 11.3 
	1999 US 11.9 
	1998 US 12.7 
	1997 US 13.3 
	1996 US 13.7 
	1995 US 13.8 
	1994 US 14.5 
	1993 US 15.1 
	1992 US 14.8 
	1991 US 14.2 
	1990 US 13.5 
	1989 US 12.8 
	1988 US 13.0 
	1987 US 13.4 
	1986 US 13.6 
	1985 US 14.0 
	1984 US 14.4 
	1983 US 15.2 
	1982 US 15.0 
	1981 US 14.0 
	1980 US 13.0 
end
gen source = "Amtliche Statistik"

tempfile official
save `official'

// Ourdata
// --------

// PSID and GSOEP als Cross-Sections
use DE if wave < 2009, replace  
collapse (mean) poor (sd) sd = poor (count) n = poor [aweight=weight], by(wave)
gen source = "Prozent unter 60% Medianeinkommen"
gen cntry="DE"
tempfile DE
save `DE'

use US, replace
collapse (mean) poor (sd) sd = poor (count) n = poor [aweight=weight], by(wave)
gen source = "Prozent unter 60% Medianeinkommen"
gen cntry="US"
tempfile US
save `US'

// Merge files together
// ---------------------

use `official', clear
append using `DE'
append using `US'

// Produce Figures
// ---------------

gen ub = poor + 1.96*sd/sqrt(n)
gen lb = poor - 1.96*sd/sqrt(n)

// Harmonize Scale
replace poor = poor*100 if source != "Amtliche Statistik"
replace ub = 100*ub if source != "Amtliche Statistik"
replace lb = 100*lb if source != "Amtliche Statistik"

// Our line
graph twoway 						 	       ///
  || rarea ub lb wave 					/// 
  if  cntry=="US" , sort color(gs8) ///
  || rarea ub lb wave 					/// 
  if  cntry=="DE" , sort color(gs8) ///
  || line poor wave if cntry=="US" ///
  , sort lcolor(black) lpattern(dash) lwidth(*1.5)            ///
  || line poor wave if cntry=="DE"                ///
  , sort lcolor(black) lpattern(solid) lwidth(*1.5)            ///
  || , ytitle("Anteil Armer (in %)") 		       ///
  by(source, note("") rows(2)) ///
  legend(order(4 "Deutschland" 3 "U.S.A.") rows(1)) ///
  xtitle("") ylabel(5(5)25, grid) xlabel(1980(5)2010)

graph export grpoorness.eps, replace
if c(os)=="Unix" {
	!epstopdf grpoorness.eps
}


exit

