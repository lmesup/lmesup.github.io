// Merge State and Federal Election Data
// -------------------------------------
// kohler@wzb.eu

version 10
set more off

// Landtag
// =======

do crltwseats
do crltw
sort area eldate party
merge area eldate party using ltwseats
drop _*
tempfile x
save `x'


// Bundestag
// =========

do crbtw

// Parliament size
// ---------------

gen int size = 400 if year(eldate)==1949 & area=="DE"
replace size = 484 if year(eldate)==1953 & area=="DE"
replace size = 494 if year(eldate)>=1957 & year(eldate) <1965 & area=="DE"
replace size = 496 if year(eldate)>=1965 & year(eldate) <= 1987 & area=="DE"
replace size = 656 if year(eldate)>=1990 & year(eldate) <= 1998 & area=="DE"
replace size = 596 if year(eldate)==2002 & area=="DE" // Reduced size because of direct mandates for PDS
replace size = 598 if year(eldate)==2005  & area=="DE"| year(eldate)==2009 & area=="DE"

// Method
// ------

gen appmethod = "jefferson" if inrange(year(eldate),1949,1983)
replace appmethod = "hamilton" if inrange(year(eldate),1987,2005) 
replace appmethod = "webster" if year(eldate)==2009

// Exception
// ---------

gen str20 grundmandat = `""Zentrum","DP","BP","WAV","SSW","DKP/DRP""'  ///
  if year(eldate)==1949
