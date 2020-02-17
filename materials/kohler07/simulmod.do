	// Simulation that investigates porperties of the models used
	// ----------------------------------------------------------

version 9.2
	clear
	
	set obs 10000
	gen cntry = int(uniform()*10)+1 

	gen abspos1 = uniform()*10 //
    gen abspos2 = cntry + invnorm(uniform())*10
	gen abspos3 = cntry + invnorm(uniform())   
	
	gen  e_i = invnorm(uniform())

	forv i = 1/3 {
		
		egen soc`i' = mean(abspos`i'), by(cntry)

		gen container`i' = .
		gen euA`i' = .
		gen euB`i' = .
		levelsof cntry, local(K)
		foreach k of local K {
			local u = uniform()*3
			replace container`i' = `u' + abspos`i' - soc`i' + e_i if cntry==`k'
			replace euA`i' = `u' + abspos`i' + e_i  if cntry==`k'
			replace euB`i' = `u' + soc`i' + e_i  if cntry==`k'
		}

		gen demean`i' = abspos`i' - soc`i'

		egen axis`i' = axis(soc`i' cntry), label(cntry)
	}

	iis cntry


	// Check 1: Situation, if depvar depend on country, but countries are uncorellated with mean abspos

	sc abspos1 axis1 [aw=container1], ms(oh) name(g1, replace) nodraw
	sc abspos1 axis1 [aw=euA1], ms(oh) name(g2, replace)  nodraw
	sc abspos1 axis1 [aw=euB1], ms(oh) name(g3, replace)  nodraw
	graph combine g1 g2 g3

	reg container1 abspos1
	reg container1 abspos1 soc1
	reg container1 soc1
	xtreg container1 abspos1, re
	xtreg container1 abspos1 soc1, re
	xtreg container1 abspos1, fe

	reg euA1 abspos1
	reg euA1 abspos1 soc1
	reg euA1 soc1
	xtreg euA1 abspos1, re
	xtreg euA1 abspos1 soc1, re
	xtreg euA1 abspos1, fe

	reg euB1 abspos1
	reg euB1 abspos1 soc1
	reg euB1 soc1
	xtreg euB1 abspos1, re
	xtreg euB1 abspos1 soc1, re
	xtreg euB1 abspos1, fe


	// Check 2: Situation, if depvar depend on country, and countries are mildely corellated with mean abspos2

	sc abspos2 axis2 [aw=container2], ms(oh) name(g1, replace) nodraw
	sc abspos2 axis2 [aw=euA2], ms(oh) name(g2, replace)  nodraw
	sc abspos2 axis2 [aw=euB2], ms(oh) name(g3, replace)  nodraw
	graph combine g1 g2 g3

	reg container2 abspos2
	reg container2 abspos2 soc2
	reg container2 soc2
	xtreg container2 abspos2, re
	xtreg container2 abspos2 soc2, re
	xtreg container2 abspos2, fe

	reg euA2 abspos2
	reg euA2 abspos2 soc2
	reg euA2 soc2
	xtreg euA2 abspos2, re
	xtreg euA2 abspos2 soc2, re
	xtreg euA2 abspos2, fe

	reg euB2 abspos2
	reg euB2 abspos2 soc2
	reg euB2 soc2
	xtreg euB2 abspos2, re
	xtreg euB2 abspos2 soc2, re
	xtreg euB2 abspos2, fe

	// Check 3: Situation, if depvar depend on country, and countries are strongly corelated with mean abspos3

	sc abspos3 axis3 [aw=container3], ms(oh) name(g1, replace) nodraw
	sc abspos3 axis3 [aw=euA3], ms(oh) name(g2, replace)  nodraw
	sc abspos3 axis3 [aw=euB3], ms(oh) name(g3, replace)  nodraw
	graph combine g1 g2 g3

	reg container3 abspos3
	reg container3 abspos3 soc3
	reg container3 soc3
	xtreg container3 abspos3, re
	xtreg container3 abspos3 soc3, re
	xtreg container3 abspos3, fe

	reg euA3 abspos3
	reg euA3 abspos3 soc3
	reg euA3 soc3
	xtreg euA3 abspos3, re
	xtreg euA3 abspos3 soc3, re
	xtreg euA3 abspos3, fe

	reg euB3 abspos3
	reg euB3 abspos3 soc3
	reg euB3 soc3
	xtreg euB3 abspos3, re
	xtreg euB3 abspos3 soc3, re
	xtreg euB3 abspos3, fe



	
