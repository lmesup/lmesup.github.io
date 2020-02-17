// Liferisk-Projekt, Data Retrieval for Poorness 
// zeh@wzb.eu, kohler@wzb.eu

// crpsid1.do Initial version
// crpsid2.do Illness recoded
// crUS.do Adds works of Ehlert/Radenacker/Heisig

cd "$liferisks/armut/analysen"
clear all
version 11
set more off
set mem 800m

// Retrive Data from PSID
// -----------------------

psiduse ///
  || weeksill_head 						/// 
  [80]V7111 [81]V7734 [82]V8396 [83]V9027 [84]V10552 [85]V11696 [86]V13096 /// 
  [87]V14194 [88]V15248 [89]V16749 [90]V18187 [91]V19487 [92]V20787 ///  
  [93]V22561 [94]ER2174 [95]ER5173 [96]ER7269 [97]ER12176 [99]ER16473 ///
  [01]ER20401 [03]ER24082 [05]ER27888 [07]ER40878 	///
  || weeksill_wife 						/// 
  [80]V7206 [81]V7897 [82]V8555 [83]V9205 [84]V10766 [85]V12059 [86]V13273 ///
  [87]V14367 [88]V15550 [89]V17068 [90]V18489 [91]V19789 [92]V21089 /// 
  [93]V22914 [94]ER4109 [95]ER6949 [96]ER9200 [97]ER12187 [99]ER16484 ///
  [01]ER20412 [03]ER24093 [05]ER27899 [07]ER40889 ///
  || daysill_head [03]ER21290 [05]ER25279 [07]ER36284 ///
  || daysill_wife [03]ER21540 [05]ER25537 [07]ER36542 ///
  || monthill_head [03]ER21294 [05]ER25283 [07]ER36288 ///
  || monthill_wife [03]ER21544 [05]ER25541 [07]ER36546 ///
  || dummyill_head [07]ER36283 	///
  || dummyill_wife [07]ER36541 	///
  || shealth_head 						///
  [84]V10877 [85]V11991 [86]V13417 [87]V14513 [88]V15993 [89]V17390 ///
  [90]V18721 [91]V20021 [92]V21321 [93]V23180 [94]ER3853 [95]ER6723 /// 
  [96]ER8969 [97]ER11723 [99]ER15447 [01]ER19612 [03]ER23009 [05]ER26990 /// 
  [07]ER38202 ///
  || shealth_wife 						/// 
  [84]V10884 [85]V12344 [86]V13452 [87]V14524 [88]V15999 [89]V17396 	/// 
  [90]V18727 [91]V20027 [92]V21328 [93]V23187 [94]ER3858 [95]ER6728 /// 
  [96]ER8974 [97]ER11727 [99]ER15555 [01]ER19720 [03]ER23136 [05]ER27113 	/// 
  [07]ER39299 ///
  || debt [84]V10932 [89]V17334 [94]ER3752 [99]ER15030 [01]ER19226 /// 
  [03]ER22621 [05]ER26602 [07]ER37620	///
  || debtsum [84]V10933 [89]V17335 [94]ER3753 [99]ER15031 [01]ER19227 /// 
  [03]ER22622 [05]ER26603 [07]ER37621	///
  || empdur_head [81]V7711 [82]V8379 [83]V9010 [84]V10519 [85]V11668 /// 
  [86]V13068 [87]V14166 [88]V15181 [89]V16682 [90]V18120 [91]V19420 /// 
  [92]V20720 [93]V22489 [94]ER2099 [95]ER5098 [96]ER7194 [97]ER10118 /// 
  [99]ER13244 [01]ER17255 [03]ER21172 [05]ER25161 [07]ER36166 /// 
  || empdur_wife [81]V7884 [82]V8543 [83]V9193 [84]V10733 [85]V12031 	/// 
  [86]V13245 [87]V14339 [88]V15483 [89]V17001 [90]V18422 [91]V19722 /// 
  [92]V21022 [93]V22842 [94]ER2593 [95]ER5592 [96]ER7688 [97]ER10600 /// 
  [99]ER13756 [01]ER17825 [03]ER21422 [05]ER25419 [07]ER36424 ///
  || empdury_head [94]ER2098 [95]ER5097 [96]ER7193 [97]ER10117 	/// 
  [99]ER13243 [01]ER17254 [03]ER21171 [05]ER25160 [07]ER36165 ///
  || empdury_wife [94]ER2592 [95]ER5591 [96]ER7687 [97]ER10599 	/// 
  [99]ER13755 [01]ER17824 [03]ER21421 [05]ER25418 [07]ER36423 ///
  || mpairs [80]ER30317 [81]ER30347 [82]ER30377 [83]ER30405 ///
  [84]ER30435 [85]ER30469 [86]ER30504 [87]ER30541 [88]ER30576 ///
  [89]ER30612 [90]ER30648 [91]ER30695 [92]ER30739 [93]ER30812 ///
  [94]ER33107 [95]ER33207 [96]ER33307 [97]ER33407 [99]ER33507 ///
  [01]ER33607 [03]ER33707 [05]ER33807  [07]ER33907 ///
  || moveout [80]ER30318 [81]ER30348 [82]ER30378 [83]ER30406 ///
  [84]ER30436 [85]ER30470 [86]ER30505 [87]ER30542 [88]ER30577 ///
  [89]ER30613 [90]ER30649 [91]ER30696 [92]ER30740 [93]ER30813 ///
  [94]ER33108 [95]ER33208 [96]ER33308 [97]ER33408 [99]ER33508 ///
  [01]ER33608 [03]ER33708 [05]ER33808 [07]ER33908 ///
  || creditordemand1 [96]ER8866 ///
  || creditordemand2 [96]ER8867 ///
  || creditordemand3 [96]ER8868 ///
  || creditordemand4 [96]ER8869 ///
  || creditordemand5 [96]ER8870 ///
  || creditordemand6 [96]ER8871 ///
  || weeksunemp_head [80]V7117 [81]V7740 [82]V8402 [83]V9033 [84]V10558 /// 
  [85]V11702 [86]V13102 [87]V14200 [88]V15254 [89]V16755 [90]V18193 /// 
  [91]V19493 [92]V20793 [93]V22570 [94]ER2191 [95]ER5190 [96]ER7286 /// 
  [97]ER10201 [99]ER13332 [01]ER17356 [03]ER21320 [05]ER25309 [07]ER36314 ///
  || weeksunemp_headA [80]V7172 [81]V7820 [82]V8481 [83]V9118 [84]V10626 /// 
  [85]V11799 [86]V13195 [87]V14291 [88]V15401 [89]V16916 [90]V18340 /// 
  [91]V19640 [92]V20940 [93]V22736 [94]ER2436 [95]ER5435 [96]ER7531 /// 
  [97]ER10440 [99]ER13585 [01]ER17638 ///
  || weeksunemp_wife [80]V7212 [81]V7903 [82]V8561 [83]V9211 [84]V10772  /// 
  [85]V12065 ///
  [86]V13279 [87]V14373 [88]V15556 [89]V17074 [90]V18495 [91]V19795 /// 
  [92]V21095 [93]V22923 [94]ER2685 [95]ER5684 [96]ER7780 [97]ER10683 /// 
  [99]ER13844 [01]ER17926 [03]ER21570 [05]ER25567 [07]ER36572 ///
  || weeksunemp_wifeA [80]V7244 [81]V7933 [82]V8588 [83]V9247  /// 
  [84]V10826 [85]V12162 /// 
  [86]V13363 [87]V14455 [88]V15703 [89]V17235 [90]V18642 [91]V19942  /// 
  [92]V21242 [93]V23089 [94]ER2930 [95]ER5929 [96]ER8025 [97]ER10922  /// 
  [99]ER14097 [01]ER18209 ///
  || daysunemp_head [94]ER2190 [95]ER5189 [96]ER7285 [97]ER10200  /// 
  [99]ER13331 [01]ER17354 [03]ER21318 [05]ER25307 [07]ER36312 ///
  || daysunemp_headA [94]ER2435 [95]ER5434 [96]ER7530 [97]ER10439  /// 
  [99]ER13584 [01]ER17636 ///
  || daysunemp_wife  [94]ER2684 [95]ER5683 [96]ER7779 [97]ER10682  /// 
  [99]ER13843 [01]ER17924 [03]ER21568 [05]ER25565 [07]ER36570 ///
  || daysunemp_wifeA [94]ER2929 [95]ER5928 [96]ER8024 [97]ER10921  /// 
  [99]ER14096 [01]ER18207 ///
  || monthunemp_head [94]ER2192 [95]ER5191 [96]ER7287 [97]ER10202  /// 
  [99]ER13333 [01]ER17358 [03]ER21322 [05]ER25311 [07]ER36316 ///
  || monthunemp_headA [94]ER2437 [95]ER5436 [96]ER7532 [97]ER10441 	/// 
  [99]ER13586 [01]ER17640 ///
  || monthunemp_wife [94]ER2686 [95]ER5685 [96]ER7781 [97]ER10684  /// 
  [99]ER13845 [01]ER17928 [03]ER21572 [05]ER25569 [07]ER36574 ///
  || monthunemp_wifeA [94]ER2931 [95]ER5930 [96]ER8026 [97]ER10923 	/// 
  [99]ER14098 [01]ER18211 ///
  || weeksemp_head [80]V7118 [81]V7741 [82]V8403 [83]V9034 [84]V10561 ///
  [85]V11705 [86]V13105 [87]V14203 [88]V15257 [89]V16758 ///
  [90]V18196 [91]V19496 [92]V20796 [93]V22575 [94]ER2222 [95]ER5221 ///
  [96]ER7317 [97]ER10231 [99]ER13362 [01]ER17391 [03]ER24077 ///
  [05]ER27883 [07]ER40873 ///
  || weeksemp_headA [80]V7173 [81]V7821 [82]V8482 [83]V9119 [84]V10629 ///
  [85]V11802 [86]V13198 [87]V14294 [88]V15404 [89]V16919 ///
  [90]V18343 [91]V19643 [92]V20943 [93]V22741 [94]ER2467 [95]ER5466 ///
  [96]ER7562 [97]ER10470 [99]ER13615 [01]ER17673 ///
  || weeksemp_wife [80]V7213 [81]V7904 [82]V8562 [83]V9212 [84]V10775 ///
  [85]V12068 [86]V13282 [87]V14376 [88]V15559 [89]V17077 ///
  [90]V18498 [91]V19798 [92]V21098 [93]V22928 [94]ER2716 [95]ER5715 ///
  [96]ER7811 [97]ER10713 [99]ER13874 [01]ER17961 [03]ER24088 ///
  [05]ER27894 [07]ER40884 ///
  || weeksemp_wifeA [80]V7245 [81]V7934 [82]V8589 [83]V9248 [84]V10829 ///
  [85]V12165 [86]V13366 [87]V14458 [88]V15706 [89]V17238 ///
  [90]V18645 [91]V19945 [92]V21245 [93]V23094 [94]ER2960 [95]ER5959 ///
  [96]ER8056 [97]ER10952 [99]ER14127 [01]ER18244 ///
  || daysothsick_headA [94]ER2415 [95]ER5414 [96]ER7510 [97]ER10423  ///
  [99]ER13568 [01]ER17608 ///
  || weeksothsick_headA [94]ER2416 [95]ER5415 [96]ER7511 [97]ER10424  ///
  [99]ER13569 [01]ER17610 ///
  || monthothsick_headA [94]ER2417 [95]ER5416 [96]ER7512 [97]ER10425  ///
  [99]ER13570 [01]ER17612 ///
  || daysothsick_head [94]ER2170 [95]ER5169 [96]ER7265 [97]ER10184  ///
  [99]ER13315 [01]ER17326 ///
  || weeksothsick_head [94]ER2171 [95]ER5170 [96]ER7266 [97]ER10185  ///
  [99]ER13316 [01]ER17328 ///
  || monthothsick_head [94]ER2172 [95]ER5171 [96]ER7267 [97]ER10186  ///
  [99]ER13317 [01]ER17330 ///
  || dayssick_headA [94]ER2420 [95]ER5419 [96]ER7515 [97]ER10427  ///
  [99]ER13572 [01]ER17615 ///
  || weekssick_headA [94]ER2421 [95]ER5420 [96]ER7516 [97]ER10428  ///
  [99]ER13573 [01]ER17617 ///
  || monthsick_headA [94]ER2422 [95]ER5421 [96]ER7517 [97]ER10429  ///
	[99]ER13574 [01]ER17619 ///
  || dayssick_head [94]ER2175 [95]ER5174 [96]ER7270 [97]ER10188  ///
  [99]ER13319 [01]ER17333 ///
  || weekssick_head [94]ER2176 [95]ER5175 [96]ER7271 [97]ER10189  ///
  [99]ER13320 [01]ER17335 ///
  || monthsick_head [94]ER2177 [95]ER5176 [96]ER7272 [97]ER10190  ///
  [99]ER13321 [01]ER17337 ///
  || daysvac_headA [94]ER2425 [95]ER5424 [96]ER7520 [97]ER10431  ///
  [99]ER13576 [01]ER17622 ///
  || weeksvac_headA [94]ER2426 [95]ER5425 [96]ER7521 [97]ER10432  ///
  [99]ER13577 [01]ER17624 ///
  || monthvac_headA [94]ER2427 [95]ER5426 [96]ER7522 [97]ER10433  ///
  [99]ER13578 [01]ER17626 ///
  || daysvac_head [94]ER2180 [95]ER5179 [96]ER7275 [97]ER10192  ///
  [99]ER13323 [01]ER17340 ///
  || weeksvac_head [94]ER2181 [95]ER5180 [96]ER7276 [97]ER10193  ///
  [99]ER13324 [01]ER17342 ///
  || monthvac_head [94]ER2182 [95]ER5181 [96]ER7277 [97]ER10194  ///
  [99]ER13325 [01]ER17344 ///
  || daysstrike_headA [94]ER2430 [95]ER5429 [96]ER7525 [97]ER10435  ///
  [99]ER13580 [01]ER17629 ///
  || weeksstrike_headA [94]ER2431 [95]ER5430 [96]ER7526 [97]ER10436  ///
  [99]ER13581 [01]ER17631 ///
  || monthstrike_headA [94]ER2432 [95]ER5431 [96]ER7527 [97]ER10437  ///
  [99]ER13582 [01]ER17633 ///
  || daysstrike_head [94]ER2185 [95]ER5184 [96]ER7280 [97]ER10196  ///
  [99]ER13327 [01]ER17347 ///
  || weeksstrike_head [94]ER2186 [95]ER5185 [96]ER7281 [97]ER10197  ///
  [99]ER13328 [01]ER17349 ///
  || monthstrike_head [94]ER2187 [95]ER5186 [96]ER7282 [97]ER10198  ///
  [99]ER13329 [01]ER17351 ///
  || daysothsick_wifeA [94]ER2909 [95]ER5908 [96]ER8004 [97]ER10905  ///
  [99]ER14080 [01]ER18179 ///
  || weeksothsick_wifeA [94]ER2910 [95]ER5909 [96]ER8005 [97]ER10906  ///
  [99]ER14081 [01]ER18181 ///
  || monthothsick_wifeA [94]ER2911 [95]ER5910 [96]ER8006 [97]ER10907  ///
  [99]ER14082 [01]ER18183 ///
  || daysothsick_wife [94]ER2664 [95]ER5663 [96]ER7759 [97]ER10666  ///
  [99]ER13827 [01]ER17896 ///
  || weeksothsick_wife [94]ER2665 [95]ER5664 [96]ER7760 [97]ER10667  ///
  [99]ER13828 [01]ER17898 ///
  || monthothsick_wife [94]ER2666 [95]ER5665 [96]ER7761 [97]ER10668  ///
  [99]ER13829 [01]ER17900 ///
  || dayssick_wifeA [94]ER2914 [95]ER5913 [96]ER8009 [97]ER10909  ///
  [99]ER14084 [01]ER18186 ///
  || weekssick_wifeA [94]ER2915 [95]ER5914 [96]ER8010 [97]ER10910  ///
  [99]ER14085 [01]ER18188 ///
  || monthsick_wifeA [94]ER2916 [95]ER5915 [96]ER8011 [97]ER10911  ///
  [99]ER14086 [01]ER18190 ///
  || dayssick_wife [94]ER2669 [95]ER5668 [96]ER7764 [97]ER10670  ///
  [99]ER13831 [01]ER17903 ///
  || weekssick_wife [94]ER2670 [95]ER5669 [96]ER7765 [97]ER10671  ///
  [99]ER13832 [01]ER17905 ///
  || monthsick_wife [94]ER2671 [95]ER5670 [96]ER7766 [97]ER10672  ///
  [99]ER13833 [01]ER17907 ///
  || daysvac_wifeA [94]ER2919 [95]ER5918 [96]ER8014 [97]ER10913  ///
  [99]ER14088 [01]ER18193 ///
  || weeksvac_wifeA [94]ER2920 [95]ER5919 [96]ER8015 [97]ER10914  ///
  [99]ER14089 [01]ER18195 ///
  || monthvac_wifeA [94]ER2921 [95]ER5920 [96]ER8016 [97]ER10915  ///
  [99]ER14090 [01]ER18197 ///
  || daysvac_wife  [94]ER2674 [95]ER5673 [96]ER7769 [97]ER10674  ///
  [99]ER13835 [01]ER17910 ///
  || weeksvac_wife  [94]ER2675 [95]ER5674 [96]ER7770 [97]ER10675  ///
  [99]ER13836 [01]ER17912 ///
  || monthvac_wife  [94]ER2676 [95]ER5675 [96]ER7771 [97]ER10676  ///
  [99]ER13837 [01]ER17914 ///
  || daysstrike_wifeA [94]ER2924 [95]ER5923 [96]ER8019 [97]ER10917  ///
  [99]ER14092 [01]ER18200 ///
  || weeksstrike_wifeA [94]ER2925 [95]ER5924 [96]ER8020 [97]ER10918  ///
  [99]ER14093 [01]ER18202 ///
  || monthstrike_wifeA [94]ER2926 [95]ER5925 [96]ER8021 [97]ER10919  ///
  [99]ER14094 [01]ER18204 ///
  || daysstrike_wife [94]ER2679 [95]ER5678 [96]ER7774 [97]ER10678  ///
  [99]ER13839 [01]ER17917 ///
  || weeksstrike_wife [94]ER2680 [95]ER5679 [96]ER7775 [97]ER10679  ///
  [99]ER13840 [01]ER17919 ///
  || monthstrike_wife [94]ER2681 [95]ER5680 [96]ER7776 [97]ER10680  ///
  [99]ER13841 [01]ER17921 ///
  || emplst [80]ER30323 [81]ER30353 [82]ER30382 [83]ER30411 /// 
  [84]ER30441 [85]ER30474 [86]ER30509 [87]ER30545 [88]ER30580 ///
  [89]ER30616 [90]ER30653 [91]ER30699 [92]ER30744 [93]ER30816 ///
  [94]ER33111 [95]ER33211 [96]ER33311 [97]ER33411 [99]ER33512 ///
  [01]ER33612 [03]ER33712 [05]ER33813 [07]ER33913 ///
  || emplh1 [94]ER2069 [95]ER5068 [96]ER7164 [97]ER10081 ///
  [99]ER13205 [01]ER17216 [03]ER21123 [05]ER25104 [07]ER36109 ///
  || emplh2 [94]ER2070 [95]ER5069 [96]ER7165 [97]ER10082 /// 
  [99]ER13206 [01]ER17217 [03]ER21124 [05]ER25105 [07]ER36110 ///
  || emplh3 [94]ER2071 [95]ER5070 [96]ER7166 [97]ER10083 ///
  [99]ER13207 [01]ER17218 [03]ER21125 [05]ER25106 [07]ER36111 ///
  || emplw1 [94]ER2563 [95]ER5562 [96]ER7658 [97]ER10563 ///
  [99]ER13717 [01]ER17786 [03]ER21373 [05]ER25362 [07]ER36367 ///
  || emplw2 [94]ER2564 [95]ER5563 [96]ER7659 [97]ER10564 ///
  [99]ER13718 [01]ER17787 [03]ER21374 [05]ER25363 [07]ER36368 ///
  || emplw3 [94]ER2565 [95]ER5564 [96]ER7660 [97]ER10565 ///
  [99]ER13719 [01]ER17788 [03]ER21375 [05]ER25364 [07]ER36369 ///
  || strat []ER31998 					 ///
  || psid_edu [80]ER30326 [81]ER30356 [82]ER30384 [83]ER30413  /// 
  [84]ER30443 [85]ER30478 [86]ER30513 [87]ER30549 [88]ER30584  /// 
  [89]ER30620 [90]ER30657 [91]ER30703 [92]ER30748 [93]ER30820  /// 
  [94]ER33115 [95]ER33215 [96]ER33315 [97]ER33415 [99]ER33516  /// 
  [01]ER33616 [03]ER33716 [05]ER33817 [07]ER33917  /// 
