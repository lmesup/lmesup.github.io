// Liferisk-Projekt, Create data set for all events
// kohler@wzb.eu


cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m

// Germany
// =======

// Retrive Data from SOEP 26
// -------------------------

soepuse ///
  afamstd bfamstd cfamstd dfamstd efamstd ffamstd gfamstd hfamstd ///
  ifamstd jfamstd kfamstd lfamstd mfamstd nfamstd ofamstd pfamstd ///
  qfamstd rfamstd sfamstd tfamstd ufamstd vfamstd wfamstd xfamstd ///
  yfamstd zfamstd 								///
  ///
  partnr84 partnr85 partnr86 partnr87 partnr88 partnr89 /// 
  partnr90 partnr91 partnr92 partnr93 partnr94 partnr95 ///
  partnr96 partnr97 partnr98 partnr99 partnr00 partnr01 /// 
  partnr02 partnr03 partnr04 partnr05 partnr06 partnr07 /// 
  partnr08 partnr09 ///
  partz84 partz85 partz86 partz87 partz88 partz89 partz90 /// 
  partz91 partz92 partz93 partz94 partz95 partz96 partz97 /// 
  partz98 partz99 partz00 partz01 partz02 partz03 partz04 /// 
  partz05 partz06 partz07 partz08 partz09 ///
  egp84 egp85 egp86 egp87 egp88 egp89 egp90 egp91 egp92 egp93 egp94 ///
  egp95 egp96 egp97 egp98 egp99 egp00 egp01 egp02 egp03 egp04 egp05 ///
  egp06 egp07 egp08 egp09 ///
  using $soep26/ , ///
  ftyp(pgen) waves(1984/2009) ///
  design(any) keep(sex gebjahr todjahr migback) clear

