*+----------------------------------------------------------------+
*|              MASTER-DO-FILE for KOHLER (2002c)                 |
*|      SOCIAL STRUCTURAL EVENTS AND PARTY PREFERENCE             |
*|              UNIVERSITY OF MANNHEIM, GERMANY                   |
*+----------------------------------------------------------------+             

* You need the following data-set:
* - GSOEP, 1984-2000 (http://www.diw-berlin.de)

version 7.0    
clear
set memory 60m   
set more off

*******************************************************************

*+-----------------------------------------+ 
*| EDIT THIS TO FIT YOUR LOCAL ENVIRONMENT |
*+-----------------------------------------+

* GSOEP-Diretory
* ---------------

* This sets a global macro "soepdir", which points to the directory 
* with the entire GSOEP-Data. You need to change this to the
* GSOEP-directory on your computer.
* Note: You should not use this directory as working directory!

global soepdir ~/data/soep      /* <- Change this */

* End of editing-section, but read following section carefully!
*******************************************************************

*+------------------+
*| ADO-INSTALLATION |
*+------------------+

* The following section automatically installs Ado-Files over the
* Internet. You need to have a conection to the internet for this.
* If you don't have a connection to the internet you need to commend 
* out the entire section. In this case you have to install the ados
* by hand (See [U] 32 or Kohler/Kreuter (2001))


* mkdat.ado, a tool for easy SOEP-Retrivals (U. Kohler)
capture which mkdat 
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lesas/ado
	net install mkdat
}


* hplot.ado, a tool for horizontally labeled plots (N. Cox)
capture which hplot
if _rc ~= 0 {
	ssc inst hplot
}


* mmerge.ado, easy and safe merging (J. Weesie)
capture which mmerge
if _rc ~= 0 {
	ssc inst mmerge
}


* fitstat.ado,  Scalar measures of fit for regression models (J. Long/J. Freese)
capture which fitstat
if _rc ~= 0 {
	net stb-56
	net install sg145
}


* rgroup.ado, Random Group Variance Estimation (U. Kohler)
capture which rgroup
if _rc ~= 0 {
	ssc install rgroup 
}

* end of installing section. 
* Note: Ado-Files also installed within the Do-Files
*******************************************************************

*+--------------------+
*| ANALYZING SECTION  |
*+--------------------+

* Simulation
* -----------

do crsimul    /* Simulation of the Data */
do grsimul1   /* Graph Results of Simulation */

* Graph of tpaths
* ---------------

do grtpaths   /* Produce Graphs like in Allison (1994) */

* Create the Data
* --------------
  
do cregp      /* Create Master-File for EGP-Classes */
do crweights  /* Create Data with weights and friends */
do crpidlv    /* Create Main Analyzing Data */

* Decribe Estimation Sample
* ------------------------

anal anpidlv1 /* Describe pidlv.dta: number of respondents, obs etc. */
do grpidlv1 /* Distribution of obs/resp. */
anal anpidlv2 /* Distribution independent vars */

* Models
* ------

* Model 1 (immediatly/permanent)
  
anal anmod1fit /* Fit  */
anal anmod1b  /* Coefficients */
do crbe      /* Creates Data with Between-Effects */ 
do grmod1 /* Graph Results */
anal anmod1se  /* Rgroup Standardfehler */

* Model 2 (incomplete information)
  
anal anmod2fit /* Fit  */
anal anmod2b  /* Coefficients */
do grmod2 /* Graph Results */
anal anmod2se  /* Rgroup Standardfehler */

* Model 3 (gradual effects)
  
anal anmod3fit /* Fit  */
anal anmod3b  /* Coefficients */
do grmod3 /* Graph Results */
anal anmod3se  /* Rgroup Standardfehler */

* Print Graphs
* ------------

do gphprint

exit

*******************************************************************