using $psid, design(any) clear

psidadd ///
  || age d11101 ///
  || sex d11102ll ///
  || mar d11104 		///
  || rel2head d11105 ///
  || hhsize d11106 ///
  || edu d11108 ///
  || yedu d11109 ///
  || race d11112ll ///
  || whours e11101 ///
  || occup e11105 ///
  || sector e11106 ///
  || hhsize0to14 h11101 ///
  || hhpregov i11101 ///
  || hhpostgov i11113 ///
  || hhlabinc i11103 ///
  || indlabinc i11110 ///
  || state l11101 /// 
  , cneffrom($cnef07) correct 

// We don't use Immigrant sample
// -----------------------------

drop if strat==0 | inrange(strat,55,78)

// Yearly creditor calls
// ---------------------

egen touse1 = neqany(creditordemand?1996), v(7,8,9)
egen touse2 = rmiss(creditordemand?1996)
gen touse = !touse1 & !touse2

egen creditordemand1991 = eqany(creditordemand?1996) if touse, v(1)
egen creditordemand1992 = eqany(creditordemand?1996) if touse, v(2)
egen creditordemand1993 = eqany(creditordemand?1996) if touse, v(3)
egen creditordemand1994 = eqany(creditordemand?1996) if touse, v(4)
egen creditordemand1995 = eqany(creditordemand?1996) if touse, v(5)
egen creditordemand1996 = eqany(creditordemand?1996) if touse, v(6)