soepadd ///
  d1110684 d1110685 d1110686 d1110687 d1110688 d1110689 d1110690 ///
  d1110691 d1110692 d1110693 d1110694 d1110695 d1110696 d1110697 ///
  d1110698 d1110699 d1110600 d1110601 d1110602 d1110603 d1110604 ///
  d1110605 d1110606 d1110607 d1110608 d1110609 ///
  e1110684 e1110685 e1110686 e1110687 e1110688 e1110689 e1110690 ///
  e1110691 e1110692 e1110693 e1110694 e1110695 e1110696 e1110697 ///
  e1110698 e1110699 e1110600 e1110601 e1110602 e1110603 e1110604 ///
  e1110605 e1110606 e1110607 e1110608 e1110609 ///
  d1110884 d1110885 d1110886 d1110887 d1110888 d1110889 d1110890 ///
  d1110891 d1110892 d1110893 d1110894 d1110895 d1110896 d1110897 ///
  d1110898 d1110899 d1110800 d1110801 d1110802 d1110803 d1110804 ///
  d1110805 d1110806 d1110807 d1110808 d1110809 ///
  d1110984 d1110985 d1110986 d1110987 d1110988 d1110989 d1110990 ///
  d1110991 d1110992 d1110993 d1110994 d1110995 d1110996 d1110997 ///
  d1110998 d1110999 d1110900 d1110901 d1110902 d1110903 d1110904 ///
  d1110905 d1110906 d1110907 d1110908 d1110909 ///
  h1110184 h1110185 h1110186 h1110187 h1110188 h1110189 h1110190 ///
  h1110191 h1110192 h1110193 h1110194 h1110195 h1110196 h1110197 ///
  h1110198 h1110199 h1110100 h1110101 h1110102 h1110103 h1110104 ///
  h1110105 h1110106 h1110107 h1110108 h1110109 ///
  y1110184 y1110185 y1110186 y1110187 y1110188 y1110189 y1110190 ///
  y1110191 y1110192 y1110193 y1110194 y1110195 y1110196 y1110197 ///
  y1110198 y1110199 y1110100 y1110101 y1110102 y1110103 y1110104 ///
  y1110105 y1110106 y1110107 y1110108 y1110109 ///
  i1110184 i1110185 i1110186 i1110187 i1110188 i1110189 i1110190 ///
  i1110191 i1110192 i1110193 i1110194 i1110195 i1110196 i1110197 ///
  i1110198 i1110199 i1110100 i1110101 i1110102 i1110103 i1110104 ///
  i1110105 i1110106 i1110107 i1110108 i1110109 ///
  i1110284 i1110285 i1110286 i1110287 i1110288 i1110289 i1110290 ///
  i1110291 i1110292 i1110293 i1110294 i1110295 i1110296 i1110297 ///
  i1110298 i1110299 i1110200 i1110201 i1110202 i1110203 i1110204 ///
  i1110205 i1110206 i1110207 i1110208 i1110209 ///
  i1110384 i1110385 i1110386 i1110387 i1110388 i1110389 i1110390 ///
  i1110391 i1110392 i1110393 i1110394 i1110395 i1110396 i1110397 ///
  i1110398 i1110399 i1110300 i1110301 i1110302 i1110303 i1110304 ///
  i1110305 i1110306 i1110307 i1110308 i1110309 ///
  i1110484 i1110485 i1110486 i1110487 i1110488 i1110489 i1110490 ///
  i1110491 i1110492 i1110493 i1110494 i1110495 i1110496 i1110497 ///
  i1110498 i1110499 i1110400 i1110401 i1110402 i1110403 i1110404 ///
  i1110405 i1110406 i1110407 i1110408 i1110409 ///
  i1110684 i1110685 i1110686 i1110687 i1110688 i1110689 i1110690 ///
  i1110691 i1110692 i1110693 i1110694 i1110695 i1110696 i1110697 ///
  i1110698 i1110699 i1110600 i1110601 i1110602 i1110603 i1110604 ///
  i1110605 i1110606 i1110607 i1110608 i1110609 ///
  i1110784 i1110785 i1110786 i1110787 i1110788 i1110789 i1110790 ///
  i1110791 i1110792 i1110793 i1110794 i1110795 i1110796 i1110797 ///
  i1110798 i1110799 i1110700 i1110701 i1110702 i1110703 i1110704 ///
  i1110705 i1110706 i1110707 i1110708 i1110709 ///
  i1110884 i1110885 i1110886 i1110887 i1110888 i1110889 i1110890 ///
  i1110891 i1110892 i1110893 i1110894 i1110895 i1110896 i1110897 ///
  i1110898 i1110899 i1110800 i1110801 i1110802 i1110803 i1110804 ///
  i1110805 i1110806 i1110807 i1110808 i1110809 ///
  i1111084 i1111085 i1111086 i1111087 i1111088 i1111089 i1111090 ///
  i1111091 i1111092 i1111093 i1111094 i1111095 i1111096 i1111097 ///
  i1111098 i1111099 i1111000 i1111001 i1111002 i1111003 i1111004 /// 
  i1111005 i1111006 i1111007 i1111008 i1111009 ///
  i1111784 i1111785 i1111786 i1111787 i1111788 i1111789 i1111790 ///
  i1111791 i1111792 i1111793 i1111794 i1111795 i1111796 i1111797 ///
  i1111798 i1111799 i1111700 i1111701 i1111702 i1111703 i1111704 ///
  i1111705 i1111706 i1111707 i1111708 i1111709 ///
  e1110184 e1110185 e1110186 e1110187 e1110188 e1110189 e1110190 ///
  e1110191 e1110192 e1110193 e1110194 e1110195 e1110196 e1110197 ///
  e1110198 e1110199 e1110100 e1110101 e1110102 e1110103 e1110104 ///
  e1110105 e1110106 e1110107 e1110108 e1110109 ///
  , ftyp(pequiv) waves(1984/2009)

