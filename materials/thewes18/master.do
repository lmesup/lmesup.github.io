* Thewes, Christoph (2018): Verzerrte Beteiligung.
* Legitimation von Volksentscheiden am Beispiel Stuttgart 21.
* KZfSS - Kölner Zeitschrift für Soziologie und Sozialpsychologie, 70(1)
* thewes@uni-potsdam.de


version 14
set more off
clear all
*graph set window fontface "CMU Serif"   // use LaTeX-Font

cd "$s21path"

do 00pr_maps			// Prepare Shape-Files
do 00cr_makro			// Prepare Makro-Data
do 00cr_s21				// Prepare S21-Election-Data
do 00cr_elections		// Prepare Elections (BTW 2009, LTW 2011)

do 01cr_ind				// Prepare Individual-Data from Gabriel/Faas/ZA5592/ZA5625
do 01an_reg_diag		// Regression-diagnostic

do 02cr_hat				// Predict counterfactual voting

do 03gr_maps_bw			// Create Descriptiv Maps

do 04gr_maps_y			// Create Bias-Maps
do 04gr_scatter_y		// Create Scatterplot with other participation-methods
do 04gr_robustness		// Create robustness check: Map+Scatter

exit