drop touse* creditordemand?1996


// Missing values
// --------------

mvdecode days* weeks* , mv(997=.a \ 998=.b \ 999=.c)
mvdecode month*, mv(97=.a \ 98=.b \ 24,99=.c)
mvdecode weeks*, mv(97=.a \ 98=.b \ 99=.c)

// Days/Months -> weeks conversion
// --------------------------------

foreach var of varlist days* {
	local weeksvar: subinstr local var "days" "weeks"
	replace `weeksvar' = `weeksvar' + round(`var'/5,1) 	/// 
	  if !mi(`var')
}

foreach var of varlist month* {
	local weeksvar: subinstr local var "month" "weeks"
	replace `weeksvar' = `weeksvar' + round(`var'*(30/7),1)  /// 
	  if !mi(`var')
}
drop days* month*  


// Merge *A variables to "normal" variables
// ----------------------------------------

foreach avar of varlist *A* {
	local var: subinstr local avar "A" ""
	replace `var' = `avar' if `var' == 0
}
drop *A*


// Reshape to long
// ---------------

// Beautyful variable names
renpfix x11102_ x11102
renpfix xsqnr_ sqnr

// Store variable labels for long
local namestub x11102 sqnr hhsize0to14 hhsize hhlabinc ///
  hhpregov hhpostgov indlabinc age rel2head edu yedu psid_edu whours 	/// 
  occup mpairs moveout state   				/// 
  mar debt debtsum creditordemand sector  /// 
  emplst emplh1 emplh2 emplh3 emplw1 emplw2 emplw3 ///
  shealth_head shealth_wife             /// 
  empdur_head empdur_wife 				/// 
  empdury_head empdury_wife 			/// 
  weeksill_head     weeksill_wife 		/// 
  weeksemp_head     weeksemp_wife 		/// 
  weeksunemp_head   weeksunemp_wife     ///
  weeksothsick_head weeksothsick_wife 	/// 
  weekssick_head	weekssick_wife	    ///
  weeksvac_head	    weeksvac_wife       ///
  weeksstrike_head  weeksstrike_wife
  

foreach stup of local namestub {
	macro drop _lab
	local i 1984
	while "`lab'" == "" {
		capture local lab: var lab `stup'`i++'
	}
	local lb`stup' `lab'
}

// Reshape
reshape long `namestub' , i(x11101ll) j(wave)

// Relabel the long data
foreach var of varlist `namestub' {
	label var `var' `"`lb`var''"'
}
lab var creditordemand "Creditor demands payment"

