* Simuliert Datensaetze mit Wahlabsicht und Sozialstruktur, 
* auf Basis der objektiven Interessenlagen

* Note: CDU u. FDP werden zusammengefasst, da keine divergierenden
* Hypothesen vorhanden.

* 0) Intro
* --------

clear
version 6.0
tempfile simul
set seed 731              


* 1) Datenstruktur
* ----------------

* Erzeuge einen Datensatz mit den sozialen Gruppen
* Bildung, Kohorte und berufl. Stellung
* (Ich verwende Strings, um die Uebersicht zu bewahren)

input str7 bild str4 koh str19 egp
    niedrig alt "Admin. Dienste"           
    niedrig alt "Soz.D./Arbeiter"   
    niedrig alt "Arbeitgeber"       
    niedrig alt "Mischtyp/Experten"
    niedrig jung "Admin. Dienste"
    niedrig jung "Soz.D./Arbeiter"
    niedrig jung "Arbeitgeber"
    niedrig jung "Mischtyp/Experten"
    hoch alt "Admin. Dienste"
    hoch alt "Soz.D./Arbeiter"
    hoch alt "Arbeitgeber"
    hoch alt "Mischtyp/Experten"
    hoch jung "Admin. Dienste"
    hoch jung "Soz.D./Arbeiter"
    hoch jung Arbeitgeber
    hoch jung "Mischtyp/Experten"
end
lab var bild "Bildung"
lab var koh "Kohorte"
lab var egp "EGP"

* Von jeder Gruppe werden 1000 Beobachtungen gebildet
expand 1000

* Speichern
save groups, replace


* 2) Simulation
* -------------

