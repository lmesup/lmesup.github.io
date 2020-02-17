// Creates various Country names 

	version 8.2
	clear
		
	input s_cntry str30 ctren str30 ctrde str3 iso3166_3 str2 iso3166_2 eu
      1    Austria       Österreich      AUT  AT	  1
      2    Belgium       Belgien 			  BEL  BE  1
      3   Bulgaria  		 Bulgarien 		  BGR  BG     3
      4     Cyprus  		 Zypern 			  CYP  CY     2
      5    Czechia  		 Tschechien 		  CZE  CZ  2
      6    Denmark  		 Dänemark 		  DNK  DK     1
      7    Estonia  		 Estland 			  EST  EE  2
      8    Finland  		 Finnland 		  FIN  FI     1
      9     France  		 Frankreich 		  FRA  FR  1
     10    Germany  		 Deutschland 	  DEU  DE     1
     11 "United Kindom"  Großbritannien  GBR  GB	  1  
     12     Greece  		 Griechenland 	  GRC  GR     1
     13    Hungary  		 Ungarn 			  HUN  HU     2
     14    Ireland  		 Irland 			  IRL  IE     1
     15      Italy  		 Italien 			  ITA  IT  1
     16     Latvia  		 Lettland 		  LVA  LV     2
     17   Lithuania  	 Litauen 			  LTU  LT  2
     18   Luxembourg  	 Luxemburg 		  LUX  LU     1
     19      Malta  		 Malta 			  MLT  MT     2
     20   Netherlands  	 Niederlande 	  NLD  NL     1
     21     Poland  		 Polen 			  POL  PL     2
     22    Romania  		 Rumänien 		  ROU  RO     3
     23   Slovakia  		 Slowakei 		  SVK  SK     2 
     24   Slovenia  		 Slowenien 		  SVN  SI     2
     25      Spain  		 Spanien 			  ESP  ES  1
     26     Sweden  		 Schweden 		  SWE  SE     1
     27     Turkey  		 Türkei 			  TUR  TR     3
     28   Portugal  		 Portugal			  PRT  PT  1
end

	sort s_cntry
	compress

	label variable eu "EU-Status"
	label define eu 1 "EU-15" 2 "AC-10" 3 "CC-3"
	label value eu eu

	save isocntry, replace