// Tsset
egen waveorder = group(wave)
tsset x11101ll waveorder
sort x11101ll waveorder


// Keep Head and Wife only
// -----------------------
// -> Note 1

keep if (inlist(rel2head, 1, 2) & inrange(sqnr, 1, 50))   

// Simple Recodings
// ----------------

// Gender
gen men:yesno = sex == 1 if !mi(sex)
label variable men "Men y/n"
drop sex

// Age
// Note slightly displaced in some obs. -> ignore
label variable age "Age"

// Race
replace race = race==2 if inrange(race,1,7)
label value race race
label define race 0 "Non-black" 1 "Black"

// Sector
gen industry:industry = inlist(sector,1,2,3,4,5) if inrange(sector,1,9)
label define industry 0 "Third" 1 "Industrial/Agricultural"
drop sector

// Whours (retrospective)
replace whours = . if whours < 0 | (whours > (7*18*365) & !mi(whours))
replace whours = whours/52
replace whours = F1.whours

// Education -> Note
mvdecode psid_edu, mv(0=.b \ 98 99=.a)
replace yedu = psid_edu if !mi(psid_edu)
by x11101ll (waveorder), sort: replace yedu = yedu[_n-1] ///
  if (yedu[_n-1] > yedu 				/// 
  & !mi(yedu[_n-1])) | (!mi(yedu[_n-1]) & mi(yedu))

