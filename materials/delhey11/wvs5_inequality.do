* WVS 5, 2005/06
* paper on happiness inequality 
* based on ISQOLS presentation
***********************************************************************

use "wvs5ab.dta", clear

drop v4-v9
drop v12-v21
drop v34-v43y
drop v44-v54
drop v107-v113
drop v210-v214
drop v223-v230
drop v152-v162
drop v165-v174
drop v24-v33
drop v69-v89
drop v90-v209
drop v55-v67
drop v217-v234

set more off
* numlabel _all, add


* life satisfaction
generate lifesat=v22
label variable lifesat "life satisfaction 1-10"

* life satisfaction als prozent variable
generate lifep=.
replace lifep=100 if v22==10
replace lifep=88 if v22==9
replace lifep=77 if v22==8
replace lifep=66 if v22==7
replace lifep=55 if v22==6
replace lifep=44 if v22==5
replace lifep=33 if v22==4
replace lifep=22 if v22==3
replace lifep=11 if v22==2
replace lifep=0 if v22==1
label variable lifep "life satisfaction 0-100"

* feeling happy
generate happy=v10
replace happy = 10 if v10==1
replace happy = 7 if v10==2
replace happy = 4 if v10==3
replace happy = 1 if v10==4
label variable happy "feeling happy 1-10"

* feeling happy als prozent variable
generate happyp=.
replace happyp = 100 if v10==1
replace happyp = 66 if v10==2
replace happyp = 33 if v10==3
replace happyp = 0 if v10==4
label variable happyp "feeling happy 0-100"

* satisfaction with financial situation of household
generate satinc=v68
label variable satinc "income satisfaction 1-10"

* satisfaction with financial situation of household als prozent variable
generate satincp=.
replace satincp=100 if v68==10
replace satincp=88 if v68==9
replace satincp=77 if v68==8
replace satincp=66 if v68==7
replace satincp=55 if v68==6
replace satincp=44 if v68==5
replace satincp=33 if v68==4
replace satincp=22 if v68==3
replace satincp=11 if v68==2
replace satincp=0 if v68==1
label variable satinc "income satisfaction 0-100"


********************************************************************************************
* Länderkürzel als string variable bilden
* Quelle http://www.worldatlas.com/aatlas/ctycodes.htm
set more off
generate str country = ""
replace country = "FRA" if v2a==1
replace country = "GBR" if v2a==2
replace country = "ITA" if v2a==4
replace country = "NLD" if v2a==5
replace country = "ESP" if v2a==8
replace country = "USA" if v2a==11
replace country = "JPN" if v2a==13
replace country = "MEX" if v2a==14
replace country = "ZAF" if v2a==15
replace country = "AUS" if v2a==17
replace country = "SWE" if v2a==19
replace country = "ARG" if v2a==22
replace country = "FIN" if v2a==23
replace country = "KOR" if v2a==24
replace country = "POL" if v2a==25
replace country = "CHE" if v2a==26
replace country = "BRA" if v2a==28
replace country = "CHL" if v2a==30
replace country = "IND" if v2a==32
replace country = "SVN" if v2a==35
replace country = "BGR" if v2a==36
replace country = "ROM" if v2a==37
replace country = "CHN" if v2a==39
replace country = "TWN" if v2a==40
replace country = "TUR" if v2a==44
replace country = "UKR" if v2a==49
replace country = "RUS" if v2a==50
replace country = "PER" if v2a==51
replace country = "GHA" if v2a==56
replace country = "MDA" if v2a==61
replace country = "THA" if v2a==65
replace country = "IDN" if v2a==70
replace country = "VNM" if v2a==71
replace country = "COL" if v2a==73
replace country = "YUG" if v2a==81
replace country = "NZL" if v2a==88
replace country = "EGY" if v2a==89
replace country = "MAR" if v2a==90
replace country = "IRN" if v2a==91
replace country = "JOR" if v2a==92
replace country = "CYP" if v2a==95
replace country = "IRQ" if v2a==97
replace country = "HKG" if v2a==104
replace country = "TTO" if v2a==105
replace country = "AND" if v2a==108
replace country = "MYS" if v2a==109
replace country = "BFA" if v2a==110
replace country = "ETH" if v2a==111
replace country = "MLI" if v2a==112
replace country = "RWA" if v2a==113
replace country = "ZMB" if v2a==114
replace country = "DEU" if v2a==276

