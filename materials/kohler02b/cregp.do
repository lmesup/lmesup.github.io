* Erzeugung EGP-Klassenschema

version 5.0
clear
set memory 60m
* -----------------------------RETRIVAL-----------------------------------
#delimit ;
mkdat
bstb84 bstb85 bstb86 bstb87 bstb88 bstb89 bstb90 bstb91 bstb92 bstb93
 bstb94 bstb95 bstb96 bstb97
bsth84 bsth85 bsth86 bsth87 bsth88 bsth89 bsth90 bsth91 bsth92 bsth93
 bsth94 bsth95 bsth96 bsth97
bstp84 bstp85 bstp86 bstp87 bstp88 bstp89 bstp90 bstp91 bstp92 bstp93
 bstp94 bstp95 bstp96 bstp97
bstt84 bstt85 bstt86 bstt87 bstt88 bstt89 bstt90 bstt91 bstt92 bstt93
 bstt94 bstt95 bstt96 bstt97
iscb84 iscb85 iscb86 iscb87 iscb88 iscb89 iscb90 iscb91 iscb92 iscb93
 iscb94 iscb95 iscb96 iscb97
isch84 isch85 isch86 isch87 isch88 isch89 isch90 isch91 isch92 isch93
 isch94 isch95 isch96 isch97
iscp84 iscp85 iscp86 iscp87 iscp88 iscp89 iscp90 iscp91 iscp92 iscp93
 iscp94 iscp95 iscp96 iscp97
isct84 isct85 isct86 isct87 isct88 isct89 isct90 isct91 isct92 isct93
 isct94 isct95 isct96 isct97
using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)
netto(-3,-2,1,0,1,2,3,4) ;
#delimit cr

*--------------ZUORDUNG KLASSEN (analog zu Mueller/Haun 1994)--------------
* Basis: Schema von Stefan Bender, modifiziert und ergaenzt von Dietmar Haun
* Stata-Do-File und Einordnungsberufe Ulrich Kohler