replace edu = 1 if inrange(yedu, 1, 11)
replace edu = 2 if yedu == 12
replace edu = 3 if yedu > 12 & yedu < . 

drop psid_edu

// Debts y/n
mvdecode debt, mv(0,8,9)
replace debt = debt==1 if !mi(debt)

// Debtsum
replace debtsum = . if debtsum > 999996 

// Work experience (Retrospective)
mvdecode empdur_head empdur_wife if wave < 1994, mv(999)
mvdecode empdur_head empdur_wife empdury_head empdury_wife if wave >= 1994, mv(98 99)

gen empdur = cond(rel2head==1,empdur_head,empdur_wife) if wave < 1994
replace empdur = cond(rel2head==1,empdury_head*12,empdury_wife*12) ///
  if wave >=1994
replace empdur = cond(rel2head==1,empdur_head,empdur_wife) ///
  if empdur==0 & wave >=1994

// I use work experience of the partner if person info is empty
replace empdur = cond(rel2head==2,empdur_head,empdur_wife) ///
  if empdur==0 &  wave < 1994 & !mi(empdur_head,empdur_wife)
replace empdur = cond(rel2head==2,empdury_head*12,empdury_wife*12) ///
  if empdur==0 & wave >=1994 & !mi(empdury_head,empdury_wife)
