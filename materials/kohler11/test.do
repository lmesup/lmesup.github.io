use /tmp/St11559.00002u, clear
collapse (mean) Phat UB LB SE, by(zanr eldate categ)
gen party3 = "SPD" if categ==1
replace party3 = "CDU/CSU" if categ==2
replace party3 = "Oth" if categ==3
sort eldate party3
tempfile x
save `x'

use elections if area == "DE"
gen party3 = "CDU/CSU" if party == "CDU/CSU"
replace party3 = "SPD" if party == "SPD"
replace party3 = "Oth" if party3 == ""
sort eldate party3
merge eldate party3 using `x'

// Prhatbar for Other Parties
gen other = party3=="Oth"
by eldate other, sort: gen sumother=sum(ppartyvotes) if other
by eldate other, sort: gen ppartyrescale=ppartyvotes/sumother[_N] if other
replace Phat = ppartyrescale * Phat if other
drop other sumother ppartyrescale 

// Graph Prhatbar and observed Proportions
// ---------------------------------------

gen str8 party6 = party if inlist(party,"SPD","CDU/CSU","FDP")
replace party6 = "Linke/PDS" if inlist(party,"Linke","PDS","WASG")
replace party6 = "B90/Gr." if inlist(party,"B90","Gruene","B90/Gr")
replace party6 = "Other" if party6 == ""

egen trueperc = sum(ppartyvotes), by(eldate party6)

egen cfacperc = sum(Phat), by(eldate party6)
replace UB = cfacperc + 1.96*SE if party3=="Oth"
replace LB = cfacperc - 1.96*SE if party3=="Oth"

gen diff = (cfacperc*100)- trueperc
gen diffUB = (UB*100) - trueperc
gen diffLB = (LB*100) -  trueperc

lab def party6 1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "B90/Gr."  /// 
5 "Linke/PDS" 6 "Other"
encode party6, gen(party6num) label(party6)

format %tdYY eldate
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || connected diff eldate, ms(O) mcolor(black) 	          	///
  || , by(party6num, legend(off) note(""))  /// 
xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid))
graph export anmpred_1.eps, replace



