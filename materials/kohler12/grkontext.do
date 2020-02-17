// Figure to describe the Kontext
// ------------------------------
// kohler@wzb.eu

version 11
set more off
cd $liferisks/armut/analysen
clear

// Input important welfare-state reforms
// -------------------------------------

input str2 iso str10 datestr str20 typ effect str80 name
	US 5.12.1980 Krankheit 1 "Medicare Secondary Payer Act"
	US 7.4.1986 Krankheit 1 "Consolidated Omnibus Budget Reconciliation Act"
	US 1.7.1988 Krankheit 1 "Medicare Catastrophic Coverage Act"
	US 23.11.1989 Krankheit -1 "Repeal of Medicare Catastrophic Coverage Act"
	US 20.9.1989 Krankheit -1 "Omnibus Reconciliation Act 1989"
	US 5.8.1993 Krankheit 1 "Family and Medical Leave Act"
	US 21.8.1996 Krankheit 1 "Health Insurance Portability and Accountability Act"
	US 3.9.1997 Krankheit 1 "Balanced Budget Act"
	US 8.12.2003 Krankheit 0 "Medicare Prescription Drug, Improvement, and Modernization Act"
	DE 1.1.1982 Krankheit -1 "Kostendämpfungs-ErgänzungsG"
	DE 1.1.1983 Krankheit -1 "HaushaltsbegleitG 1983"
	DE 1.1.1984 Krankheit -1 "HaushaltsbegleitG 1984"
	DE 1.1.1989 Krankheit  0 "GesundheitsreformG"
	DE 1.1.1993 Krankheit -1 "GesundheitsstrukturG"
	DE 1.1.1997 Krankheit -1 "BeitragsentlastungsG"
	DE 1.7.1997 Krankheit -1 "1./2. GKV-NeuordnungsG"
	DE 1.1.1999 Krankheit 1 "SolidaritätsstärkungsG"
	DE 29.12.1999 Krankheit 1 "G zur Reform der GKV"
	DE 1.1.2002 Krankheit -1 "Altersvermögens-ErgänzungsG"
	DE 1.1.2004 Krankheit -1 "GKV-ModernisierungsG"
	DE 1.4.2007 Krankheit 0 "GKV-WettbewerbsstärkungsG"
	US 1.7.1981 Familientrennung 1 "Omnibus Reconciliation Act 1981"
	US 13.8.1981 Familientrennung 1 "Economic Recovery Tax Act"
	US 16.8.1984 Familientrennung 1 "Child Support Enforcement Amendments"
	US 22.10.1986 Familientrennung 1 "Tax Reform Act"
	US 13.10.1988 Familientrennung 0 "Family Support Act"
	US 15.10.1990 Familientrennung 1 "Child Care and Development Block Grant Act"
	US 5.8.1993 Familientrennung 1 "Family and Medical Leave Act"
	US 1.1.1994 Familientrennung 1 "Federal Budget Act"
	US 10.8.1993 Familientrennung 1 "Omnibus Budget Reconciliation Act 1993"
	US 22.8.1996 Familientrennung 0 "Personal Responsibility and Work Opportunity Reconciliation Act"
	US 5.8.1997 Familientrennung 1 "Taxpayer Relief Act (Child Tax Credit)"
	US 24.06.1998 Familientrennung 0 "Deadbeat Parents Punishment Act"
	US 7.6.2001 Familientrennung 1 "Economic Growth and Tax Relief Reconciliation Act"
	US 28.5.2003 Familientrennung 1 "Jobs and Growth Tax Relief Reconciliation Act"
	US 4.10.2004 Familientrennung 1 "Working Families Tax Relief Act"
	US 8.2.2006 Familientrennung -1 "Deficit Reduction Act"
	DE 1.1.1980 Familientrennung 1 "UnterhaltsvorschussG"
	DE 22.12.1982 Familientrennung 1 "2. HaushaltsstrukturG"
	DE 1.1.1983 Familientrennung 1 "HaushaltsbegleitG 1983"
	DE 31.12.1986 Familientrennung 1 "BundeserziehungsgeldG"
	DE 1.1.1986 Familientrennung 1 "SteuersenkungsG"
	DE 26.6.1985 Familientrennung 1 "4. G zur Änderung des BSHG"
	DE 1.1.1987 Familientrennung 1 "SteuerreformG"
	DE 20.12.1991 Familientrennung 1 "G zur Änderung des UnterhaltsvorschussG und der UnterhaltssicherungsVO"
	DE 6.12.1991 Familientrennung 1 "2. G zur Änderung des BundeserziehungsgeldG"
	DE 27.7.1992 Familientrennung 1 "Schwangeren- und FamilienhilfeG"
	DE 1.1.1996 Familientrennung 1 "JahressteuerG"
	DE 2.11.2000 Familientrennung 1 "G Ächtung der Gewalt in der Erz. u. Änderung des Kindesunterhaltsrecht"
	DE 1.1.2001 Familientrennung -1 "3. G zur Änderung des BundeserziehungsgeldG"
	DE 1.1.2003 Familientrennung 1 "HaushaltsbegleitG 2003"
	DE 31.12.2005 Familientrennung 1 "TagesbetreuungsausbauG"
	DE 1.1.2005 Familientrennung 1 "4. G für moderne Dienstleistungen am Arbeitsmarkt"
	DE 1.10.2005 Familientrennung 1 "Kinder- und JugendhilfeweiterentwicklungsG"
	DE 1.1.2007 Familientrennung 1 "Bundeselterngeld- und ElternzeitG"
	DE 1.1.2008 Familientrennung -1 "G zur Änderung des Unterhaltsrecht"
	DE 16.12.2008 Familientrennung 1 "KinderförderungsG"
	US 9.6.1980 Verrentung -1 "SSA Amendments 1980"
	US 13.8.1981 Verrentung 1 "Economic Recovery Tax Act"
	US 29.12.1981 Verrentung 0 "SSA Amendments 1981"
	US 20.4.1983 Verrentung -1 "SSA Amendments 1983"
	US 23.8.1984 Verrentung 1 "Retirement Equity Act"
	US 22.10.1986 Verrentung 1 "Tax Reform Act"
	US 22.12.1987 Verrentung 1 "Omnibus Budget Reconciliation Act 1987"
	US 5.11.1990 Verrentung  1 "Omnibus Budget Reconciliation Act 1990"
	US 10.8.1993 Verrentung -1 "Omnibus Budget Reconciliation Act 1993"
	US 15.8.1994 Verrentung -1 "Social Security Administrative Reform Act"
	US 22.10.1994 Verrentung -1 "Social Security Domestic Act"
	US 28.3.1996 Verrentung 1 "The Contract With America Advancement Act"
	US 22.8.1996 Verrentung -1 "Personal Responsibility and Work Opportunity Reconciliation Act"
	US 20.8.1996 Verrentung 1 "The Small Business Job Protection Act"
	US 3.9.1997 Verrentung 1 "Balanced Budget Act"
	US 7.4.2000 Verrentung 1 "Senior Citizens' Freedom to Work Act"
	US 7.6.2001 Verrentung 1 "Economic Growth and Tax Relief Reconciliation Act"
	US 8.2.2006 Verrentung 1 "Deficit Reduction Act"
	US 17.8.2006 Verrentung -1 "Pension Protection Act"
	DE 1.12.1981 Verrentung 0 "G über die Anpassung der Renten der gesetzl. RV"
	DE 1.1.1982 Verrentung -1 "HaushaltsbegleitG 1982"
	DE 1.1.1983 Verrentung -1 "HaushaltsbegleitG 1983"
	DE 1.1.1984 Verrentung -1 "HaushaltsbegleitG 1984"
	DE 26.6.1985 Verrentung -1 "4. G zur Änderung des BSHG"
	DE 1.1.1986 Verrentung 0 "G zur Neuord. Hinterbliebenenrenten u. Anerk. Kindererziehungszeiten i. d. GRV"
	DE 18.12.1989 Verrentung 0 "G zur Reform der gesetzl. RV"
	DE 13.9.1996 Verrentung -1 "Wachstums- und BeschäftigungsförderungsG"
	DE 1.1.1997 Verrentung -1 "BeitragsentlastungsG"
	DE 23.6.1993 Verrentung 0 "G zur Umsetzung des Föderalen Konsolidierungsprogramms"
	DE 1.1.2000 Verrentung -1 "RentenreformG "
	DE 1.1.2001 Verrentung -1 "G zur Reform der Renten wegen verminderter Erwerbsfähigkeit"
	DE 1.1.2002 Verrentung 0 "AltersvermögensG"
	DE 1.7.2004 Verrentung -1 "RV-NachhaltigkeitsG"
	DE 1.1.2003 Verrentung  1 "G über eine bedarfsorientierte Grundsicherung im Alter"
	DE 1.1.2005 Verrentung -1 "G zur Einordnung des Sozialhilferechts in das SozialGbuch"
	DE 22.12.1982 Arbeitsplatzverlust -1 "Arbeitsförderungs-KonsolidierungsG"
	DE 22.12.1982 Arbeitsplatzverlust -1 "2. HaushaltsstrukturG"
	DE 1.1.1983 Arbeitsplatzverlust -1 "HaushaltsbegleitG 1983"
	DE 1.1.1984 Arbeitsplatzverlust -1 "HaushaltsbegleitG 1984"
	DE 1.1.1985 Arbeitsplatzverlust 1 "G zur Änderung von Vorschriften des ArbeitsförderungsG und der gesetzl. RV"
	DE 23.6.1993 Arbeitsplatzverlust -1 "G zur Umsetzung des Föderalen Konsolidierungsprogramms"
	DE 1.1.1986 Arbeitsplatzverlust 1 "7. G zur Änderung des AFG"
	DE 27.6.1987 Arbeitsplatzverlust 1 "G zur Verl. des Versicherungsschutzes bei Arbeitslosigkeit und Kurzarbeit"
	DE 1.1.1994 Arbeitsplatzverlust -1 "1./2. G zur Umsetzung des Spar-, Konsolidierungs- und Wachstumsprogramms"
	DE 1.1.1998 Arbeitsplatzverlust 0 "Arbeitsförderungs-ReformG"
	DE 31.3.2000 Arbeitsplatzverlust -1 "SGB III ÄnderungsG"
	DE 31.12.2004 Arbeitsplatzverlust -1 "G zu Reformen am Arbeitsmarkt"
	DE 1.1.2004 Arbeitsplatzverlust -1 "3. G für moderne Dienstleistungen am Arbeitsmarkt"
	DE 1.1.2005 Arbeitsplatzverlust -1 "4. G für moderne Dienstleistungen am Arbeitsmarkt"
	US 24.12.1980 Arbeitsplatzverlust -1 "Omnibus Budget Reconciliation Act 1980"
	US 13.8.1981 Arbeitsplatzverlust -1 "Omnibus Budget Reconciliation Act 1981"
	US 3.9.1982 Arbeitsplatzverlust 1 "Tax Equity and Fiscal Responsibility Act"
	US 22.10.1986 Arbeitsplatzverlust -1 "Tax Reform Act"
	US 13.10.1988 Arbeitsplatzverlust -1 "Family Support Act"
	US 10.6.1993 Arbeitsplatzverlust -1 "Unemployment Compensation Amendments"
	US 17.8.1991 Arbeitsplatzverlust 1 "Emergency Unemployment Compensation Act"
	US 3.9.1997 Arbeitsplatzverlust 0 "Balanced Budget Act"
	US 22.8.1996 Arbeitsplatzverlust -1 "Personal Responsibility and Work Opportunity Reconciliation Act"
	US 21.10.1998 Arbeitsplatzverlust 1 "Quality Housing and Work Responsibility Act"
	US 9.3.2002 Arbeitsplatzverlust 1 "Temporary Extended Unemployment Compensation Act"
	US 13.5.2002 Arbeitsplatzverlust 1 "Farm Security and Rural Investment Act"
	US 8.2.2006 Arbeitsplatzverlust -1 "Deficit Reduction Act"
