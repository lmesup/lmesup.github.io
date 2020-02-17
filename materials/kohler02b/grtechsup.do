* Grafik der 10 häufigsten SO-Sequenzen, balanced Panel-Design
version 6.0
clear
set memory 60m

use techsup

capture program drop stab5b
	program define stab5b
		gph open, saving(stab5b, replace)
			tempvar tno
			local opt `"s(oo) border sort ylab(0(1)3) key1(" ") gap(8) "'
			local opt `" `opt' l1(" ") b2(" ") xtick(1(1)5) xlab(1(1)5) "'
	    	local pen = f[1]
			graph pid seq1 tno, c(.L) pen(0`pen')  /*
			*/ `opt' bbox(0,0,5200,17000,500,250,1) 
	    	local pen = f[2]
			graph seq2 tno, c(L) pen(`pen') /*
			*/ `opt' bbox(0,15000,5100,32000,500,250,1) 
	    	local pen = f[3]
			graph pid seq3 tno, c(.L) pen(0`pen') /*
			*/  `opt' bbox(4200,0,9400,17000,500,250,1) 
	    	local pen = f[4]
			graph seq4 tno, c(L) pen(`pen')  /*
			*/  `opt' bbox(4200,15000,9400,32000,500,250,1) 
	    	local pen = f[5]
			graph pid seq5 tno, c(.L) pen(0`pen')  /*
			*/  `opt' bbox(8600,0,13800,17000,500,250,1) 
	    	local pen = f[6]
			graph seq6 tno, c(L) pen(`pen')  /*
			*/ `opt'  bbox(8600,15000,13800,32000,500,250,1) 
	    	local pen = f[7]
			graph pid seq7 tno, c(.L) pen(0`pen') /*
			*/ `opt'  bbox(13000,0,18200,17000,500,250,1) 
	    	local pen = f[8]
			graph seq8 tno, c(L) pen(`pen')  /*
			*/  `opt' bbox(13000,15000,18200,32000,500,250,1) 
	    	local pen = f[9]
			graph pid seq9 t, c(.L) pen(0`pen') /*
			*/ `opt' bbox(17400,0,22600,17000,500,250,1) 
	    	local pen = f[10]
			graph seq10 t, c(L) pen(`pen') /*
			*/ `opt' bbox(17400,15000,22600,32000,500,250,1) 
			gph pen 1
			gph font 500 250
			gph text 23000 15000 0 0 Zeitablauf
		gph close
	end
stab5b

exit
