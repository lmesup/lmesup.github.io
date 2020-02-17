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