end


gen date = date(datestr,"DMY")
format date %tdCY

label define typnum 4 "Arbeitsplatzverlust" 3 "Krankheit" 2 "Verrentung" 1 "Familientrennung"
encode typ, gen(typnum) label(typnum)
gen arrow = typnum + effect*.3 if effect


graph tw									/// 
  || pcarrow typnum date arrow date, lcolor(black) mcolor(black)  ///
  || sc typnum date, mcolor(black) ms(O)  			///
  || , by(iso, rows(2) note("") legend(off)) 				///
  ylabel(1/4, valuelabel angle(0)) 		///
  xtitle("") xlabel(#6) 

graph export grkontext1.eps, replace
if c(os)=="Unix" {
	!epstopdf grkontext1.eps
}

drop typ arrow datestr
egen index = group(iso name)
reshape wide effect, i(index) j(typnum)

forv i = 1/4 {
	label value effect`i' effect
}
label define effect -1 "$-$" 0 "$+/-$" 1 "$+$"


compress

format date %tdNN/YY

sort iso date name
listtex date name effect4 effect3 effect2 effect1  ///  
  if iso=="DE" using grkontextDE.tex, replace  /// 
  rstyle(tabular)  /// 
  head("\begin{tabular}{lp{8.5cm}cccc}\hline" 	///
  `"          &                  &\multicolumn{4}{c}{Wirkung des G bzgl. Risikogebiet} \\"'  ///
  `"Datum&ReformG &Arbeit&Krankheit&Rente&Familie\\\hline"') /// 
  foot("\hline\end{tabular}")


listtex date name effect4 effect3 effect2 effect1  /// 
if iso=="US" using grkontextUS.tex, replace  /// 
  rstyle(tabular)  /// 
  head("\begin{tabular}{lp{8.5cm}cccc}\hline" 	///
  `"          &                  &\multicolumn{4}{c}{Wirkung des G bzgl. Risikogebiet} \\"'  ///
  `"Datum&ReformG &Arbeit&Krankheit&Rente&Familie\\\hline"') /// 
foot("\hline\end{tabular}")


// Get Macrovars-Data
// (Source: International Monetary Fund, World Economic Outlook Database,
// October 2009)

use ../../data/MacroVars/macrovars, clear

ren ger_gdp gdpDE
ren us_gdp gdpUS
ren ger_unemp unempDE
ren us_unemp unempUS

reshape long gdp unemp, i(year) j(iso, string)

local opt lcolor(black)
graph twoway ///
  || connected gdp year, yaxis(1) `opt' ms(O)	/// 
  mcolor(black) lpattern(solid)  ///
  || connected unemp year, yaxis(2) `opt' ms(O)      ///
  mlcolor(black) mfcolor(white) lpattern(dash)  ///
  || , by(iso, rows(2) note("") 		/// 
  l1title("Veränderung BIP in % (Konstante Preise)") ///
  r1title("Arbeitslosenquote in %")) ///
  legend(order(1 "Bruttoinlandsprodukt (BIP)" 2 "Arbeitslosenquote")) ///
  xlabel(1980(5)2010) xtitle("")


graph export grkontext2.eps, replace
if c(os)=="Unix" {
	!epstopdf grkontext2.eps
}

 