soepadd ///
  - - - - - - - - ip77 - kp83 lp89 mp75 np79 op66  /// 
  pp95 qp95 rp95 sp86 tp98 up83 vp104 wp87 xp98 yp99 zp95 /// 
  - bp7301 cp7301 dp7302 ep7002 fp8602 - hp8102 ip8102 - kp8802  /// 
  lp9402 mp8002 np8601 op7501 pp10301 qp10201 rp10201 sp10101  /// 
  tp10401 up9701 vp11001 wp10101 xp10401 yp11401 zp10101   ///
  - bp7302 cp7302 dp7303 ep7003 fp8603 - hp8103 ip8103 - kp8803  /// 
  lp9403 mp8003 np8602 op7502 pp10302 qp10202 rp10202 sp10102  /// 
  tp10402 up9702 vp11002 wp10102 xp10402 yp11402 zp10102 /// 
 - bp7303 cp7303 dp7304 ep7004 fp8604 - hp8104 ip8104 - kp8804 /// 
  lp9404 mp8004 np8501 op7401 pp102 qp101 rp101 sp100 tp103 /// 
  up96 vp109 wp100 xp103 yp113 zp100 ///
  - bp7304 cp7304 dp7305 ep7005 fp8605 - hp8105 ip8105 - kp8805  /// 
  lp9405 mp8005 np8502 op7402 - - - - - - - - - - - ///
  ap2301 bp4401 cp3501 dp3301 ep3301 -  gp36g01 /// 
  hp4701 ip4701 jp4601 kp50  lp41  mp3901 np3301 ///
  op3301 pp3602 qp3402 rp3702 sp3702 tp6302 up3402 vp3902 ///
  wp3202 xp4302 yp4202 zp3802   ///
  - bp8009 cp9109 dp9309 ep8409 fp10309 gp10309 hp10309 ///
  ip10309 jp10309 kp10309 lp10309 mp10809 np11509 ///
  op12109 pp13314 qp14214 rp13314 sp13314 tp14120 ///
  up14420 vp15320 wp14120 xp14823 yp15423 zp15623  		/// 
  , ftyp(p) waves(1984/2009)

soepadd  ///
  - - - - - nh5201 oh5201 ph5101 qh5501 rh5001  ///
  sh5001 th4901 uh4901 vh41  wh41 xh41 yh42 zh42    /// 
  - - - - - nh5202 oh5202 ph5102 qh5502 rh5002  ///
  sh5002 th4902 uh4902 vh42  wh42 xh42 yh43 zh43    /// -> Note 2
  ih5001 jh5001 kh5001 lh5101 mh5101 nh5101     ///
  oh5101 ph5201 qh5601 rh5101 sh5101 th5001 uh5001 vh5201  ///
  wh5201 xh5201 yh5301 zh5301  ///
  , ftyp(h) waves(1992/2009)

soepadd ///
  ap1a bp1a cp1a dp1a ep1a fp1a gp1a hp1a ip1a jp1a kp1a lp1a mp1a np1a ///
  op1a pp1a qp1a rp1a sp1a tp1a up1a vp1a wp1a xp1a yp1a zp1a ///
  ap1b bp1b cp1b dp1b ep1b fp1b gp1b hp1b ip1b jp1b kp1b lp1b mp1b np1b ///
  op1b pp1b qp1b rp1b sp1b tp1b up1b vp1b wp1b xp1b yp1b zp1b ///
  ap1d bp1d cp1d dp1d ep1d fp1d gp1d hp1d ip1d jp1d kp1d lp1d mp1d np1d ///
  op1d pp1d qp1d rp1d sp1d tp1d up1d vp1d wp1d xp1d yp1d zp1d ///
  -    -    -    -    -    -    -    -    ip1k jp1k kp1k lp1k -    -    ///
  -    -    -    -    -    -    -    -    -    -    -  -  /// 
, ftyp(pkal) waves(1984/2009)

// Rename
// -------