replace grundmandat = `""Zentrum","DP","GB/BHE","FDP""' if year(eldate)==1953
replace grundmandat = `""DP""' if year(eldate)==1957
replace grundmandat = `""B90/Gr","PDS""' if year(eldate)==1990
replace grundmandat = `""PDS""' if year(eldate)==1994
replace grundmandat = `""PDS""' if year(eldate)==1998

// Seats
// -----

keep if area=="DE"

// 1949 
gen seats = 131 if party == "SPD" & year(eldate)==1949
lab var seats "Seats in Parliament"
replace seats =   1 if party == "SSW" & year(eldate)==1949
replace seats =   3 if party == "Parteilose" & year(eldate)==1949
replace seats =   5 if party == "DKP/DRP" & year(eldate)==1949
replace seats =  10 if party == "Zentrum" & year(eldate)==1949
replace seats =  12 if party == "WAV" & year(eldate)==1949
replace seats =  15 if party == "KPD" & year(eldate)==1949
replace seats =  17 if party == "BP" & year(eldate)==1949   
replace seats =  17 if party == "DP" & year(eldate)==1949
replace seats =  24 if party == "CSU" & year(eldate)==1949
replace seats =  52 if party == "FDP" & year(eldate)==1949
replace seats = 115 if party == "CDU" & year(eldate)==1949

// 1953
replace seats = 189 if party == "CDU" & year(eldate)==1953
replace seats = 151 if party == "SPD" & year(eldate)==1953
replace seats =  52 if party == "CSU" & year(eldate)==1953
replace seats =  48 if party == "FDP" & year(eldate)==1953
replace seats =  27 if party == "GB/BHE" & year(eldate)==1953
replace seats =  14 if party == "DP" & year(eldate)==1953
replace seats =   3 if party == "Zentrum" & year(eldate)==1953

// 1957--2009
levelsof appmethod if year(eldate)>=1957, local(K)
foreach k of local K {
	egen `k' = apport(npartyvotes) if appmethod=="`k'", ///
	  by(eldate) s(size) t(5) e(strpos(grundmandat,party)>0) m(`k')
}
replace seats 							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton, ///
    cond(!mi(webster),webster,.))) if year(eldate)>=1957
drop jefferson hamilton webster

// Overhang seats
// --------------

replace seats = seats + 2 if party == "CDU" & year(eldate)==1953
replace seats = seats + 1 if party == "DP" & year(eldate)==1953
replace seats = seats + 3 if party == "CDU" & year(eldate)==1957
replace seats = seats + 5 if party == "CDU" & year(eldate)==1961
replace seats = seats + 1 if party == "SPD" & year(eldate)==1980
replace seats = seats + 2 if party == "SPD" & year(eldate)==1983
replace seats = seats + 1 if party == "CDU" & year(eldate)==1987
replace seats = seats + 6 if party == "CDU" & year(eldate)==1990
replace seats = seats + 12 if party == "CDU" & year(eldate)==1994
replace seats = seats + 4 if party == "SPD" & year(eldate)==1994
replace seats = seats + 13 if party == "SPD" & year(eldate)==1998
replace seats = seats + 1 if party == "CDU" & year(eldate)==2002
replace seats = seats + 4 if party == "SPD" & year(eldate)==2002
replace seats = 2 if party == "PDS" & year(eldate)==2002
replace seats = seats + 7 if party == "CDU" & year(eldate)==2005
replace seats = seats + 9 if party == "SPD" & year(eldate)==2005
replace seats = seats + 21 if party == "CDU" & year(eldate)==2009
replace seats = seats + 3 if party == "CSU" & year(eldate)==2009






// Append Landtag
// ==============

append using `x'


// Seats
// -----

replace size=73 if year(eldate)==1979 & area=="SH"
replace size=74 if inlist(year(eldate),1983,1987,1988) & area=="SH"
replace size=75 if inlist(year(eldate),1992,1996,2000) & area=="SH"
replace size=69 if year(eldate)==2005 & area=="SH"
replace size=66 if year(eldate)==1990 & area=="MV"
replace size=71 if inlist(year(eldate),1994,1998,2002,2006) & area=="MV" 
replace size=120 if inlist(year(eldate),1978,1982,1986,1987) & area=="HH"
replace size=121 if inlist(year(eldate),1991,1993,1997,2001,2004,2008) & area=="HH" 
replace size=100 if inlist(year(eldate),1979,1983,1987,1991,1995,1999) & area=="HB" 
replace size=83 if inlist(year(eldate),2003,2007) & area=="HB"
replace size=99 if inlist(year(eldate),1990,1994,1998,2002) & area=="ST" 
replace size=91 if year(eldate)==2006 & area=="ST" 
replace size=125 if inlist(year(eldate),1979,1981) & area=="BE" 
replace size=119 if inlist(year(eldate),1985,1989) & area=="BE" 
replace size=200 if year(eldate)==1990 & area=="BE"
replace size=150 if year(eldate)==1995 & area=="BE"
replace size=130 if inlist(year(eldate),1999,2001,2006) & area=="BE"
replace size=120 if inlist(year(eldate),1968,1980,1984,1988,1992,1996,2001,2006) & area=="BW"
replace size=88 if inlist(year(eldate),1990,1994,1999,2004) & area=="BB"
replace size=149 if year(eldate)==1970 & area=="NI"
replace size=155 if inlist(year(eldate),1978,1982,1986,1990,1994,1998,2003) & area=="NI"
replace size=135 if year(eldate)==2008 & area=="NI"
replace size=200 if inlist(year(eldate),1962,1966,1970) & area=="NW"
replace size=201 if inlist(year(eldate),1985,1990,1995,2000) & area=="NW"
replace size=181 if year(eldate)==2005 & area=="NW"
replace size=160 if year(eldate)==1990 & area=="SN"
replace size=120 if inlist(year(eldate),1994,1999,2004) & area=="SN"
replace size=96 if year(eldate)==1962 & area=="HE"
replace size=110 if inlist(year(eldate),1970,1982,1983,1987,1991,1995,1999,2003,2008) & area=="HE"
replace size=89 if year(eldate)==1990 & area=="TH"
replace size=88 if inlist(year(eldate),1994,1999,2004) & area=="TH"
replace size=100 if inlist(year(eldate),1967,1979,1983,1987) & area=="RP"
replace size=101 if inlist(year(eldate),1991,1996,2001,2006) & area=="RP"
replace size=204 if inlist(year(eldate),1966,1974,1982,1986,1990,1994,1998) & area=="BY"
replace size=180 if year(eldate)==2003 & area=="BY"
replace size=50 if year(eldate)==1980 & area=="SL"
replace size=51 if inlist(year(eldate),1985,1990,1994,1999,2004) & area=="SL"



// Derived variables
// =================

// Unit of analysis
// ----------------

gen unitid = area + " (" + string(eldate,"%tdMon_YY") + ")"
lab var unitid "Unit of analysis"


// Sum up CDU and CSU
// ------------------

replace party = "CDU/CSU" if party == "CDU" | party == "CSU" 					
  
// Recalculate number of votes
by area eldate party, sort: replace npartyvotes = sum(npartyvotes)
by area eldate party: replace npartyvotes = npartyvotes[_N]

// Recalculate number of seats
by area eldate party, sort: replace seats = sum(seats)
by area eldate party: replace seats = seats[_N]
by area eldate party: keep if _n==1


// Percentages
// -----------

gen pvoters = nvoters/nelectorate * 100
lab var pvoters "Total turnout"
gen pvalid = nvalid/nelectorate * 100
lab var pvalid "Valid turnout"
gen pinvalid = ninvalid/nelectorate * 100
lab var pinvalid "Invalid %"
gen ppartyvotes = npartyvotes/nvalid * 100
lab var ppartyvotes  "Proportion of valid votes (in %)"


// Number of parties > 1%
// ----------------------

by area eldate: gen byte nparties = _N
by area eldate: gen byte nparties1 = sum(ppartyvotes > 1)
by area eldate: replace nparties1 = nparties1[_N]
by area eldate: gen byte nparties5 = sum(ppartyvotes > 5)
by area eldate: replace nparties5 = nparties5[_N]

lab var nparties "# of parties"
lab var nparties1 "# of parties > 1%"
lab var nparties5 "# of parties > 5%"


// Regierungsparteien 
// ------------------

gen regparty:yesno = 0

// Berlin
replace regparty=1 if area == "BE" 		/// Scharz-Rot-Gelb
  & inlist(year(eldate),1950) 	  	    ///
  & inlist(party,"CDU/CSU","SPD","FDP")
replace regparty=1 if area == "BE" 		/// Große Koalition
  & inlist(year(eldate),1954,1958,1990,1995,1999) 		/// 
  & inlist(party,"CDU/CSU","SPD")
replace regparty=1 if area == "BE" 		 /// Sozialliberale Koalition
  & inlist(year(eldate),1963,1967,1975,1979)  /// 
  & inlist(party,"FDP","SPD")
replace regparty=1 if area == "BE" 		/// SPD
  & inlist(year(eldate),1971) 		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "BE" 		/// Schwarz-Gelb
  & inlist(year(eldate),1981,1985) 		/// 
  & inlist(party,"CDU/CSU","FDP")
replace regparty=1 if area == "BE" 		/// Rot-Grün
  & inlist(year(eldate),1989) 		    /// 
  & inlist(party,"SPD","AL")
replace regparty=1 if area == "BE" 		/// Rot-Rot
  & inlist(year(eldate),2001,2006)	    /// 
  & inlist(party,"SPD","PDS","Linke")
	
// Brandenburg
replace regparty=1 if area == "BB"		/// Ampel
  & inlist(year(eldate),1990) 	 	    ///
  & inlist(party,"CDU/CSU","SPD","FDP")
	
replace regparty=1 if area == "BB" 		/// SPD
  & inlist(year(eldate),1994) 		    /// 
  & inlist(party,"SPD")

replace regparty=1 if area == "BB" 		/// Große Koalition
  & inlist(year(eldate),1999,2004) 		    ///
  & inlist(party,"CDU/CSU","SPD")

// Baden Württemberg
replace regparty=1 if area == "BW" 		/// Scharz-Gelb
  & inlist(year(eldate),1960,1964,1996,2001,2006) 	  	    ///
  & inlist(party,"CDU/CSU","FDP")

replace regparty=1 if area == "BW" 		/// CDU
  & inlist(year(eldate),1972,1976,1980,1984,1988)		/// 
  & inlist(party,"CDU/CSU")

replace regparty=1 if area == "BW" 		/// Große Koalition
  & inlist(year(eldate),1968,1992) 			///    	    
  & inlist(party,"CDU/CSU","SPD")

replace regparty=1 if area == "BW" 		/// Allparteien
  & inlist(year(eldate),1952,1956) 			///    	    
  & inlist(party,"CDU/CSU","SPD","FDP","GB/BHE")

// Bayern
replace regparty=1 if area == "BY" 		/// CSU
  & inrange(year(eldate),1962,2003)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "BY" 		/// SPD,BP,BHE,FDP
  & inlist(year(eldate),1954)		    /// 
  & inlist(party,"SPD","BP","GB/BHE","FDP")
replace regparty=1 if area == "BY" 		/// CSU/FDP/GB-BHE
  & inlist(year(eldate),1958)		    /// 
  & inlist(party,"CDU/CSU","FDP","GB/BHE")
replace regparty=1 if area == "BY" 		/// CSU/SPD/BHE-DG
  & inlist(year(eldate),1950)		    /// 
  & inlist(party,"CDU/CSU","SPD","BHE-DG")
replace regparty=1 if area == "BY" 		/// CSU/SPD/BHE-DG
  & inlist(year(eldate),2008)		    /// 
  & inlist(party,"CDU/CSU","FDP")

// Bremen
replace regparty=1 if area == "HB" 		/// SPD, CDU, FDP
  & inlist(year(eldate),1951,1955)	    /// 
  & inlist(party,"CDU/CSU","SPD","FDP")
replace regparty=1 if area == "HB" 		/// Sozialliberal
  & inlist(year(eldate),1959,1963,1967)		    /// 
  & inlist(party,"SPD","FDP")
replace regparty=1 if area == "HB" 		/// SPD
  & inlist(year(eldate),1971,1975,1979,1983,1987)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "HB" 		/// Ampel
  & inlist(year(eldate),1991)		    /// 
  & inlist(party,"SPD","FDP","Gruene")
replace regparty=1 if area == "HB" 		/// Große Koalition
  & inlist(year(eldate),1995,1999,2003)		    /// 
  & inlist(party,"SPD","CDU/CSU")
replace regparty=1 if area == "HB" 		/// Rot-Gruene
  & inlist(year(eldate),2007)		    /// 
  & inlist(party,"SPD","Gruene")

// Deutschland
replace regparty = 1 if area=="DE"		/// CDU/FDP/DP
  & inlist(party,"CDU/CSU","FDP","DP") 	///
  & inlist(year(eldate),1949,1953)
replace regparty = 1 if area=="DE"		/// CDU/DP
  & inlist(party,"CDU/CSU","DP") 	///
  & inlist(year(eldate),1957,1961)
replace regparty = 1 if area=="DE"		/// CDU/FDP
  & inlist(party,"CDU/CSU","FDP") 	///
  & inlist(year(eldate),1961,1965,1983,1987,1990,1994)
replace regparty = 1 if area=="DE"		/// Große Koalition
  & inlist(party,"CDU/CSU","SPD") 	///
  & inlist(year(eldate),2005)
replace regparty = 1 if area=="DE"		/// Sozialliberal
  & inlist(party,"FDP","SPD") 	///
  & inlist(year(eldate),1969,1972,1976,1980)
replace regparty = 1 if area=="DE"		/// Rot-Grün
  & inlist(party,"SPD","Gruene") 	///
  & inlist(year(eldate),1998,2002)

// Hessen
replace regparty=1 if area == "HE" 		/// SPD, GB/BHE
  & inlist(year(eldate),1954,1958,1962)	    /// 
  & inlist(party,"GB/BHE","SPD","GDP/BHE")
replace regparty=1 if area == "HE" 		/// Sozialliberal
  & inlist(year(eldate),1970,1974,1978)		    /// 
  & inlist(party,"SPD","FDP")
replace regparty=1 if area == "HE" 		/// SPD
  & inlist(year(eldate),1950,1966,1982)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "HE" 		/// CDU
  & inlist(year(eldate),2003,2008)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "HE" 		/// Schwarz-Gelb
  & inlist(year(eldate),1987,1999,2009)		    /// 
  & inlist(party,"FDP","CDU/CSU")
replace regparty=1 if area == "HE" 		/// Rot-Grün
  & inlist(year(eldate),1983,1991,1995)		    /// 
  & inlist(party,"SPD","Gruene")

// Hamburg
replace regparty=1 if area == "HH" 		/// Sozialliberal
  & inlist(year(eldate),1957,1961,1970,1974,1987)		    /// 
  & inlist(party,"SPD","FDP")
replace regparty=1 if area == "HH" 		/// SPD
  & inlist(year(eldate),1949,1966,1978,1982,1986,1991)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "HH" 		/// SPD/Statt-Partei
  & inlist(year(eldate),1993) 			///
  & inlist(party,"SPD","STATT Partei")
replace regparty=1 if area == "HH" 		/// CDU/Schill/FDP
  & inlist(year(eldate),2001)		    /// 
  & inlist(party,"FDP","CDU/CSU","Schill")
replace regparty=1 if area == "HH" 		/// Rot-Grün
  & inlist(year(eldate),1997)		    /// 
  & inlist(party,"SPD","Gruene")
replace regparty=1 if area == "HH" 		/// Hamburg-Block
  & inlist(year(eldate),1953)		    /// 
  & inlist(party,"Hamburg Block")
replace regparty=1 if area == "HH" 		/// CDU
  & inlist(year(eldate),2004)		    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "HH" 		/// Scharz-Grün
  & inlist(year(eldate),2008)		    /// 
  & inlist(party,"CDU/CSU","Gruene")

// Mecklenburg Vorpommern
replace regparty=1 if area == "MV" 		/// Scharz-Gelb
  & inlist(year(eldate),1990)		    /// 
  & inlist(party,"CDU/CSU","FDP")
replace regparty=1 if area == "MV" 		/// Große Koalition
  & inlist(year(eldate),1994,2006)	    /// 
  & inlist(party,"SPD","CDU/CSU")
replace regparty=1 if area == "MV" 		/// Rot-Rot
  & inlist(year(eldate),1998,2002)	    /// 
  & inlist(party,"SPD","PDS")

// Niedersachsen
replace regparty=1 if area == "NI" 		/// SPD, GB/BHE, Zentrum
  & inlist(year(eldate),1951)	    /// 
  & inlist(party,"GB/BHE","SPD","Zentrum")
replace regparty=1 if area == "NI" 		/// CDU et al. 
  & inlist(year(eldate),1955)	    /// 
  & inlist(party,"DP","CDU/CSU","FDP","GB/BHE")
replace regparty=1 if area == "NI" 		/// SPD, GB/BHE, FDP
  & inlist(year(eldate),1959)	    /// 
  & inlist(party,"GB/BHE","SPD","FDP")
replace regparty=1 if area == "NI" 		/// Sozialliberal
  & inlist(year(eldate),1963,1974)		    /// 
  & inlist(party,"SPD","FDP")
replace regparty=1 if area == "NI" 		/// SPD
  & inlist(year(eldate),1970,1994,1998)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "NI" 		/// CDU
  & inlist(year(eldate),1978,1982)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "NI" 		/// Schwarz-Gelb
  & inlist(year(eldate),1986,2003,2008)		    /// 
  & inlist(party,"FDP","CDU/CSU")
replace regparty=1 if area == "NI" 		/// Rot-Grün
  & inlist(year(eldate),1990)		    /// 
  & inlist(party,"SPD","Gruene")
replace regparty=1 if area == "NI" 		/// Große Koalition
  & inlist(year(eldate),1967)		    /// 
  & inlist(party,"SPD","CDU/CSU")

// Nordrhein-Westfalen
replace regparty=1 if area == "NW" 		/// CDU, Zentrum, SPD
  & inlist(year(eldate),1950)	    /// 
  & inlist(party,"CDU/CSU","SPD","Zentrum")
replace regparty=1 if area == "NW" 		/// Sozialliberal
  & inlist(year(eldate),1966,1970,1975)		    /// 
  & inlist(party,"SPD","FDP")
replace regparty=1 if area == "NW" 		/// SPD
  & inlist(year(eldate),1980,1985,1990)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "NW" 		/// CDU
  & inlist(year(eldate),1958)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "NW" 		/// Schwarz-Gelb
  & inlist(year(eldate),1954,1962,2005)		    /// 
  & inlist(party,"FDP","CDU/CSU")
replace regparty=1 if area == "NW" 		/// Rot-Grün
  & inlist(year(eldate),1995,2000)		    /// 
  & inlist(party,"SPD","Gruene")

// Rheinland Pfalz
replace regparty=1 if area == "RP" 		/// Sozialliberal
  & inlist(year(eldate),1991,1996,2001) /// 
  & inlist(party,"SPD","FDP")
replace regparty=1 if area == "RP" 		/// SPD
  & inlist(year(eldate),2006)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "RP" 		/// CDU
  & inlist(year(eldate),1971,1975,1979,1983)	            /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "RP" 		/// Schwarz-Gelb
  & inlist(year(eldate),1951,1955,1959,1963,1967,1987)		    /// 
  & inlist(party,"FDP","CDU/CSU")

// Schleswig-Holstein
replace regparty=1 if area == "SH" 		/// CDU, GB/BHE, FDP, DP
  & inlist(year(eldate),1950)	    /// 
  & inlist(party,"GB/BHE","CDU/CSU","FDP","DP")
replace regparty=1 if area == "SH" 		/// CDU, GB/BHE, FDP
  & inlist(year(eldate),1954,1958)	    /// 
  & inlist(party,"GB/BHE","CDU/CSU","FDP")
replace regparty=1 if area == "SH" 		/// Große Koalition
  & inlist(year(eldate),2005)		    /// 
  & inlist(party,"CDU/CSU","SPD")
replace regparty=1 if area == "SH" 		/// SPD
  & inlist(year(eldate),1988,1992)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "SH" 		/// CDU
  & inlist(year(eldate),1971,1975,1979,1983,1987)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "SH" 		/// Schwarz-Gelb
  & inlist(year(eldate),1962,1967)		    /// 
  & inlist(party,"FDP","CDU/CSU")
replace regparty=1 if area == "SH" 		/// Rot-Grün
  & inlist(year(eldate),1996,2000)		    /// 
  & inlist(party,"SPD","Gruene")

// Saarland
replace regparty=1 if area == "SL" 		/// SPD
  & inlist(year(eldate),1985,1990,1994)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "SL" 		/// CDU
  & inlist(year(eldate),1970,1975,1999,2004)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "SL" 		/// Schwarz-Gelb
  & inlist(year(eldate),1960,1965,1980)		    /// 
  & inlist(party,"FDP","CDU/CSU")

// Sachsen
replace regparty=1 if area == "SN" 		/// Große Koalition
  & inlist(year(eldate),2004)		    /// 
  & inlist(party,"SPD","CDU/CSU")
replace regparty=1 if area == "SN" 		/// CDU
  & inlist(year(eldate),1990,1994,1999)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "SN" 		/// CDU/FDP
  & inlist(year(eldate),2009)	    /// 
  & inlist(party,"CDU/CSU","FDP")

// Sachsen-Anhalt
replace regparty=1 if area == "ST" 		/// SPD
  & inlist(year(eldate),1998)		    /// 
  & inlist(party,"SPD")
replace regparty=1 if area == "ST" 		/// Große Koaliton
  & inlist(year(eldate),2006)	/// 
  & inlist(party,"CDU/CSU","SPD")
replace regparty=1 if area == "ST" 		/// Schwarz-Gelb
  & inlist(year(eldate),1990,2002)		    /// 
  & inlist(party,"FDP","CDU/CSU")
replace regparty=1 if area == "ST" 		/// Rot-Grün
  & inlist(year(eldate),1994)		    /// 
  & inlist(party,"SPD","Gruene")

// Thüringen
replace regparty=1 if area == "TH" 		/// CDU
  & inlist(year(eldate),1999,2004)	    /// 
  & inlist(party,"CDU/CSU")
replace regparty=1 if area == "TH" 		/// Große Koaliton
  & inlist(year(eldate),1994)	/// 
  & inlist(party,"CDU/CSU","SPD")
replace regparty=1 if area == "TH" 		/// Schwarz-Gelb
  & inlist(year(eldate),1990)		    /// 
  & inlist(party,"FDP","CDU/CSU")
lab var regparty "Govering party y/n"


// Sitze im Bundesrat
gen brseats = 3 if inlist(area,"HB","HH","MV","SL")
replace brseats = 4 if inlist(area,"BE","BB","RP","SN","ST","SH","TH")
replace brseats = 4 if inlist(area,"HE") & eldate<date("18Jan1996","DMY")
replace brseats = 5 if inlist(area,"HE") & eldate>=date("18Jan1996","DMY")
replace brseats = 6 if inlist(area,"BW","BY","NI","NW")
replace brseats = 0 if inlist(area,"BE","BB","MV","SN","ST","TH") 	/// 
  & eldate<date("3Oct1990","DMY") 
lab var brseats "Seats in Bundesrat"

// Mandatszuteilungsverfahren
// --------------------------

replace appmethod = "jefferson" if 			///
  (inlist(area,"SL","SN","SH")) 	///
  | (area == "BY" & year(eldate) <= 1993)  ///
  | (area == "BW" & year(eldate) <= 2007)  ///
  | (area == "HE" & year(eldate) <= 1982)  ///
  | (area == "BE" & year(eldate) <= 1987)  ///
  | (area == "HB" & year(eldate) <= 1990)  ///
  | (area == "HH" & year(eldate) <= 1990)  ///  
  | (area == "NI" & (year(eldate) <= 1974 | year(eldate) >= 1986)) ///

replace appmethod = "hamilton" if 			///
  (inlist(area,"BB","MV","NW","RP","ST","TH")) 	///
  | (area == "BY" & year(eldate) > 1993)  ///
  | (area == "HE" & year(eldate) > 1982)  ///
  | (area == "BE" & year(eldate) > 1987)  ///
  | (area == "HB" & inrange(year(eldate),1990,2002))  ///
  | (area == "HH" & inrange(year(eldate),1991,2004))  /// 
  | (area == "NI" & inrange(year(eldate),1978,1982)) 

replace appmethod = "webster" if    ///
  (area == "BW" & year(eldate) > 2007)  ///
  | (area == "HB" & year(eldate) > 2002)  ///
  | (area == "HH" & year(eldate) > 2004) 
lab var appmethod "Mandatszuteilungsverfahren"
note appmethod: Quellen: Vogel et al. (1971: 192--195), /// 
  http://www.wahlrecht.de/laender/index.htm

order unitid area eldatestr eldate  ///
  nelectorate nvoters nvalid ninvalid nmissing ///
  party npartyvotes nparties nparties1 nparties5 seats ///
  p* regparty brseats appmethod

compress
save elections, replace


exit