replace empdur = cond(rel2head==2,empdur_head,empdur_wife) ///
  if empdur==0 & wave >=1994 & !mi(empdur_head,empdur_wife)

replace empdur = round(empdur/12,1)
replace empdur = F1.empdur
label variable empdur "Years in present job"
drop empdur_* empdury_*

// Health indicators
// -----------------

mvdecode weeksill*, mv(99=.a \98=.b \143 =.c)
mvdecode shealth*, mv(9=.a \8=.b \0 =.c)

// Short term illness
gen ill:yesno = inrange(weeksill_head,.2,6) 	/// 
  if rel2head==1 & !mi(weeksill_head) 
replace ill = inrange(weeksill_wife,.2,6)      ///
  if rel2head==2 & !mi(weeksill_wife)
replace ill = dummyill_head2007==1 if rel2head==1 & wave==2007
replace ill = dummyill_wife2007==1 if rel2head==2 & wave==2007
replace ill = F1.ill
label variable ill "Short term illness"
drop dummyill*

// Long term illness
gen illlong:yesno = weeksill_head >= 6 	/// 
  if rel2head==1 & !mi(weeksill_head) 
replace illlong = weeksill_wife >= 6 ///
  if rel2head==2 & !mi(weeksill_wife)
replace illlong = F1.illlong
label variable illlong "Long term illness"