soepren egp*, new(egp) wave(1984/2009)
soepren ?famstd, new(mar) w(1984/2009)
soepren ?hhnr, new(hnr) w(1984/2009)
soepren ?netto, new(netto) w(1984/2009)
soepren i11101??, new(hhpregov) w(1984/2009)
soepren i11102??, new(hhpostgov) w(1984/2009)
soepren i11103??, new(hhlabinc) w(1984/2009)
soepren i11104??, new(hhassetinc) w(1984/2009)
soepren i11106??, new(hhprivtrans) w(1984/2009)
soepren i11107??, new(hhpubtrans) w(1984/2009)
soepren i11108??, new(hhpubpensions) w(1984/2009)
soepren i11110??, new(indlabinc) w(1984/2009)
soepren i11117??, new(hhprivpensions) w(1984/2009)
soepren e11101??, new(whours) w(1984/2009)
soepren e11106??, new(sector) w(1984/2009)
soepren y11101??, new(cpi) w(1984/2009)
soepren d11106??, new(hhsize) w(1984/2009)
soepren d11108??, new(edu) w(1984/2009)
soepren d11109??, new(yedu) w(1984/2009)
soepren h11101??, new(hhsize0to14) w(1984/2009)
soepren ?p1a, new(vollzstr) w(1984/2009)
soepren ?p1b, new(teilzstr) w(1984/2009)
soepren ?p1d, new(arblstr) w(1984/2009)
soepren ?p1k, new(kurzstr) w(1992/1995)
soepren partnr??, new(partnr) w(1984/2007)
soepren partz??, new(partz) w(1984/2007)

soepren ///
  bp8009 cp9109 dp9309 ep8409 fp10309 gp10309 hp10309 ///
  ip10309 jp10309 kp10309 lp10309 mp10809 np11509 ///
  op12109 pp13314 qp14214 rp13314 sp13314 tp14120 ///
  up14420 vp15320 wp14120 xp14823 ///
  , new(todpart) w(1985/2007)

soepren 								/// 
  ip77 kp83 lp89 mp75 np79 op66 pp95 	/// 
  qp95 rp95 sp86 tp98 up83 vp104 wp87 	/// 
  xp98 yp99 zp95 ///
  , new(shealth) waves(1992 1994/2009)

soepren 								///
  bp7301 cp7301 dp7302 ep7002 fp8602 hp8102 ip8102 kp8802  /// 
  lp9402 mp8002 np8601 op7501 pp10301 qp10201 rp10201 sp10101  /// 
  tp10401 up9701 vp11001 wp10101 xp10401 yp11401 zp10101 ///
  , new(illnot) waves(1985/1989 1991/1992 1994/2009)

soepren 								/// 
  bp7302 cp7302 dp7303 ep7003 fp8603 hp8103 ip8103 kp8803  /// 
  lp9403 mp8003 np8602 op7502 pp10302 qp10202 rp10202 sp10102  /// 
  tp10402 up9702 vp11002 wp10102 xp10402 yp11402 zp10102 ///
  , new(illdays) waves(1985/1989 1991/1992 1994/2009)

soepren 								/// 
  bp7303 cp7303 dp7304 ep7004 fp8604 	/// 
  hp8104 ip8104 kp8804 lp9404 mp8004 	/// 
  np8501 op7401 pp102 qp101 rp101 sp100 /// 
  tp103 up96 vp109 wp100 xp103 yp113 zp100 /// 
  , new(longill) waves(1985/1989 1991/1992 1994/2009)
				 
soepren 								///
  bp7304 cp7304 dp7305 ep7005 fp8605 hp8105 ip8105 kp8805  /// 
  lp9405 mp8005 np8502 op7402  /// 
  , new(illlongfreq) waves(1985/1989 1991/1992 1994/1998)

soepren ///
  nh5201 oh5201 ph5101 qh5501 rh5001  ///
  sh5001 th4901 uh4901 vh41 wh41 xh41 yh42 zh42  ///
  , new(debt) waves(1997/2009)

soepren ///
  nh5202 oh5202 ph5102 qh5502 rh5002  ///
  sh5002 th4902 uh4902 vh42 wh42 xh42 yh43 zh43  ///
  , new(debtsum) waves(1997/2008)

soepren ///
  ih5001 jh5001 kh5001 lh5101 mh5101 nh5101  ///
  oh5101 ph5201 qh5601 rh5101 sh5101 th5001  ///
  uh5001 vh5201 wh5201 xh5201 yh5301 zh5301  ///
  ,  new(reserve) waves(1992/2009)

soepren ///
  ap2301 bp4401 cp3501 dp3301 ep3301 gp36g01 /// 
  hp4701 ip4701 jp4601 kp50  lp41  mp3901 np3301 ///
  op3301 pp3602 qp3402 rp3702 sp3702 tp6302 up3402 vp3902 ///
  wp3202 xp4302  yp4202 zp3802   ///
  , new(empdur) waves(1984/1988 1990/2009)


