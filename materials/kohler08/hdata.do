* Repräsentativität (harter Datensatz)
* luniak@wz-berlin.de

version 8.2

clear
set memory 80m
set more off
use alldat2, clear

// 2 Personen im Haushalt
keep if paar ==1

// Ehepaare oder Partner, die zusammen leben
keep if mar == 1

//Geschlechtskriterium
keep if female2 <.
keep if female != female2 

save hdata, replace

exit
