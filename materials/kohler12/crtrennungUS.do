*** CREATE US ***

version 11
clear
set mem 500m
set more off

psiduse  ///
	|| mpairs [80]ER30317 [81]ER30347 [82]ER30377 [83]ER30405 ///
	[84]ER30435 [85]ER30469 [86]ER30504 [87]ER30541 [88]ER30576 ///
	[89]ER30612 [90]ER30648 [91]ER30695 [92]ER30739 [93]ER30812 ///
	[94]ER33107 [95]ER33207 [96]ER33307 [97]ER33407 [99]ER33507 ///
	[01]ER33607 [03]ER33707 [05]ER33807  [07]ER33907 ///
	///
	|| moveout [80]ER30318 [81]ER30348 [82]ER30378 [83]ER30406 ///
	[84]ER30436 [85]ER30470 [86]ER30505 [87]ER30542 [88]ER30577 ///
	[89]ER30613 [90]ER30649 [91]ER30696 [92]ER30740 [93]ER30813 ///
	[94]ER33108 [95]ER33208 [96]ER33308 [97]ER33408 [99]ER33508 ///
	[01]ER33608 [03]ER33708 [05]ER33808 [07]ER33908 ///
  using $psid, design(any) clear

psidadd ///
  || mar d11104 						/// 
  || rel2head d11105 					///
  || kidshh h11101 						///
  || indhh x11103 						///
  , cneffrom($cnef07) correct 

drop xsqnr* x11102*

// reshape long
reshape long 							/// 
  mar rel2head indhh mpairs moveout kidshh, i(x11101ll) j(wave)	
	
by x11101ll (wave), sort: 				/// 
  gen trennung =  mpairs==0 & mpairs[_n-1]==1 ///
  & inlist(rel2head,1,2) & mar!=3 & kidshh[_n-1]!=0

by x11101ll (wave), sort: 				///
  gen divorce = inlist(mar,4,5) & mar[_n-1]==1 & kidshh[_n-1]!=0

save trennungUS, replace











