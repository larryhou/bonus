mat input T = (0, 36000, 0.03, 0\36000, 144000, 0.1, 2520\144000, 300000, 0.20, 16920\300000, 420000, 0.25, 31920\420000, 660000, 0.30, 52920\660000, 960000, 0.35, 85920\960000, 1200000, 0.45, 181920)
mat list T

clear
capture scalar drop _all

set obs `=T[rowsof(T),2] / 2000 + rowsof(T)'
gen bonus=.
gen tax=.

scalar r=0
forvalues n = 1/`=rowsof(T)' {
	disp `n'
	forvalues m = `=T[`n',1]' (2000) `=T[`n',2]' {
		disp `m', r
		scalar r = r + 1
		replace bonus = `m' in `=r'
		replace tax = `m' * T[`n',3] - T[`n', 4] in `=r'
	}
}

forvalues n = 1/`=rowsof(T)-1' {
	gen t`n' = bonus * T[`n',3] - T[`n',4]
	replace t`n'=. if bonus <= T[`n',2]
}

format bonus tax %10.0fc

#delimit ;
line tax t? bonus, xsize(16) ysize(9) lc(red) lw(*1 *.25 ...)
xlabel(`=T[1,1]' `=T[2,1]' `=T[3,1]' `=T[4,1]' `=T[5,1]' `=T[6,1]' `=T[7,1]')
xlabel(, labs(*.5) grid glw(*.5))
ylabel(, labs(*.5) glw(*.5) glc(*1.1))
ymtick(##5, grid glw(*.5))
xtitle("计税额度", size(*.75) margin(vsmall))
ytitle("个税", size(*.75))
legend(off)
graphr(margin(tiny))
;
#delimit cr