// Weeks ill
gen illweeks = weeksill_head if rel2head==1 
replace illweeks = weeksill_wife if rel2head==2
replace illweeks = F1.illweeks
label variable illweeks "Weeks of illness"

// Subjective health
gen shealth = cond(rel2head==1,shealth_head,shealth_wife)
by x11101ll (waveorder): egen sickbar = mean(shealth)
by x11101ll (waveorder): egen sicksd = sd(shealth)
gen sick = shealth > (sickbar + sicksd) if !mi(shealth)
label variable sick "Feeling sick"
label variable shealth "Subj. health evaluation"
drop weeksill* sickbar sicksd shealth_*

// Income (Retrospective)
// ----------------------

// Equivalent Scale
gen hhpostgoveq = hhpostgov/(1 + .5*(hhsize - hhsize0to14 - 1) + .3*hhsize0to14)
label variable hhpostgoveq "Household equivalent income (post gov)"
// (CPI correction is downstream)

// Employment Status
// -----------------

gen emplh:empl=.
gen emplw:empl=.
foreach num of numlist 9 8 6 7 5 4 3 1 2 {
	replace emplh=`num' if emplh1==`num' | emplh2==`num' | emplh3==`num' 
	replace emplw=`num' if emplw1==`num' | emplw2==`num' | emplw3==`num' 
}

replace emplst=emplh if rel2head==1 & sqnr==1 & inrange(wave,1994,2007)
replace emplst=emplw if rel2head==2 & sqnr<51 & inrange(wave,1994,2007)
lab var emplst "Employment Status"
lab def emplst 						///  
  1 "Working now"	 ///
  2 "Only temporarily laid off" ///
  3 "Looking for work, unemployed" ///
  4 "Retired"			 ///
  5 "Permanently disabled"		 ///
  6 "Housewife; keeping house"		///
  7 "Student"				 ///
  8 "Other"					 ///
  9 "NA; DK"					 ///
  0	"Inappropriate"

drop emplh* emplw*


// Weeks worked
// ------------
// = weeks worked - weeks missed 

// We delete all execept one pice of information that seem to be stored
// in several variables 

foreach rel in head wife {
	local types unemp sick othsick vac strike
	forv i = 1/`:word count `types'' {
		gettoken typ1 types: types
		
		foreach typ of local types {
			replace weeks`typ'_`rel' = .  /// 
			  if weeks`typ1'_`rel' == weeks`typ'_`rel' ///
			  & weeks`typ'_`rel'>= 15 
		}
	}
}

egen weeksmissed_wife = rowtotal( 		/// 
  weeksunemp_wife weekssick_wife 		/// 
  weeksothsick_wife weeksvac_wife 		/// 
  weeksstrike_wife)

egen weeksmissed_head = rowtotal( 		///
  weeksunemp_head weekssick_head 		/// 
  weeksothsick_head weeksvac_head 		/// 
  weeksstrike_head)

gen weeksmissed = weeksmissed_head if rel2head == 1 & sqnr == 1
replace weeksmissed = weeksmissed_wife if rel2head==2 & sqnr<51
replace weeksmissed = 52 if weeksmissed > 52 & weeksmissed < . 

gen empweeks = weeksemp_head if rel2head == 1 & sqnr == 1
replace empweeks = weeksemp_wife if rel2head==2 & sqnr<51
replace empweeks = 52 - weeksmissed if empweeks == .a

replace empweeks = F1.empweeks
label variable empweeks "Weeks worked"

// Weeks unemployed (Retrospective)
// --------------------------------

replace weeksunemp_head=0 if x11101ll==5419002 // Obvious data error
gen unempweeks = weeksunemp_head if rel2head==1 & sqnr==1
replace unempweeks = weeksunemp_wife if rel2head==2 & sqnr<51 

replace unempweeks = F1.unempweeks

// Correction if weeks unemployed + weeks employed to high (with fuzziness)
replace unempweeks = 56 - empweeks if (empweeks + unempweeks) > 56

label variable unempweeks "Weeks unemployed"
drop weeks*


// Poorness
// --------

// Merge Weights and stuff
merge n:1 x11101ll using  ../../data/weights/psidweights  ///
  , keep(3) keepusing(weight) nogenerate

