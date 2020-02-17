* Some Numbers used in the text
* -----------------------------

version 8.2
	set more off
	capture log close
	log using anGDP, replace

	// Data
	// ----

quietly {

		use plurality_ci_b, clear
		drop if iso3166_2 == "LU"

		encode eu, gen(EU)
		recode EU  3=1 2=3 1=2
		label define EU 1 "EU-15" 2 "AC-10" 3 "CC-3", modify
		
		// Calculate Means
		// ---------------

		forv i = 1/3 {
			sum  gdppcap1 if EU == `i', meanonly
			local mean`i' = r(mean)
			local min`i' = r(min)
			local max`i' = r(max)
		}
		
		sort gdppcap1
	}
	
	di as txt  "Mean EU-15/Mean AC-10: " as res `mean1'/`mean2'
	di as txt  "Mean EU-15/Mean CC-3: " as res `mean1'/`mean3'
	di as txt  "Mean AC-10/Mean CC-3: " as res `mean2'/`mean3'
	di as txt  "Max/Min: " as res gdppcap1[_N]/gdppcap1[1]
	di as txt  "EU: Max/Min: " as res `max1'/`min1'
	di as txt  "AC: Max/Min: " as res `max2'/`min2'
	di as txt  "CC: Max/Min: " as res `max3'/`min3'
		
		
quietly {

		use ~/data/agg/gdp50-02, clear  // See notes below
		drop if iso3166_2 == "DE-w"
		bysort iso3166_2 (year): gen minmax = GDP[_N]/GDP[1]
		by iso3166_2: keep if _n==1
	}

	sum minmax
	list iso3166_2 minmax


	// Letzte 30 Jahre
	// ---------------
	
	quietly {
		use ~/data/agg/gdp50-02, clear  // See notes below
		drop if iso3166_2 == "DE-w"
		drop if year < 1973
		bysort iso3166_2 (year): gen minmax = GDP[_N]/GDP[1]
		by iso3166_2: keep if _n==1
	}

	sum minmax
	list iso3166_2 minmax


	
	log close
	exit


	Notes
	-----
	
Daten beruhen auf 24 OECD-Ländern	
	
AUSTRALIA: 7 June 1971
AUSTRIA: 29 September 1961
BELGIUM: 13 September 1961
CANADA: 10 April 1961
DENMARK: 30 May 1961
FINLAND: 28 January 1969
FRANCE: 7 August 1961
GERMANY: 27 September 1961
GREECE: 27 September 1961
ICELAND: 5 June 1961
IRELAND: 17 August 1961
ITALY: 29 March 1962
JAPAN: 28 April 1964
LUXEMBOURG: 7 December 1961
NETHERLANDS: 13 November 1961
NEW ZEALAND: 29 May 1973
NORWAY: 4 July 1961
PORTUGAL: 4 August 1961
SPAIN: 3 August 1961
SWEDEN: 28 September 1961
SWITZERLAND: 28 September 1961
TURKEY: 2 August 1961
UNITED KINGDOM: 2 May 1961
UNITED STATES: 12 April 1961


Nicht enthalten sind Daten folgender 6 OECD-Mitgliedsstaaten

CZECH REPUBLIC: 21 December 1995
HUNGARY: 7 May 1996
KOREA: 12 December 1996
MEXICO: 18 May 1994
SLOVAK REPUBLIC: 14 December 2000
POLAND: 22 November 1996
