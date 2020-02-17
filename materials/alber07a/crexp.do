// Social expenditure, Pension expenditure, Tax revenues (Eurostat+OECD)
// lenarz@wzb.eu

clear
input str2 iso3166 socbrut01 socbrut04 socnet01 taxrev04 pens04
at 26.0 29.1 21.8 42.6 12.8
au 18.0    . 21.1 31.2 3.9
be 24.7 29.3 23.2 45.0 7.2 
ca 17.8    . 20.3 33.5 4.0 
ch 26.4 29.5    . 29.2 6.8 
cy    . 17.8    .    .  .
cz 20.1 19.6 18.5 38.4  7.8
de 27.4 29.5 27.6 34.7 11.3
dk 29.2 30.7 22.5 48.8  7.2
ee    . 13.4    .    .   .
es 19.6 20.0 17.0 34.8  7.9
fi 24.8 26.7 20.0 44.2  5.8
fr 28.5 31.2 27.0 43.4 10.5
gb 21.8 26.3 23.3 36.0  5.9
gr 24.3 26.0    . 35.0 11.5
hu 20.1 20.7    . 38.1  7.5
ie 13.8 17.0 12.5 30.1  2.8
is 19.8 23.0 18.4 38.7  4.1
it 24.4 26.1 21.9 41.1 11.4
jp 16.9    . 20.2 26.4  8.0
lt    . 13.3    .    .   . 
lu 20.8 22.6    . 37.8  4.5
lv    . 12.6    .    .   . 
mt    . 18.8    .    .   . 
nl 21.8 28.5 22.1 37.5  5.4
no 23.9 26.3 20.9 44.0  7.0
pl 23.0 20.0    . 34.4 11.4
pt 21.1 24.9    . 34.5  8.8 
se 29.8 32.9 26.0 50.4 10.1
si    . 24.3    .    .  .
sk 17.9 17.2 16.7 30.3  6.4
tr    .    .    . 31.3    .
us 14.7    . 23.1 25.5  5.5
end

replace iso3166 = upper(iso3166)

lab var iso3166 "ISO-3166 two-digit country codes"
lab var socbrut01 "Social expenditures (brutto) as % of GDP in 2001 (OECD)" 
lab var socbrut04 "Social expenditures (brutto) as % of GDP in 2004 (Eurostat)"
lab var socnet01  "Social expenditures (netto) as % of GDP in 2001 (OECD)"
lab var taxrev04  "Total tax revenue as % of GDP in 2004 (OECD)"
lab var pens04    "Pension expenditures as % of GDP in 2004 (Eurostat)"

note socbrut01: Adema, W; Ladaique, M (2005): Net Social Expenditure, 2005 Edition - More comprehensive measures of social support, p. 71 [Online] http://www.oecd.org/dataoecd/56/2/35632106.pdf [Feb 2007]

note socbrut04: Eurostat, [Online] http://epp.eurostat.ec.europa.eu/extraction/retrieve/de/theme3/spr/spr_exp_sum?OutputDir=EJOutputDir_1068&user=unknown&clientsessionid=8CAD700C5BA384FC8BA8AE102C18C885.extraction-worker-1&OutputFile=spr_exp_sum.htm&OutputMode=U&NumberOfCells=28&Language=de&OutputMime=text%2Fhtml& [Feb 2007]

note socnet01: Adema, W; Ladaique, M (2005): Net Social Expenditure, 2005 Edition - More comprehensive measures of social support, p. 71 [Online] http://www.oecd.org/dataoecd/56/2/35632106.pdf [Feb 2007]

note taxrev04: Source: OECD (2006): Revenue Statistics 1965-2005, Tab. A. 

note pens04: http://stats.oecd.org/wbos/default.aspx?datasetcode=SOCX_AGG


	sort iso3166
save exp, replace

exit



Zu den Angaben zu net social spending (Adema/Ladaique 2005: 70):
"As the construction of net social spending indicators involves
adjusting for indirect taxation of consumption out of benefit income,
net social expenditure is related to GDP at factor cost, as GDP at
factor costs does not include the value of indirect taxation and
government subsidies to private enterprises and public
corporations. However, in order to facilitate comparison with gross
social spending indicators which are usually related to GDP at market
prices for international comparisons, Table A3.1 presents these
indicators.  As domestic product includes income that accrues to
foreigners, it may be argued that national income is another
appropriate measure.  As net transfers to foreigners should be
measured (foreign aid is often net of tax) and capital stock
depreciation arguably should not be used to finance tax payments,
Table A3.2 relates the net spending indicators to Net Disposable
National Income at factor prices."


