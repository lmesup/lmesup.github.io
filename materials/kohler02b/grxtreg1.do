version 6.0
clear
set obs 6
input i t X Y
 1 1 2 6
 1 2 3 5.7
 1 3 4 5
 2 1 4 15
 2 2 5 11
 2 3 6 6
gen id=i==2
reg Y X
predict yhat
reg Y X id
predict yh1 if id==0
predict yh2 if id==1
gen Y1=Y if id==0
gen Y2=Y if id==1
lab var Y1 "Y_(i=1)"
lab var Y2 "Y_(i=2)"

capture program drop graphik
program define graphik
    sum X
    local x = r(max) + .1
    sum X if i == 1
    local x1 = r(max) + .1
    sum X if i == 2
    local x2 = r(min) - .1
    sum yhat
    local y = r(max)
    sum yh1
    local y1 = r(min)
    sum yh2
    local y2 = r(max)
    gph open, saving(xtreg1, replace)
        graph yhat Y1 yh1 Y2 yh2 X, /*
        */ c(l[-#].l.l) s(iOiTi) pen(22222) /*
        */ bor xlab(2(1)6) ylab(3(3)15) /*
        */ xscale(2,6.5) key1(s(O) p(2) "Y(i=1)") key2(s(T) p(2) "Y(i=2)") /*
        */ l1title(Y) gap(3)
        local ay = r(ay)
        local by = r(by)
        local ax = r(ax)
        local bx = r(bx)
        local r = `ay' * `y' + `by'
        local c = `ax' * `x' + `bx'
        local r1 = `ay' * `y1' + `by'
        local c1 = `ax' * `x1' + `bx'
        local r2 = `ay' * `y2' + `by'
        local c2 = `ax' * `x2' + `bx'
        gph pen 1
		gph font 600 300
        gph text `r' `c' 0 -1 a + bX
        gph text `r1' `c1' 0 -1 a_1 + bX
        gph text `r2' `c2' 0  1 a_2 + bX
    gph close
end
graphik
