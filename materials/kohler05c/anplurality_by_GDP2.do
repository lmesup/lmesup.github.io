* Entropy and Deviance by GDP
* ---------------------------

version 8.2

	// Data
	// ----

	use plurality_ci, clear

	gen fc = inlist(s_cntry,3,5,7,13,16,17,21,22,23,24)

	replace gdppcap = gdppcap/1000
	drop if iso3166_2 == "LU"
	

	reg entropy_s gdppcap1 /* Npl */  if fc 
	estimates store entropy_fc

	reg entropy_s gdppcap1 /* Npl */  if !fc 
	estimates store entropy_nfc

	reg deviance gdppcap1 /* Npl */  if fc 
	estimates store deviance_fc

	reg deviance gdppcap1 /* Npl */  if !fc 
	estimates store deviance_nfc

   lab var entropy_s "Entropie"
	lab var deviance  "Devianz"
   lab var gdppcap1  "BIP"
	lab var Npl  "Beob. für SES"

	estout entropy_fc entropy_nfc deviance_fc deviance_nfc ///
	  using anplurality2.tex, replace  ///
	  cells(b(star fmt(%4.3f)) se(paren fmt(%4.3f)))        ///
	  stats(r2 N, fmt(%4.2f %4.0f) label("\$r^2$" "n"))     ///
	  label varlabels(_cons Konstante) style(tex)           ///  
	prehead("\begin{tabular}{lrrrrr}" \hline) ///
	  posthead(\hline) prefoot(\hline)         ///
	  postfoot(\hline "\end{tabular}")         ///
	  varwidth(22) modelwidth(6)

	exit
	