// Reshape to long
// --------------

local stubs hnr egp hhpregov hhpostgov indlabinc whours sector mar netto ///
  hhlabinc hhassetinc hhprivtrans hhpubtrans hhpubpensions hhprivpensions  /// 
  hhsize hhsize0to14 cpi shealth illnot illdays longill illlongfreq  /// 
  debt debtsum reserve vollzstr teilzstr arblstr kurzstr edu yedu empdur ///
  partnr partz todpart

// Store variable labels for long
foreach stup of local stubs {
	macro drop _lab
	local i 1984
	while "`lab'" == "" {
		capture local lab: var lab `stup'`i++'
	}
	local lb`stup' `lab'
}

reshape long `stubs' , i(persnr) j(wave)


// Relabel the long data
foreach var of varlist `stubs' {	
	label var `var' `"`lb`var''"'
}

// Missing values
// --------------

mvdecode _all, mv(-1=.a \-2=.b \-3=.c)

// Recodings
// ---------

tsset persnr wave

// Gender
gen men:yesno = sex == 1 if !mi(sex)
lab def frau 0 "Men" 1 "Women"

// Age
gen age = wave - gebjahr

// "Race"
gen race:race = inlist(migback,2,3,4) if inrange(migback,1,4)
lab def race 0 "German" 1 "Mig. background"
drop migback

// Sector
gen industry:industry = inlist(sector,1,2,3,4,5) if inrange(sector,1,9)
label define industry 0 "Third" 1 "Industrial/Agricultural"
drop sector

// Health Indicators
gen byte ill:yesno = 0 					/// 
  if whours > 0 & !mi(whours)           /// Working force only
  & !inlist(wave,1990,1993)              // No data in 1999 + 1993
replace ill = 1 if illdays >= 5 & illdays <= 30
replace ill = 0 if longill == 1 & wave <= 1998
replace ill = 0 if inlist(longill,1,2) & wave > 1998
label variable ill "Short term illness"

gen illlong:yesno = 0 if !mi(ill) 
replace illlong = 1 if longill == 1 & wave <= 1998
replace illlong = 1 if inlist(longill,1,2) & wave > 1998
replace illlong = 1 if illdays > 30 & !mi(illdays) // As in PSID
label variable illlong "Long term illness"

gen illweeks = illdays/5
replace illweeks = 0 if illnot==1
label variable illweeks "Weeks of illness"

foreach var of varlist ill* {
	replace `var' = F1.`var' 
}

bys persnr (wave): egen sickbar = mean(shealth)
by persnr (wave): egen sicksd = sd(shealth)
gen sick = shealth > (sickbar + sicksd) if !mi(shealth)
label variable sick "Feeling sick"

drop illnot illdays sickbar sicksd longill 

// Whours
replace whours = . if whours < 0 | (whours > (7*18*365) & !mi(whours))
replace whours = whours/52
replace whours = F1.whours

// Debts y/n
replace debt = debt==1 if !mi(debt) 

// Debtsum
replace debtsum = . if debtsum < 0 & !mi(debtsum)
replace debtsum = debtsum * 1/1.95583 if wave < 2002
replace debtsum = debtsum *  (103.9/ cpi)  // Net of inflation, prices of 2007

// Reserve
replace reserve = reserve==1 if reserve < .

// Income 
// ------
// (-> Note 1)

// Basic transformations
foreach var of varlist 				/// 
  hhpregov hhpostgov indlabinc hhlabinc hhassetinc hhprivtrans 	/// 
  hhpubpensions hhprivpensions {
	replace `var' = F1.`var' 
	replace `var' = `var' * (103.9/ cpi)  // Net of inflation, prices of 2007
	replace `var' = `var' / 12            // Monats-EK
}

// Equivalent Scale
gen hhpregoveq  =  hhpregov/(1 + .5*(hhsize - hhsize0to14 - 1) + .3*hhsize0to14)
gen hhpostgoveq = hhpostgov/(1 + .5*(hhsize - hhsize0to14 - 1) + .3*hhsize0to14)