// Correction for inflation
preserve
clear
input int wave cpi
1980 82.4
1981 90.9
1982 96.5
1983 99.6
1984 103.9
1985 107.6
1986 109.6
1987 113.6
1988 118.3
1989 124.0
1990 130.7
1991 136.2
1992 140.3
1993 144.5
1994 148.2
1995 152.4
1996 156.9
1997 160.5
1998 163.0
1999 166.6
2000 172.2
2001 177.1
2002 179.9
2003 184.0
2004 188.9
2005 195.3
2006 201.6
2007 207.3
end
replace wave = wave + 1 
tempfile cpi
save `cpi'

restore
merge n:1 wave using `cpi', nogen keep(3)

foreach var of varlist indlabinc* hhlabinc* hhpregov* hhpostgov* {
	replace `var' = `var' * (207.3/cpi)
	label var `var' "`:variable label `var'' (prices of 2007)"
}

// Poorness
gen poor=.
levelsof wave, local(K)
foreach k of local K {
	_pctile hhpostgoveq [aweight=weight] if wave==`k' 
	replace poor = hhpostgoveq < (r(r1)*.6) if wave==`k' 
}
label variable poor "Poor y/n"

ren x11101ll id
tsset id waveorder
sort id waveorder

replace hhpostgoveq = F1.hhpostgoveq
replace poor = F1.poor
replace wave = wave + 1 if wave >= 1997

// Events
// ------

// Job loss
bys id (waveorder): gen byte eunemp  ///
  = inrange(unempweeks,12,52) & inrange(empweeks[_n-1],28,52)
label variable eunemp "Job loss"

gen eunempdata = inrange(age,25,55)
gen eunempatrisk = inrange(empweeks,28,52)

// Become sick
by id (waveorder): gen byte eill = illlong==1 & illlong[_n-1]==0 
label variable eill "Become sick"
gen eilldata = inrange(age,25,55)
gen eillatrisk = inrange(empweeks,28,52)

// Family break-up
by id (waveorder): 				/// 
  gen byte efambreak =  mpairs==0 & mpairs[_n-1]==1 ///
  & inlist(rel2head,1,2) & mar!=3 & inrange(hhsize0to14[_n-1],1,.) 
label variable efambreak "Family break-up"

gen efambreakdata = inrange(age,25,55) 
gen efambreakatrisk = mpairs==1 & inrange(hhsize0to14[_n-1],1,.) 

// Retirement
by id (waveorder): 						/// 
  gen atrisk = sum(age>=55 & !mi(age) & empweeks>=32 & empweeks<.) 

by id (waveorder): replace atrisk = atrisk >= 2 /// 
  if age>=55 & age<. 
drop if atrisk == 2 // 1 obs with age=61 in 2004 and age=49 in 2005

gen byte eretire = empweeks <= 8 & f1.empweeks <= 8 & f2.empweeks<=8  ///
  if atrisk & !mi(empweeks,f1.empweeks,f2.empweeks) & wave < 1996
replace eretire = empweeks <= 8 & f1.empweeks <= 8    ///
  if atrisk & !mi(empweeks,f1.empweeks) & wave >= 1996

bys id eretire (wave): replace eretire = 0 if _n>1 & eretire == 1
replace eretire = 0 if mi(eretire)

lab var eretire "Old age labor force exit"

gen eretiredata = age >= 55 & age < .
gen eretireatrisk = inrange(empweeks,8,.)
drop atrisk

// End Matters
// -----------

ren x11102 hhnr
label variable wave "Year"

compress
order hhnr id wave cpi sqnr rel2head weight strat state /// 
  men age race  /// 
  hhsize* mar mpairs moveout 							///  
  industry occup whours empweeks unempweeks empdur emplst 	/// 
  edu yedu 								/// 
  ill* sick shealth 					/// 
  poor indlabinc* hhlabinc* hhpregov* hhpostgov* debt* creditordemand ///
  eunemp efambreak eretire eill

sort id waveorder
save US.dta, replace

exit


Notes
-----

(1) Keep Heads and Wifes --> Relationship to Head "1" oder "10" (Head)
bzw. "2", "20" oder "22" (Wife), vgl. Online-FAQ, im CNEF schon
zusammengefasst. 


(2) Hesig (25.3.2011) hat festgestellt, dass es Inkonsistenzen
zwischen Education("grades completed")-Variablen im 2007er
Individual-File und den laut codebook auf diesen basierenden Education
Variablen im  CNEF gibt. Mögliche Erklärung: CNEF-Daten basieren auf
alter Datenlieferung

Variablen werden überschreiben - aber nur dann, wenn psid_edu gültigen
wert hat. Oft ist dies nicht der Fall... vielleicht wurde im CNEF
fortgeschrieben?  Codebook dokumentiert das nicht...