capture program drop egp
program define egp
while "`1'" ~= "" {
 local i 84
 while `i' <= 97 {
  local bst "bst`1'`i'"
  local isc "isc`1'`i'"
  local egp "egp`1'`i'"
  noi di "Erzeugung von `egp'"
  gen `egp' = `isc' if `isc'> 0
  replace `egp' = -97 if `isc' == .  /* <- Non-matchs */
  replace `egp' = -98 if `isc' == -2 /* <- TNZ */
  replace `egp' = -99 if `isc' == -1 /* k.A. */

  * +----------------------------------------------------------+
  * | -1-                     Dienstklasse I                   |
  * |           Obere u. mittlere Raenge der Dienstklasse      |
  * | (hoehere und mittlere Raenge der akad. Berufe, der Ver-  |
  * |     waltungs und Managementberufe; Grossunternehmer)     |
  * +----------------------------------------------------------+

  * Freie Berufe, selbstaendige Akademiker
  replace `egp' = -1 if `bst' == 15 & (`isc' ~= 34 & `isc' ~= 531)

  * Sonstige Selbstaendige < 10/Selb. Landwirte/Freie Berufe, selb. Akademiker
  recode `egp' 21 22 24 61 63 67 110 129 161 171 192 = -1 /*
  */ if `bst' >= 10 & `bst' <=21

  * Sonstige Selbstaendige < 10
  recode `egp' 23 28 121 159 = -1 /*
  */ if `bst' == 21

  * Sonstige Selbstaendige > 9
  */ recode `egp' 11/29 41 61 63/65 81/132 159 174 195 199 201/219 /*
  */              400 410 432 441 500 = -1 /*
  */ if `bst' == 23

  * Beamte (mittlerer Dienst)
  replace `egp' = -1 /*
  */ if `bst' == 41 & `isc' == 201

  * Beamte (gehobener Dienst)
  recode `egp' 11/61 63/67 81/132 195 199 201/219 = -1 /*
  */ if `bst' == 42

  * Beamte (hoeherer Dienst)
  replace `egp' = -1 /*
  */ if `bst' == 43

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 61 63/65 67 90/132 202/219  = -1 /*
  */ if `bst' == 51

  * Angestellte mit qualifizierter Taetigkeit
  recode `egp' 61 67  = -1 if `bst' == 52

  * Angestellte mit hochqualifizierter Taetigkeit
  recode `egp' 1 11 12 14 21/29 31 41 51 52 53 61 63 65 67 69 75 81 82 83 /*
  */           90 121 129 131  132 159 192 195 201/219 300 = -1 /*
  */ if `bst' == 53

  * Angestellte mit umfassenden Fuehrungsaufgaben
  replace `egp' = -1 /*
  */ if `bst' == 54 & (`isc' ~= 700 & `isc' ~= 924)

  * Auszubildende/Praktikanten
  recode `egp' 31 122 129 132 141 161 191 = -1 /*
  */ if `bst' == 70

  * +----------------------------------------------------------+
  * | -2-                     Dienstklasse II                  |
  * |                Niedere Raenge der Dienstklasse           |
  * +----------------------------------------------------------+

  * Sonstige Selbstaendige < 10/Selb. Landwirte/Freie Berufe, selb. Akademiker
  recode `egp' 71 73 76 193 199 432 = -2 /*
  */ if `bst' >= 10 & `bst' <=21

  * Sonstige Selbstaendige < 10
  replace `egp' = -2 /*
  */ if `bst' == 21 & `isc' == 75

  * Sonstige Selbstaendige > 9
  replace `egp' = -2 /*
  */ if `bst' == 23 & (`isc' == 442 | `isc' == 443)

  * Mithelfende Familienangehoerige
  recode `egp' 211/219 = -2 /*
  */ if `bst' == 30

  * Beamte (einfacher Dienst)
  replace `egp' = -2 /*
  */ if `bst' == 40 & `isc' == 132

  * Beamte (mittlerer Dienst)
  recode `egp' 11 13 14 28 29 31 41 71 84 110 132 133 134 135 139 141 /*
  */    171 180 191 193 194 331 339 351 352 359 422 431 582 = -2 /*
  */ if `bst' == 41

  * Beamte (gehobener Dienst)
  replace `egp' = -2 /*
  */ if `bst' == 42 & (`isc' ~= 627 & `isc' ~= 632 & `isc' ~= 700  & /*
  */                   `isc' ~= 811 & `isc' ~= 841 & `isc' ~= 849  & /*
  */                   `isc' ~= 856 & `isc' ~= 922 & `isc' ~= 983) & /*
  */                   `egp' >0

  * Industrie- und Werkmeister im Angestelltenverhaeltniss
  recode `egp' 67 71 193 194 300 400 = -2 /*
  */ if `bst' == 50

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 21 31 32 69 71 76 77 134 139 159 171 193 194 195 /*
  */           199 219 300 = -2 /*
  */ if `bst' == 51

  * Angestellte mit qualifizierter Taetigkeit
 recode `egp' 11 13 14 21/25 28 29 31 38 41 42 43 51 52 53 54 62 64 65 /*
 */           66 68 69 71 73 75 76 77 79 81 82 83 84 90 110 129 131 132 /*
 */           133 134 135 139 141 149 159 171/199 199 201/219 300 310 331 /*
 */           339 341 342 351 352 359 392 400/431 441 442 500 581 582 589 /*
 */           600 = -2 /*
 */ if `bst' == 52

  * Angestellte mit hochqualifizierter Taetigkeit
  recode `egp' 2 13 32/36 38 39 42 43 54 62 66 68 71 72 73 74 76 /*
  */          77 84 110 133 134 135 139 141 149 162 163 171 173 174 180 /*
  */          191 193 194 199 212 310 321 322 331 339 342 351 352 359 370 /*
  */          380 391/394 399 400 410 421 422 431 432 441 442 451 500 510 /*
  */          520 531 532 540 551 570 581 582 589 591 592 599 600 611 621 /*
  */          622 626 627 632 700 711 713 728 734 771 773 775 776 777 791 /*
  */          793 795 796 801 803 811 819 820 832 839 841 842 843 849 851 /*
  */          852 853 854 855 856 857 859 861 862 871 873 880 921 922 924 /*
  */          925 927 931 949 951 954 959 969 971 974 982 983 984 985 989 = -2 /*
  */ if `bst' == 53

  * Angestellte mit umfassenden Fuehrungsaufgaben
  replace `egp' = -2 /*
  */ if `bst' == 54 & (`isc' == 700 | `isc' == 924)

  * Angelernte Arbeiter
  replace `egp' = -2 /*
  */ if `bst' == 61 & (`isc' == 132 | `isc' == 139)

  * Gelernte Arbeiter und Facharbeiter
  recode `egp' 21 42 71 133 194 352 400 500 = -2 /*
  */ if `bst' == 62

  * Vorarbeiter, Kolonnenfhrer
  replace `egp' = -2 /*
  */ if `bst' == 63 & (`isc' == 194 | `isc' == 500)

  * Meister, Polier
  recode `egp' 201/219 300 395 = -2 /*
  */ if `bst' == 64

  * Auszubildende/Praktikanten
  recode `egp' 2 67 76 133 180 193 339 342 = -2 /*
  */ if `bst' == 70

  * +----------------------------------------------------------+
  * | -3-  Nicht-manuelle Berufe mit Routinetaetigkeiten       |
  * |         (Bueroberufe, auch Verkaufsberufe)               |
  * +----------------------------------------------------------+

  * Beamte (einfacher Dienst)
  replace `egp' = -3 /*
  */ if `bst' == 40 & (`isc' ~= 360 & `isc' ~= 370 & `isc' ~= 581 & /*
  */                   `isc' ~= 582 & `isc' ~= 589 & `isc' ~= 632 & /*
  */                   `isc' ~= 776 & `isc' ~= 833 & `isc' ~= 841 & /*
  */                   `isc' ~= 851 & `isc' ~= 856 & `isc' ~= 872 & /*
  */                   `isc' ~= 873 & `isc' ~= 969 & `isc' ~= 983 & /*
  */                   `isc' ~= 984 & `isc' ~= 985 & `isc' ~= 989 & /*
  */                   `isc' ~= 999 & `isc' ~= 700 & `isc' ~= 132 & /*
  */                   `egp' >0 )

  * Beamte (mittlerer Dienst)
  recode `egp' 310 341 342 380 391 393 394 592 = -3  /*
    */ if `bst' == 41

  * Industrie- und Werkmeister im Angestelltenverhaeltnis
  recode `egp' 321 331 339 393 394 395 451 = -3 /*
  */ if `bst' == 50

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 14 68 72 74 193 310 321 322 331 339 341 342 352 380 391 /*
  */          392 393 394 395 399 400 410 421 422 431 432 441 442 500 /*
  */          510 520 551 = -3 /*
  */ if `bst' == 51

  * Angestellte mit qualifizierter Taetigkeit
  recode `egp' 72 321 322 380 391 393 394 395 399 410 432 451 510 551 = -3 /*
  */ if `bst' == 52

  * Ungelernte Arbeiter
  recode `egp' 11/443 = -3 /*
  */ if `bst' == 60

  * Angelernte Arbeiter
  recode `egp' 2 71 76 193 194 300/399 451/490 = -3 /*
  */ if `bst' == 61

  * Gelernte Arbeiter und Facharbeiter
  recode `egp' 72 79 193 300 310 331 339 342 380 422 432 = -3 /*
  */ if `bst' == 62

  * Auszubildende/Praktikanten
  recode `egp' 310 331 393 394 451 582 599 = -3 /*
  */ if `bst' == 70

  * +----------------------------------------------------------+
  * | -4-  Selbstaendige mit ueber 9 Mitarabeiter              |
  * +----------------------------------------------------------+

  * Freie Berufe, selbstaendige Akademiker
  replace `egp' = -4 /*
  */ if `bst' == 15 & (`isc' == 34 | `isc' == 531)

  * Sonstige Selbstaendige > 10
  replace `egp' = -4 /*
  */ if `bst' == 23 & `isc' ~= 1 & `isc' ~= 2 & `egp' > 0

  * Mithelfende Familienangehoehrige
  recode `egp' 300/599 700/999 1004 = -4 /*
  */ if `bst' == 30

  * +----------------------------------------------------------+
  * | -5-  Kleine Selbstaendige mit hoechstens 9 Mitarbeitern  |
  * +----------------------------------------------------------+

  * NOTE: Teile von `egp' = 5 werden unten auf Code 6 gesetzt

  * Sonstige Selbstaendige < 10
  replace `egp' = -5 /*
  */ if `bst' == 21 & `isc' ~= 1 & `isc' ~= 2 & `egp'> 0

  * Mithfelfende Familienangehoehrige
  replace `egp' = -5 /*
  */ if `bst' == 30 & `isc' ~= 1 & `isc' ~= 2 & `isc' ~=4 & `egp'>0

  * +----------------------------------------------------------+
  * | -6-           Selbstaendige Landwirte                    |
  * +----------------------------------------------------------+

  * Selbstaendige Landwirte
  replace `egp' = -6 /*
  */ if `bst' == 10 & `isc' ~= 621 & `egp'> 0

  * Sonstige Selbstaendige < 10/Freie Berufe, selbstaendige Akademiker
  replace `egp' = -6 /*                                     egp=5 -> egp=6
  */ if (`bst' == 15 | `bst' == 21) & (`isc' >= 600 & `isc' <= 649)

  * Mithelfende Familienangehoerige
  replace `egp'  = -6 /*
    */ if `bst' == 30 &  `isc' >= 600 & `isc' <= 649

  * +----------------------------------------------------------+
  * | -7-  Techniker; Aufsichtskraefte im manuellen Bereich    |
  * |                (Vorarbeiter, Meister)                    |
  * +----------------------------------------------------------+

  * Beamte (einfacher Dienst)
  replace `egp' = -7 /*
  */ if `bst' == 40 & `isc' == 700

  * Beamte (mittlerer Dienst)
  recode `egp' 1 2 21 33 34 35 39 360 370 392 520 531 532 581 589 611 621 /*
  */         627 632 649 700 811 819 841 842 843 852 855 856 857 873 874 /*
  */         931 949 951 954 969 971 981 983 984 985 986 989 = -7  /*
  */ if `bst' == 41

  * Beamte (hoeherer Dienst)
  recode `egp' 627 632 700 811 841 849 856 922 983 = -7 /*
  */ if `bst' == 42

  * Industrie- und Werkmeister im Angestelltenverhaeltnis
  * Note: entg. Vorschlag 599 (statt 11) und 985 (statt 8) Klasse 7 zugewiesen
  replace `egp' = -7 /*
  */ if `bst'==50 & (`isc' ~=  67 & `isc' ~=  71 & `isc' ~= 193 & /*
  */                 `isc' ~= 194 & `isc' ~= 300 & `isc' ~= 400 & /*
  */                 `isc' ~= 321 & `isc' ~= 331 & `isc' ~= 339 & /*
  */                 `isc' ~= 393 & `isc' ~= 394 & `isc' ~= 395 & /*
  */                 `isc' ~= 451 & `egp' > 0 )

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 33 34 35 38 39 54 75 162 163 700 901 = -7 /*
  */ if `bst' == 51

  * Angestellte mit qualifizierter Taetigkeit
  recode `egp' 1 2 32/36 39 162 163 360 370 452 520 531 532 560 570 700 /*
  */ 711 726 744 749 754 773 775 776 778 791 793 794 795 796 811 713 801 /*
  */ 832 833 841 842 843 844 849 851/856 859 861 862 871 873 874 880 891 /*
  */ 895 921 922 923 924 925 926 927 931 939 941 949 951 954 959 961 969 /*
  */ 971 973 981 982 983 984 985 989 = -7 /*
  */ if `bst' == 52

  * Ungelernter Arbeiter
  replace `egp' = -7 /*
  */ if `bst' == 60 & (`isc' == 2 | `isc' == 700 )

  * Angelernter Arbeiter
  replace `egp' = -7 /*
  */ if `bst' == 61 & (`isc' == 2 | `isc' == 700 )

  * Gelernte und Facharbeiter
  recode `egp' 11 32 33 34 35 52 64 84 359 700 = -7/*
  */ if `bst' == 62

  * Vorarbeiter, Kolonnenfhrer
  replace `egp' = -7 /*
  */ if `bst' == 63 & (`isc' ~= 194 & `isc' ~= 500 & `isc' ~= 452 & /*
  */                   `isc' ~= 999 & `egp' > 0)

  * Meister, Polier
  replace `egp' = -7 /*
  */ if `bst' == 64 & `isc' ~= 2 & `egp'> 0

  * Auszubildende/Praktikanten
  recode `egp' 32 34 35 71 72 75 734 = -7 /*
  */ if `bst' == 70

  * +----------------------------------------------------------+
  * | -8-               Facharbeiter                           |
  * +----------------------------------------------------------+

  * Beamte (einfacher Dienst)
  recode `egp' 1 360 370 581 582 589 632 776 833 841 851 856 872 873 969 /*
  */         983 984 985 989 = -8 /*
  */ if `bst' == 40

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 180 360 370 531 532 570 582 589 711 754 756 773 776 791 792 /*
  */ 793 794 795 796 803 811 819 832 833 841 842 843 849 852 855 856 862 /*
  */ 871 873 892 895 902 921 922 926 927 931 939 949 951 953 954 959 973 /*
  */ 983 984 985 = -8 /*
  */ if `bst' == 51

  * Ungelernte Arbeiter
  replace `egp' = -8 /*
  */ if `bst' == 60 & `isc' == 1

  * Angelernte Arbeiter
  replace `egp' = -8 /*
  */ if `bst' == 61 & `isc' == 1

  * Gelernte und Facharbeiter
  replace `egp' = -8 /*
  */ if `bst' == 62 & (`isc' ~= 611 & `isc' ~= 612 & `isc' ~= 621 & /*
  */                   `isc' ~= 622 & `isc' ~= 624 & `isc' ~= 625 & /*
  */                   `isc' ~= 626 & `isc' ~= 627 & `isc' ~= 631 & /*
  */                   `isc' ~= 632 & `isc' ~=  10 & `isc' ~= 540 & /*
  */                   `isc' ~= 599 & `isc' ~= 729 & `isc' ~= 742 & /*
  */                   `isc' ~= 782 & `isc' ~= 939 & `isc' ~= 943 & /*
  */                   `isc' ~= 949 & `isc' ~= 971 & `isc' ~= 979 & /*
  */                   `isc' ~= 989 & `isc' ~= 999 & `egp' > 0 )

  * Vorarbeiter, Kolonnenfhrer
  replace `egp' = -8 /*
  */ if `bst' == 63 & (`isc' == 452 | `isc' == 999)

  * Auszubildende/Praktikanten
  recode `egp' 14 162 163 370 531 532 540 552 570 581 589 711 755 776 791 /*
  */ 795 811 /*
  */  819 820 831 832 834 841 842 843 849 851 852 854 855 856 871 874 893 /*
  */  771 796 801 901 902 923 931 949 802 833 873 926 939 952 969 971 951 /*
  */  954 956 957 985 1004 = -8 /*
  */ if `bst' == 70

  * +----------------------------------------------------------+
  * | -9-           Un- und angelernte Arbeiter                |
  * +----------------------------------------------------------+

  * NOTE: Teile von `egp' = 9 werden unten auf Code 10 bzw 11 gesetzt

  * Beamte (einfacher Dienst)
  replace `egp' = -9 /*
  */ if `bst' == 40 & `isc' == 999

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 1 552 560 971 974 979 986 989 999 1004 = -9 /*
  */ if `bst' == 51

  * Ungelernte Arbeiter                   (-> Teile unten auf 10,11 )
  replace `egp' = -9 /*
  */ if `bst' == 60 & (`isc' ~= 3 & `isc' ~= 7) & `egp'> 0

  * Angelernte Arbeiter                   (-> Teile unten auf 10,11 )
  replace `egp' = -9 /*
  */ if `bst' == 61 & (`isc' ~= 2 & `isc' ~= 3 & `isc' ~= 7 & `isc' ~= 8) /*
  */                & `egp'> 0

  * Gelernte und Facharbeiter
  recode `egp' 540 599 729 742 782 939 943 949 971 979 989 999 = -9 /*
  */ if `bst' == 62

  * Auszubildende/Praktikanten
  replace `egp' = -9 /*
  */ if `bst' == 70

  * +----------------------------------------------------------+
  * | -10-                 Landarbeiter                        |
  * +----------------------------------------------------------+

  * Selbstaendige Landwirte
  replace `egp' = -10 /*
  */ if `bst' == 10 & `isc' == 621

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 611/649 = -10 /*
  */ if `bst' == 51

  * Angestellte mit qualifiz. Taetigkeit
  recode `egp'  611/649 = -10 /*
  */ if `bst' == 52

  * Ungelernte Arbeiter
  recode `egp' 611/649 = -10  /*
  */ if `bst' == 60                           /* egp=9 -> egp=10 */

  * Angelernte Arbeiter
  recode `egp' 611/649 = -10 /*
  */  if `bst' == 61                          /* egp=9 -> egp=10 */

  * Gelernte und Facharbeiter
  recode `egp' 611 612 621 622 624 625 626 627 631 632 = -10 /*
  */ if `bst' == 62

  * Auszubildende/Praktikanten
  recode `egp' 627 611 621 624 627 632 = -10 /*
  */if `bst' == 70

  * +----------------------------------------------------------+
  * | -11-                 Klasse 11                           |
  * |     Berufe ohne jegliche buerokratische Einbindung       |
  * +----------------------------------------------------------+

  * Angestellte mit einfacher Taetigkeit
  recode `egp' 490 540 451/490 599 = -11 /*
  */ if `bst' == 51

  * Angestellte mit qualifizierter Taetigkeit
  recode  `egp' 452 490 540 552 599 = -11 /*
  */ if `bst' == 52

  * Ungelernte Arbeiter
  recode `egp' 451/490 500/599 = -11 /*
  */ if `bst' == 60                                /* egp=9 -> egp=11 */

  * Auszubildende/Praktikanten
  replace `egp' = -11 /*
  */ if `bst' == 70 & `isc' == 540
  local i = `i' + 1
 }
 mac shift
}
end
egp b h p t

capture program drop egp
program define egp
while "`1'" ~= "" {
 local i 84
 while `i' <= 97 {
  local bst "bst`1'`i'"
  local isc "isc`1'`i'"
  local egp "egp`1'`i'"
  noi di "Modifikationen von `egp'"
  * +----------------------------------------------------------+
  * |                  Modifikationen                          |
  * +----------------------------------------------------------+
  replace `egp' = -2 if `bst' == -1 & /*
  */                   (`isc' ==  71 | `isc' == 133 | `isc' == 431)
  replace `egp' = -2 if `bst' == 41 & `isc' ==  22
  replace `egp' = -2 if `bst' == 41 & `isc' == 122
  replace `egp' = -7 if `bst' == 41 & `isc' == 849
  replace `egp' = -8 if `bst' == 51 & `isc' == 874
  replace `egp' = -9 if `bst' == 51 & `isc' == 969
  replace `egp' = -2 if `bst' == 52 & `isc' ==  27
  replace `egp' = -7 if `bst' == 52 & `isc' == 892
  replace `egp' = -8 if `bst' == 52 & `isc' == 957
  replace `egp' = -8 if `bst' == 61 & `isc' == 180
  replace `egp' = -3 if `bst' == 61 & `isc' == 432
  replace `egp' = -7 if `bst' == 62 & `isc' ==  27
  replace `egp' = -3 if `bst' == 62 & `isc' == 431
  replace `egp' = -8 if `bst' == 62 & `isc' == 982
  replace `egp' = -7 if `bst' == 64 & `isc' ==  14
  replace `egp' = -7 if `bst' == 64 & `isc' == 162
  replace `egp' = -7 if `bst' == 64 & `isc' == 394
  replace `egp' = -7 if `bst' == 64 & `isc' == 581
  replace `egp' = -7 if `bst' == 64 & `isc' == 724
  replace `egp' = -7 if `bst' == 64 & `isc' == 761
  replace `egp' = -7 if `bst' == 64 & `isc' == 820
  replace `egp' = -7 if `bst' == 64 & `isc' == 902
  replace `egp' = -7 if `bst' == 64 & `isc' == 943

  * Berufliche Stellung unbekannt, ISCO bekannt, sonst nicht zugewiesen
  * -------------------------------------------------------------------

  recode `egp' 21/31 41 61 67 110/132 151 159 161/173 192 202/219 600 = -1 /*
  */ if `bst' == -1
  recode `egp' 2 14 32/38 41/54 62 68/71 76/84 133/149 191 193/195 300 /*
  */            331 339 351/359 421/442 = -2 /*
  */ if `bst' == -1
  recode `egp' 72 74 310 321 322 341 342 360/399 520/540 570 591 599/*
  */            862 = -3 /*
  */ if `bst' == -1
  recode `egp' 400 410 500 510 = -5 /*
  */ if `bst' == -1
  replace `egp' = -6 /*
  */ if `bst' == -1  & (`isc' == 611 | `isc' == 612) & `egp' > 0
  recode `egp' 39 551 700 842 844 = -7 /*
  */ if `bst' == -1
  recode `egp' 581/589 711/841 843 849/859 871/959 981 983 = -8 /*
  */ if `bst' == -1
  recode `egp' 969/979 984/999 = -9 /*
  */ if `bst' == -1
  recode `egp' 621/632 = -10 /*
  */ if `bst' == -1
  recode `egp' 451/490 552 560 = -11 /*
  */ if `bst' == -1


  * Mittlere Beamte, sonst nicht zugewiesen
  * ---------------------------------------
  recode `egp' 1/921 = -2 /*
  */ if `bst' == 41
  replace `egp' = -2 if `bst' == 41 & `isc' == -1

  * Einfache Angestellte, sonst nicht zugewiesen
  * --------------------------------------------
  recode `egp' 172 191 = -2 /*
  */ if `bst' == 51
  recode `egp' 1/4 = -3 /*
  */ if `bst' == 51
  replace `egp' = - 3/*
  */ if `bst' == 51 & `isc' == -1

  * Qualif. Angestellte, sonst nicht zugewiesen
  * -------------------------------------------
  recode `egp' 1/591 = -3 if `bst' == 52
  replace `egp' = -3 if `bst' == 52 & `isc' == -1
  recode `egp' 835 974 = -9 if `bst' == 52

  * Hochqualif. Angestellte, sonst nicht zugewiesen
  * -----------------------------------------------
  recode `egp' 1/9 = -2 if `bst' == 53
  replace `egp' = -2 if `bst' == 53 & `isc' == -1

  * Auszubildende, sonst nicht zugewiesen
  * -------------------------------------
  recode `egp' 24/159 = -2 if `bst' == 70
  recode `egp' 441 452  = -3 if `bst' == 70
  replace `egp' = -5 if `bst' == 70 & `egp' == 410
  recode `egp' 773/959 = -8 if `bst' == 70
  replace `egp' = -99 if `bst' == -1 & `egp' == 5

  * verbleibende Kombinationen nach Trometer (1993) zugeordnet:
  * -----------------------------------------------------------
  replace `egp' = -2 if `bst' == 53 & `isc' == 172
  replace `egp' = -3 if `bst' == 53 & `isc' == 395
  replace `egp' = -2 if `bst' == 51 & `isc' == 581
  recode `egp' 359 839 872 925 957 = -8 if `bst' == 51

  * verbleibende Kombinationen nach Haun (1997) :
  * ---------------------------------------------
  recode `egp' 22 24 42 = -1 if `bst' == 51
  recode `egp' 2 133 135 = -2 if `bst' == 51

  * weitere durch Kohler:
  *----------------------
  recode `egp' 73 83 84 141 149 174 179 191 591 = -2 /*
  */ if `bst' == 51
  replace `egp' = -7 if `bst' == 51 & `isc' == 600
  recode `egp' 725 778 801 834 835 851 853 854 859 952 944 955 956 961 = -8 /*
  */ if `bst' == 51
  recode `egp' 724 756 792 819 820 857 872 953 952 955 956 = -7 /*
  */ if `bst' == 52
  recode `egp' 79 756 956 = -2 /*
  */ if `bst' == 53
  replace `egp' =  -5 if `bst' == -1 & `isc' ==  65
  replace `egp' = -98 if `bst' == -1 & `isc' ==   6
  replace `egp' = -99 if `bst' == -1 & `isc' ==   6
  replace `egp' = -99 if `bst' == -1 & `isc' ==   90
  replace `egp' = -98 if `bst' == 51 & `isc' ==   6
  replace `egp' = -99 if `bst' == -1 & `isc' ==   9
  replace `egp' = -99 if `bst' == 51 & `isc' ==   9
  replace `egp' = -99 if `bst' == 52 & `isc' ==   9

  * keine Information ueber Isco:
  * Zuordnungsregel: Zuweisung zur Modalkategorie, falls 1984 mit mehr als
  * 70 %  besetzt
  replace `egp' = -6 if (`egp' == -99 | `egp' == 4) & `bst' == 10
  replace `egp' = -1 if (`egp' == -99 | `egp' == 4) & `bst' == 15
  replace `egp' = -5 if (`egp' == -99 | `egp' == 4) & `bst' == 21
  replace `egp' = -4 if (`egp' == -99 | `egp' == 4) & `bst' == 23
  replace `egp' = -4 if (`egp' == -99 | `egp' == 4) & `bst' == 30
  replace `egp' = -2 if (`egp' == -99 | `egp' == 4) & `bst' == 42
  replace `egp' = -1 if (`egp' == -99 | `egp' == 4) & `bst' == 43
  replace `egp' = -7 if (`egp' == -99 | `egp' == 4) & `bst' == 50
  replace `egp' = -1 if (`egp' == -99 | `egp' == 4) & `bst' == 54
  replace `egp' = -9 if (`egp' == -99 | `egp' == 4) & `bst' == 60
  replace `egp' = -9 /*
  */ if (`egp' == -99 | `egp' == 4 | `egp' == 7) & `bst' == 61
  replace `egp' = -8 if (`egp' == -99 | `egp' == 4) & `bst' == 62
  replace `egp' = -7 if (`egp' == -99 | `egp' == 4) & `bst' == 63
  replace `egp' = -7 if (`egp' == -99 | `egp' == 4) & `bst' == 64

  * Und zum Schluss:
  * ----------------
  replace `egp' = - 99 if `egp' == 4
  replace `egp' = `egp' * -1
  replace `egp' = . if `egp' == 97  /* -> Non-Matchs */
  replace `egp' = -1 if `egp' == 99
  replace `egp' = -2 if `egp' == 98
  local i = `i' + 1
 }
 mac shift
}
end
egp b h p t

capture program drop labels
program define labels
        local i 84
        while `i' <= 97 {
                lab var egpb`i' "EGP Befragter `i'"
                lab var egph`i' "EGP Hauptverdiener `i'"
                lab var egpp`i' "EGP, Einordnung Pappi `i'"
                lab var egpt`i' "EGP, Einordnung Terwey `i'"
                lab val egpb`i' egp
                lab val egph`i' egp
                lab val egpp`i' egp
                lab val egpt`i' egp
                local i=`i'+1
        }
end
labels
lab def egp 1 "Dienst 1" 2 "Dienst 2" 3 "Non-man." 4 "gr.Selb." /*
*/ 5 "kl.Selb." 6 "selb.Lw." 7 "Vorarb." 8 "Facharb." 9 "Un/Angel" /*
*/ 10 "Landarb" 11 "Heimber"

keep hhnr-nnetto egp*
save peigen, replace

*-----------------------SPEICHERN---------------------------------------
capture program drop svdat
program define svdat
    local i 84
    while `i'<=97 {
        use hhnr `1'hhnr `1'netto persnr egpb`i' egph`i' egpp`i' egpt`i' /*
        */ if `1'netto == 1 using peigen, clear
        ren `1'hhnr hhnrakt
        sort hhnr hhnrakt persnr
        merge hhnr hhnrakt persnr using $soepdir/`1'peigen
        assert _merge==3
        drop `1'netto _merge
        compress
        order hhnr hhnrakt persnr bul`i' hst`i' fam`i' bil`i' bbil`i' /*
        */ bdauer`i' est`i' nie`i' bstb`i' iscb`i' bsth`i' isch`i' /*
        */ bstp`i' iscp`i' bstt`i' isct`i' bstbex`i' iscbex`i' bstpar`i' /*
        */ iscpar`i' bstvpa`i' iscvpa`i' aus`i' hhein`i' ein`i' /*
        */ egpb`i' egph`i' egpp`i' egpt`i'
        save $soepdir/`1'peigen, replace
        local i = `i'+1
        mac shift
    }
end
svdat a b c d e f g h i j k l m n

exit

----------------------------------------------------------------------------


\begin{enumerate}
\item Die Klassifizierung Ostdeutscher Befragter beginnt erst mit Welle h
(1991). 1990 wurde zwar bereits eine Befragung Ostdeutscher durchgef"uhrt,
die berufliche Stellung jedoch anders abgefragt (keine Beamte, daf"ur aber
Genossenschaftsbauer).  Da in sp"ateren Wellen auch f"ur ostdeutsche
Befragte die Westversion verwendet wurde, beginnt die Klassifizierung in
EGP-Klassen mit 1991, dem Jahr, in dem das Westschema erstmals vorliegt.

\item Trennung der Selbst"andigen in 1 Mitarbeiter oder allein vs. 2-9 Mitarb.
nicht m"oglich. Desgleichen die Trennung des Selbst"andigen zw. 10-49 und
"uber 50 Mitarbeiter.  Vercodet wurde wie bei Mueller/Haun (1994)
\nocite{mueller94}

\item In der Vorlage von M"uller/Haun (1994) \nocite{mueller94}
traten einige der in den "ubrigen Wellen auftretenden Kombinationen nicht
auf. Diese wurden wenn m"oglich nach Trometer, danach nach Haun (1997)
\nocite{haun97} und ansonsten aufgrund eigener Entscheidungen vercodet.

\item Bei fehlender Information "uber den Isco--Code (Missing--Code $-1$)
wurde auf Basis einer Kreuztabelle f"ur die Welle 1984 zwischen beruflicher
Stellung und den bisher vergebenen Codes ermittelt, ob sich Personen gut
anhand der Information "uber die berufliche Stellung einer Klasse zuweisen
lassen. Wenn "uber 70 Prozent der Befragten einer beruflichen Stellung nur
einer Klasse zugewiesen wurden, wurde diese Klasse zugewiesen.