// Income Concepts
foreach var of varlist hhpregov* hhpostgov* indlab {
	gen `var'_diff1 = F1.`var' - `var' 			     // Abs Change t+1 - t
	gen `var'_diff2 = F2.`var' - `var'  		     // Abs Change t+2 - t
	
	gen `var'_ln = cond(inrange(`var',0,1),0,ln(`var'))   // Log Income
	gen `var'_lndiff1 = F1.`var'_ln - `var'_ln	   // Log Change t+1 - t
	gen `var'_lndiff2 = F2.`var'_ln - `var'_ln     // Log Change t+2 - t
	gen `var'_abslndiff1 = abs(`var'_lndiff1)      // Fields-Ok Mobility
	gen `var'_abslndiff2 = abs(`var'_lndiff2)      // Fields-Ok Mobility
}


// Unemployment
// ------------

// Change 2-digit to 1-digit
foreach var of varlist vollzstr teilzstr arblstr kurzstr {
	replace `var' = subinstr(`var', "-2" , "9" , .)
	replace `var' = subinstr(`var', "-1" , "9" , .)
	replace `var' = subinstr(`var', "00" , "0" , .)
	replace `var' = subinstr(`var', "01" , "1" , .)
	replace `var' = subinstr(`var', "08" , "9" , .)
}

// Strings in 1996/97 coded abnormally. Harmonize!
replace vollzstr=subinstr(vollzstr, "000000000009" , "000000000000" , .)  /// 
  if inrange(wave,1996,1997)
replace teilzstr=subinstr(teilzstr, "000000000009" , "000000000000" , .)  /// 
  if inrange(wave,1996,1997)