generate str ctryname = ""
replace ctryname = "France" if v2a==1
replace ctryname = "Great Britain" if v2a==2
replace ctryname = "Italy" if v2a==4
replace ctryname = "Netherlands" if v2a==5
replace ctryname = "Spain" if v2a==8
replace ctryname = "United States" if v2a==11
replace ctryname = "Japan" if v2a==13
replace ctryname = "Mexico" if v2a==14
replace ctryname = "South Africa" if v2a==15
replace ctryname = "Australia" if v2a==17
replace ctryname = "Sweden" if v2a==19
replace ctryname = "Argentina" if v2a==22
replace ctryname = "Finland" if v2a==23
replace ctryname = "South Korea" if v2a==24
replace ctryname = "Poland" if v2a==25
replace ctryname = "Switzerland" if v2a==26
replace ctryname = "Brazil" if v2a==28
replace ctryname = "Chile" if v2a==30
replace ctryname = "India" if v2a==32
replace ctryname = "Slovenia" if v2a==35
replace ctryname = "Bulgaria" if v2a==36
replace ctryname = "Romania" if v2a==37
replace ctryname = "China" if v2a==39
replace ctryname = "Taiwan" if v2a==40
replace ctryname = "Turkey" if v2a==44
replace ctryname = "Ukraine" if v2a==49
replace ctryname = "Russia" if v2a==50
replace ctryname = "Peru" if v2a==51
replace ctryname = "Ghana" if v2a==56
replace ctryname = "Moldova" if v2a==61
replace ctryname = "Thailand" if v2a==65
replace ctryname = "Indonesia" if v2a==70
replace ctryname = "Vietnam" if v2a==71
replace ctryname = "Colombia" if v2a==73
replace ctryname = "Serbia" if v2a==81
replace ctryname = "New Zealand" if v2a==88
replace ctryname = "Egypt" if v2a==89
replace ctryname = "Morocco" if v2a==90
replace ctryname = "Iran" if v2a==91
replace ctryname = "Jordan" if v2a==92
replace ctryname = "Cyprus" if v2a==95
replace ctryname = "Iraq" if v2a==97
replace ctryname = "Hong Kong" if v2a==104
replace ctryname = "Trinidad&Tob." if v2a==105
replace ctryname = "Andorra" if v2a==108
replace ctryname = "Malaysia" if v2a==109
replace ctryname = "Burkina Faso" if v2a==110
replace ctryname = "Ethiopia" if v2a==111
replace ctryname = "Mali" if v2a==112
replace ctryname = "Rwanda" if v2a==113
replace ctryname = "Zambia" if v2a==114
replace ctryname = "Germany" if v2a==276

generate sdlife=lifep
generate sdhappy=happyp
generate sdinc=satincp

collapse (mean) lifesat happy satinc lifep happyp satincp (sd) sdlife sdhappy sdinc, by(ctryname)

**** coefficient of variance berechnen aus aggregierten Daten
generate covlife = sdlife/lifep
generate covhappy = sdhappy/happyp
generate covinc = sdinc/satincp

********************************************************************
*** residual approach für life satisfaction 0-100, allgemeine Formel 
*** standard deviation
regress sdlife lifep
predict gap 
generate nenn=(sdlife-gap)

sum sdlife
generate diff=((sdlife-r(mean))*(sdlife-r(mean)))/r(N)
sum diff
generate teil=sqrt(r(sum))

generate excess=nenn/teil
generate exsdlife=excess
drop gap diff nenn teil excess

********************************************************************
*** residual approach für life satisfaction 0-100, allgemeine Formel 
*** coefficient of variation
regress covlife lifep
predict gap 
generate nenn=(covlife-gap)

sum covlife
generate diff=((covlife-r(mean))*(covlife-r(mean)))/r(N)
sum diff
generate teil=sqrt(r(sum))

generate excess=nenn/teil
generate excovlife=excess
drop gap diff nenn teil excess

********************************************************************
*** residual approach für happiness 0-100, allgemeine Formel 
*** standard deviation
regress sdhappy happyp
predict gap 
generate nenn=(sdhappy-gap)

sum sdhappy
generate diff=((sdhappy-r(mean))*(sdhappy-r(mean)))/r(N)
sum diff
generate teil=sqrt(r(sum))

generate excess=nenn/teil
generate exsdhappy=excess
drop gap diff nenn teil excess


**********************************************************************
*** difference between gross and net happiness inequality

spearman sdlife exsdlife, stats(obs p) pw
egen ranksd = rank(sdlife)
egen rankexsd = rank(exsdlife)
generate change1 = ranksd - rankexsd

set scheme economist
graph dot change1, over(ctryname, sort(change1)) ///
subtitle("rank change, net inequality against gross") ///
ytitle("- = more unequal, + = more equal") ///
caption("Data: WVS5ab; do-file: wvs5_inequality") ///
xsize(3) ysize(8) yline(0)

graph export "change.eps", replace


*******************************************************************
* Test for dependence on mean
pwcorr sdlife lifep, sig
pwcorr exsdlife lifep, sig

pwcorr covlife lifep, sig
pwcorr excovlife lifep, sig

****************************************************************************************************************
*** jetzt die country data dazu spielen
sort ctryname
save myusing, replace
use "wvs5countrydata.dta", clear
sort ctryname
merge ctryname using myusing
erase myusing.dta

**********************************************
* conditioning grafiken, level vs. inequality 
set scheme economist
scatter sdlife lifep, ///
subtitle("gross inequality approach (as observed)") ///
ytitle("gross happiness inequality") ///
xtitle("average happiness") ///
caption("Data: WVS5ab; do-file: wvs5_inequality") ///
xsize(4.5) ysize(4.5) ///
mlabel(country) mlabposition(12) mlabcolor(black) mlabsize(vsmall) msize(vsmall)
graph export "depgross.eps", replace