local i 1
quietly {     /* Kein Output */
    while `i'<=1000 {   /* Tausend Wiederholungen */ 
        use groups, clear    /* Laden der Datenstruktur */

        * Systematische Komponenten
        * -------------------------

        local U = uniform()*2-1
        local Pmkons = uniform()*2-1
        local Pmspd = uniform()*2-1
        local Pwkons = uniform()*2-1
        local Pwspd = uniform()*2-1
        local Pw = uniform()*2-1  
        local Psb90 = uniform()*2-1
        local Ps = uniform()*2-1  

        * Systematischer Teil der Reduktionsfaktoren
        * ------------------------------------------

        local redukU = uniform()*2-1
        local redukM1 = uniform()*2-1
        local redukM2 = uniform()*2-1
        local redukW1 = uniform()*2-1
        local redukW2 = uniform()*2-1
        local redukS = uniform()*2-1


        * Bewertungen
        * -----------

        * Der Bewertungsraum ist 
        *
        * U_ma  U_mj
        * U_wa  U_wj
        * U_sa  U_sj
        * 
        * mit: U_sj > U_sa (Inglehart-Hypothese)
        
        gen Um  = normprob(invnorm(uniform()) + `U')
        gen Uw  = normprob(invnorm(uniform()) + `U')
        gen Us  = normprob(invnorm(uniform()) + `U') /*
        */ if koh=="jung" 
        replace Us =  normprob(invnorm(uniform()) + `U')  /*
        */ * normprob(invnorm(uniform()) + `redukU') /*
        */ if koh=="alt"
    
        * Erwartungen
        * -----------

        * Der Erwartungsraum ist 
        *
        * P_m,kons  P_w,kons  P_s,kons
        * P_m,spd   P_w,spd   P_s,spd
        * P_m,b90   P_w,b90   P_s,b90
    
        * Machtproduktion, Arbeitgeber
        * Hypothese: P_m,kons > (P_m,b90 | P_m,spd); Differenz: Zufall
        gen Pmkons = normprob(invnorm(uniform()) + `Pmkons')   /*
        */ if egp=="Arbeitgeber"
        gen Pmspd = Pmkons * normprob(invnorm(uniform()) + `redukM1') /*
        */    if egp=="Arbeitgeber" 
        gen Pmb90 = Pmkons * normprob(invnorm(uniform()) + `redukM1') /*
        */    if egp=="Arbeitgeber"

        * Machtproduktion, alle Arbeitnehmer
        * Hypothese: P_m,spd > P_m,b90 > P_m,kons; Differenz: Zufall
        replace Pmspd = normprob(invnorm(uniform()) + `Pmspd')  /*
        */  if egp ~= "Arbeitgeber"
        replace Pmb90 = Pmspd * normprob(invnorm(uniform()) + `redukM2')  /*
        */     if egp~="Arbeitgeber"
        replace Pmkons = Pmb90 * normprob(invnorm(uniform()) + `redukM2')  /*
        */    if egp~="Arbeitgeber"
    
        * Wohlstandsproduktion, Arbeitgeber, D-Admin
        * Hypothese: P_w,kons > (P_w,spd | P_w,b90); Differenz: Zufall
        gen Pwkons = normprob(invnorm(uniform()) + `Pwkons')  /*
        */ if egp=="Arbeitgeber" | egp == "Admin. Dienste"
        gen Pwspd = Pwkons * normprob(invnorm(uniform()) + `redukW1') /* 
        */    if egp =="Arbeitgeber" | egp == "Admin. Dienste"
        gen Pwb90 = Pwkons * normprob(invnorm(uniform()) + `redukW1') /* 
        */    if egp =="Arbeitgeber" | egp == "Admin. Dienste"

        * Wohlstandsproduktion,"Soz.D./Arbeiter" u. Arbeiter
        * Hypothese: P_w,spd > P_w,b90 > P_w,b90 Differenz: Zufall
        replace Pwspd = normprob(invnorm(uniform()) + `Pwspd')  /*
        */ if egp =="Soz.D./Arbeiter" 
        replace Pwb90 = Pwspd * normprob(invnorm(uniform()) + `redukW2')  /*
        */ if egp =="Soz.D./Arbeiter" 
        replace Pwkons = Pwb90 * normprob(invnorm(uniform()) + `redukW2') /*
        */     if egp =="Soz.D./Arbeiter"
    
        * Wohlstandproduktion,"Mischtyp/Experten"
        * Hypothese: P_w,spd = P_w,b90 = P_w,kons, Differenz: Zufall
        replace Pwspd = normprob(invnorm(uniform()) + `Pw')   /*
        */     if egp == "Mischtyp/Experten" 
        replace Pwb90 = normprob(invnorm(uniform()) + `Pw')   /*
        */    if egp == "Mischtyp/Experten" 
        replace Pwkons = normprob(invnorm(uniform()) + `Pw')  /*
        */     if egp == "Mischtyp/Experten"    

        * Selbstverwirklichung, hohe Bildung
        * Hypothese: P_w,b90 > (P_w,spd | P_w,kons), Differenz: Zufall
        gen Psb90 = normprob(invnorm(uniform()) + `Psb90')  /*
        */ if bil=="hoch"
        gen Psspd = Psb90 * normprob(invnorm(uniform()) + `redukS')  /*
        */ if bil=="hoch"
        gen Pskons = Psb90 * normprob(invnorm(uniform()) + `redukS')  /*
        */ if bil=="hoch"

        * Selbstverwirklichung, niedere Bildung
        * Hypothese: P_w,b90 = P_w,spd = P_w,kons, Differenz: Zufall
        replace Pskons = normprob(invnorm(uniform()) + `Ps') if bil=="niedrig"
        replace Psspd =  normprob(invnorm(uniform()) + `Ps') if bil=="niedrig"
        replace Psb90 =  normprob(invnorm(uniform()) + `Ps') if bil=="niedrig"

        * Ergebnisraum
        * ------------

        * EU = P * U
        gen EUkons = Pmkons * Um + Pwkons * Uw + Pskons * Us
        gen EUspd = Pmspd * Um + Pwspd * Us + Psspd * Us
        gen EUb90 = Pmb90 * Um + Pwb90 * Us + Psb90 * Us
        
        * Handlungsselektion
        * ------------------

        gen kons = EUkons>max(EUspd,EUb90)
        gen spd = EUspd>max(EUkons,EUb90)
        gen b90 = EUb90>max(EUspd,EUkons)


        * Aggregation nach soziostrukturellen Gruppen        
        * --------------------------------------------    

         gen n = 1
        collapse (sum) kons spd b90 (count) n, by(bild koh egp)

        * Berechnung der Anteilswerte
        * ---------------------------

        replace spd = spd/n
        replace kons = kons/n
        replace b90 = b90/n

        * Speichern der Ergebnisse
        * ------------------------

        gen sample = `i'
        gen U = normprob(`U') 
        gen Pmkons = normprob(`Pmkons') 
        gen Pmspd = normprob(`Pmspd') 
        gen Pwkons = normprob(`Pwkons') 
        gen Pwspd = normprob(`Pwspd') 
        gen Pw = normprob(`Pw') 
        gen Psb90 = `Psb90' 
        gen Ps = normprob(`Ps') 

        * Systematischer Teil der Reduktionsfaktoren
        * ------------------------------------------

        gen redukU = normprob(`redukU') 
        gen redukM1 = normprob(`redukM1') 
        gen redukM2 = normprob(`redukM2') 
        gen redukW1 = normprob(`redukW1') 
        gen redukW2 = normprob(`redukW2') 
        gen redukS = normprob(`redukS') 


        capture append using `simul'
        save `simul', replace

        * Naechste Runde
        * --------------

        local i = `i' + 1
    }
}

save simul, replace
exit