// Count month unemployed
gen unempmth = 0 
forvalues mth = 1/12 {
	replace unempmth = unempmth + 1 	/// 
	  if substr(arblstr, `mth' ,1) == "1"  /// 
	  & substr(vollzstr, `mth' ,1) == "0" ///
	  & substr(teilzstr, `mth' ,1) == "0"  /// 
	  & (substr(kurzstr, `mth' ,1) == "0" | kurzstr =="")
}

replace unempmth = F1.unempmth

drop arblstr vollzstr teilzstr kurzstr

// Work experience
replace empdur = empdur + 2000 if inrange(empdur,0,10)
replace empdur = empdur + 1900 if inrange(empdur,11,99)
replace empdur = . if empdur < gebjahr | empdur > wave  // 22 cases
replace empdur = wave - empdur
label variable empdur "Years in present job"


// Class of main worker
by wave hnr (whours), sort: gen egph:egp = egp[_N] if whours[_N] < .
replace egph = 1 if inlist(egph,1,2)
replace egph = 2 if inlist(egph,3,4)
replace egph = 3 if inlist(egph,5,6,11)
replace egph = 4 if inlist(egph,8)
replace egph = 5 if inlist(egph,9,10)
replace egph = 6 if inlist(egph,15,18) | egph > .  // Nonmatch remain missing!
label define egp 					/// 
  1 "Service class" 					/// 
  2 "Routine non-manual" 			/// 
  3 "Self empl."                 ///
  4 "Skilled worker" 				/// 
  5 "Unskilled Worker" 				/// 
  6 "Other (and missing)", modify


// Class of person
gen egpp = 1 if inlist(egp,1,2)
replace egpp = 2 if inlist(egp,3,4)
replace egpp = 3 if inlist(egp,5,6,11)
replace egpp = 4 if inlist(egp,8)
replace egpp = 5 if inlist(egp,9,10)
replace egpp = 6 if inlist(egp,15,18) | egpp > .  // Nonmatch remain missing!
drop egp

// End Matters
// -----------

compress
order hhnr hnr persnr wave netto men gebjahr age race todjahr hhsize*  /// 
  mar industry egpp egph whours unempmth edu yedu ill* sick shealth  /// 
  indlabinc* hhlabinc*  ///
  hhpregov* hhpostgov* debt* reserve
save soep2.dta, replace

exit













// Unemp-file
use persnr year mthunemp mthwork using soep, clear
ren year wave
isid persnr wave

tsset persnr wave
replace mthunemp = F1.mthunemp
replace mthwork = F1.mthwork

gen byte unempdata = 1
tempfile unempDE
save `unempDE'
		
// Family-file
use persnr wave trennung divorce using trennungDE, clear
isid persnr wave

gen byte familydata = 1

tempfile familyDE
save `familyDE'

// Health file
use persnr hhnr wave hhpostgoveq illlong netto whours age edu men ///
  using soep2 , clear
isid persnr wave
gen byte healthdata = 1

// Merge files
merge 1:1 persnr wave using `unempDE', nogen update
merge 1:1 persnr wave using `familyDE', nogen update

replace unempdata = 0 if unempdata==.
replace familydata = 0 if familydata==.
replace healthdata = 0 if healthdata==.

// Merge Weights and stuff
merge n:1 persnr using  ../../data/weights/gsoepweights  ///
  , keep(3) keepusing(weight) nogenerate

merge n:1 hhnr using $soep25/design 	///
  , keep(3) keepusing(psu) nogenerate

// Valid observations only
by persnr (wave), sort: keep if netto[_n+1]==10

// Define Poorness
gen poor=.
levelsof wave, local(K)
foreach k of local K {
	_pctile hhpostgoveq [aw=weight] if wave==`k' 
	replace poor = hhpostgoveq < (r(r1)*.6) if wave==`k' 
}

ren persnr id

order id hhnr wave weight 				/// 
  healthdata familydata unempdata whours men age edu  ///
  hhpostgoveq poor
  
compress

save joined3DE, replace

























// United States
// -------------

// Unemp-file
use id wave wkun wkwrkd using psid, clear
ren id x11101ll
isid x11101ll wave

tsset x11101ll wave
gen mthunemp = floor(F1.wkun/4.3)
gen mthwork = floor(F1.wkwrkd/4.3)
drop wkun wkwrkd

gen byte unempdata = 1

replace wave = cond(inrange(wave,1,18),1980+wave-1,1980+ wave + (wave-19)-1)
isid x11101ll wave

tempfile unempUS
save `unempUS'

// Family-file
use x11101ll wave trennung divorce using trennungUS, clear
isid x11101ll wave

replace wave = wave - 1 if wave >= 1999
gen byte familydata = 1

tempfile familyUS
save `familyUS'

// Health-file
use x11101ll x11102 wave hhpostgoveq illlong whours age edu men  ///
  using psid2, clear
isid x11101ll wave

gen byte healthdata = 1

// Merge files
merge 1:1 x11101ll wave using `unempUS', nogen
merge 1:1 x11101ll wave using `familyUS', nogen

replace unempdata = 0 if unempdata==.
replace familydata = 0 if familydata==.
replace healthdata = 0 if healthdata==.

// Merge Weights and stuff
merge n:1 x11101ll using  ../../data/weights/psidweights  ///
  , keep(3) keepusing(weight) nogenerate

ren x11101ll id

// Valid observations only
by id  (wave), sort: keep if x11102[_n+1]!=.

// Define Poorness
gen poor=.
levelsof wave, local(K)
foreach k of local K {
	_pctile hhpostgoveq [aw=weight] if wave==`k' 
	replace poor = hhpostgoveq < (r(r1)*.6) if wave==`k' 
}


order id x11102 wave weight 				/// 
  healthdata familydata unempdata whours men age edu  ///
  hhpostgoveq poor
  
compress

save joined3US, replace







Notes
-----

(1) Einkommensinfos beziehen sich auf das Vorjahr, da die Werte für 2007
im vor Release der 2008 Daten, die eigentlichen 2007er Werte aber erst
2008 erhoben werden. jeweils ein Jahr zurückverlegen Werte < 0 auf Missing
setzen (keine negativen Werte in D) 0 auf 1 setzen --> 1. für
Logarithmierung (keine negativen Werte)

(2) Question Wording changes of debtsum variable:

1997-2004: Do you have to use a certain amount of your income for
paying back loans which you took out for major purchases or other
expenses?  Please do not include loan, mortgage or interest payments
which you have already stated in previous questions.

Since 2005: Aside from debts on loans for home and property ownership,
are you currently paying back loans and interest on loans that you
took out to make large purchases or other expenditures?



