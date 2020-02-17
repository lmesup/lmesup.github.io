
*** CREATE ***

clear
version 11

soepuse ///
	afamstd bfamstd cfamstd dfamstd efamstd ffamstd gfamstd ///
	hfamstd ifamstd jfamstd kfamstd lfamstd mfamstd nfamstd /// 
	ofamstd pfamstd qfamstd rfamstd sfamstd tfamstd ufamstd /// 
	vfamstd wfamstd xfamstd ///
	///
	partnr84 partnr85 partnr86 partnr87 partnr88 partnr89 /// 
	partnr90 partnr91 partnr92 partnr93 partnr94 partnr95 ///
	partnr96 partnr97 partnr98 partnr99 partnr00 partnr01 /// 
	partnr02 partnr03 partnr04 partnr05 partnr06 partnr07 /// 
	///
	partz84 partz85 partz86 partz87 partz88 partz89 partz90 /// 
	partz91 partz92 partz93 partz94 partz95 partz96 partz97 /// 
	partz98 partz99 partz00 partz01 partz02 partz03 partz04 /// 
	partz05 partz06 partz07 /// 
	using $soep25, ftyp(pgen) waves(1984/2007) design(any) ///

soepadd ///
	h1110184 h1110185 h1110186 h1110187 h1110188 h1110189 ///
	h1110190 h1110191 h1110192 h1110193 h1110194 h1110195 ///
	h1110196 h1110197 h1110198 h1110199 h1110100 h1110101 ///
	h1110102 h1110103 h1110104 h1110105 h1110106 h1110107 ///
	, ftyp(pequiv) waves(1984/2007)

soepadd ///
  bp8009 cp9109 dp9309 ep8409 fp10309 gp10309 hp10309 ///
  ip10309 jp10309 kp10309 lp10309 mp10809 np11509 ///
  op12109 pp13314 qp14214 rp13314 sp13314 tp14120 ///
  up14420 vp15320 wp14120 xp14823 		/// 
  ,ftyp(p) w(1985/2007) 

*** rename
soepren ?famstd, new(mar) w(1984/2007)
soepren h11101??, new(kidshh) w(1984/2007)
soepren partnr??, new(partnr) w(1984/2007)
soepren partz??, new(partz) w(1984/2007)

soepren ///
	bp8009 cp9109 dp9309 ep8409 fp10309 gp10309 hp10309 ///
	ip10309 jp10309 kp10309 lp10309 mp10809 np11509 ///
	op12109 pp13314 qp14214 rp13314 sp13314 tp14120 ///
	up14420 vp15320 wp14120 xp14823 ///
	, new(todpart) w(1985/2007)

*** reshape long
drop ?netto ?hhnr

reshape long mar kidshh partnr partz todpart 	///
  , i(persnr) j(wave)


// Familientrennung
mvdecode _all, mv(-1,-2,-3)

gen trennung = 0
by persnr (wave), sort: replace trennung = 1  /// 
  if partz==0  & inlist(partz[_n-1],1,2,9)  /// 
  & mar!=5 & kidshh[_n-1]!=0

by persnr (wave), sort: replace trennung = 1  /// 
  if inrange(partz,1,9) & partnr != partnr[_n-1] & !mi(partnr[_n-1]) /// 
  & mar!=5 & kidshh[_n-1]!=0

replace trennung = 0 if inrange(todpart,1,12)

// Scheidung

by persnr (wave): gen divorce = inlist(mar,2,4) & mar[_n-1] == 1 & kidshh[_n-1]!=0

keep persnr wave trennung divorce
save trennungDE, replace

exit