set scheme economist
scatter exsdlife lifep, ///
subtitle("gross inequality approach (residuals)") ///
ytitle("net happiness inequality") ///
xtitle("average happiness") ///
caption("Data: WVS5ab; do-file: wvs5_inequality") ///
xsize(4.5) ysize(4.5) ///
mlabel(country) mlabposition(12) mlabcolor(black) mlabsize(vsmall) msize(vsmall)
graph export "depnet.eps", replace


*********************************************************************
* correlates of life satisfaction inequality

generate poplog = log(pop2005)
generate gdp00log = log(gdp2000)
generate gdp05log = log(gdp2005)
generate ppp05log = log(ppp2005)

pwcorr sdlife gini2005 ppp05log, sig
pwcorr exsdlife gini2005 ppp05log, sig

set scheme economist
tw (lfit sdlife gini2005) /// 
	(scatter sdlife gini2005 ///
	, jitter(2) mlabel(country) mlabposition(12) mlabcolor(black) mlabsize(vsmall) msize(vsmall)) ///
	, subtitle("net approach (r = .26; p = .07)") xtitle("gini income inequality") ytitle("gross happiness inequality") legend(off)  ///
     xsize(4.5) ysize(4.5) ylabel(,grid angle(0) glpattern(line) glcolor(black)) ///
	caption("Data: WVS5ab; do-file: wvs5_inequality")
graph export "ginigross.eps", replace

set scheme economist
tw (lfit exsdlife gini2005) /// 
	(scatter exsdlife gini2005 ///
	, jitter(2) mlabel(country) mlabposition(12) mlabcolor(black) mlabsize(vsmall) msize(vsmall)) ///
	, subtitle("net approach (r = .39; p = .005)") xtitle("gini income inequality") ytitle("net happiness inequality") legend(off)  ///
     xsize(4.5) ysize(4.5) ylabel(,grid angle(0) glpattern(line) glcolor(black)) ///
	caption("Data: WVS5ab; do-file: wvs5_inequality")
graph export "gininet.eps", replace

regress sdlife gini2005 ppp05log 
estimates store m1
regress exsdlife gini2005 ppp05log 
estimates store m2
estout m1 m2 using "regr1.txt" ///
    , cells(b(star fmt(%9.3f)) t(par fmt(%9.2f))) stats(r2 N) style(tab) starlevel(* .1 ** .05 *** .01 **** .001) replace 

********************************************************************* 
* Test für anderes inequality mass, cov
pwcorr covlife gini2005 ppp05log, sig
pwcorr excovlife gini2005 ppp05log, sig

regress covlife gini2005 ppp05log 
estimates store m11
regress excovlife gini2005 ppp05log 
estimates store m12
estout m11 m12 using "regr2.txt" ///
    , cells(b(star fmt(%9.3f)) t(par fmt(%9.2f))) stats(r2 N) style(tab) starlevel(* .1 ** .05 *** .01 **** .001) replace 

******************************************************************** 
* Test für anderes happiness mass, feeling happy
pwcorr sdhappy gini2005 ppp05log, sig
pwcorr exsdhappy gini2005 ppp05log, sig

regress sdhappy gini2005 ppp05log 
estimates store m21
regress exsdhappy gini2005 ppp05log 
estimates store m22
estout m21 m22 using "regr3.txt" ///
    , cells(b(star fmt(%9.3f)) t(par fmt(%9.2f))) stats(r2 N) style(tab) starlevel(* .1 ** .05 *** .01 **** .001) replace 

********************************************************************
* Unterschiedlicher Effekt für OECD?
* dazu residual approach für life satisfaction 0-100, allgemeine Formel, stdev, nur für OECD
regress sdlife lifep if wregion==1
predict gap 
generate nenn=(sdlife-gap) if wregion==1

sum sdlife if wregion==1
generate diff=((sdlife-r(mean))*(sdlife-r(mean)))/r(N) if wregion==1
sum diff if wregion==1
generate teil=sqrt(r(sum)) if wregion==1

generate excess=nenn/teil if wregion==1
generate exOECD=excess if wregion==1
drop gap diff nenn teil excess

* dann für nicht-OECD
regress sdlife lifep if wregion>1
predict gap 
generate nenn=(sdlife-gap) if wregion>1

sum sdlife if wregion>1
generate diff=((sdlife-r(mean))*(sdlife-r(mean)))/r(N) if wregion>1
sum diff if wregion>1
generate teil=sqrt(r(sum)) if wregion>1

generate excess=nenn/teil if wregion>1
generate exnoOECD=excess if wregion>1
drop gap diff nenn teil excess

pwcorr exOECD gini2005 ppp05log, sig
pwcorr exnoOECD gini2005 ppp05log, sig

************************************************************************
* andere determinants of happiness inequality?
pwcorr sdlife gini2005 efrac GEM2005 gendinc freedom2005 peace2008 ppp05log, sig
pwcorr exsdlife gini2005 efrac GEM2005 gendinc freedom2005 peace2008 ppp05log, sig

