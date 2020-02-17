	version 8.2

	use $stata/planets, clear
	lab var planet "Planet"
	lab var distance "Mean Dist. from Sun (10^6 km)"
	lab var radius   "Radius at Equator (km)"		  
	lab var mass     "Mass (kg)" 
	lab var density  "Density (g/m^3)"				  
	lab var moons    "Number of Known Moons"		  
	lab var rings    "Rings present"					  
	lab var logdist  "Log Dist. from Sun (10^6 km)"
	lab var lograd   "Log Radius at Equator (km)"		  
	lab var logmass  "Log Mass (kg)" 
	lab var logdens  "Log Density (g/m^3)"				  
	lab var logmoons "Log Number of Known Moons +1"		  

	lab def yesno 0 "no" 1 "yes", modify

	format logdist-logmoons %4.0g


	replace planet = "Mercury" if planet == "Merkur"
	replace planet = "Earth" if planet == "Erde"
	replace planet = "Neptune" if planet == "Neptun"
	
	
	save planets, replace
	exit
	

	
