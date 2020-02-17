* Repräsentativität (weicher Datensatz)
* luniak@wz-berlin.de

version 8.2

clear
set memory 80m
set more off
use alldat2

// 2 Personen im Haushalt
keep if paar ==1

// Ehepaare oder Partner, die zusammen leben
keep if mar == 1

save wdata, replace

exit
