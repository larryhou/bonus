insheet using data.txt, clear
format %7.0fc 工资区间 扣除数
format %9.0fc 奖金区间
format %3.2f 税率
list 

gen 盲点 = ((奖金区间[_n] * (1 - 税率[_n]) + 扣除数[_n]) - 扣除数[_n + 1]) / (1 - 税率[_n + 1]), a(奖金区间)
format %9.0fc 盲点

gen 盲距 = 盲点 - 奖金区间, a(盲点)
format %8.0fc 盲距

gen 税后 = 奖金区间[_n] - (奖金区间[_n] * 税率[_n] - 扣除数[_n])
format %9.0fc 税后
list

mkmat *区间 税率 扣除数 盲* 税后, mat(T)
matrix list T

clear
set obs 2000

gen bonus = _n * 1000
format %9.0fc bonus

drop if bonus < 3500

list in 1/5

gen tax=.
format %8.0fc tax

gen remain=.
format %9.0fc remain

local node = 0
quiet forvalues level = 1/7 {
	replace tax = bonus * T[`level',3] - T[`level', 4] if bonus <= T[`level',2] & bonus > `node'
	replace remain = bonus - (bonus * T[`level',3] - T[`level', 4]) if bonus <= T[`level',2] & bonus > `node'
	
	gen n`level' = bonus * T[`level',3] - T[`level', 4]
	replace n`level' = . if bonus <= T[`level',2]
	
	local node = T[`level',2]
}

quiet drop if tax == . | remain == .

#delimit ;
line tax n* bonus if bonus <= 300000, xsize(9.2) ysize(5)
	lw(medium) lc(red) legend(off)
	ylabel(#10, format(%8.0fc) labs(vsmall) glw(vthin))
	ymtick(##5, grid glw(vthin))
	xlabel(#30, format(%9.0fc) angle(30) labs(vsmall) grid glw(vthin))
	ytitle("tax", size(vsmall))
	xtitle("bonus", size(vsmall))
;

#delimit cr
graph export bonus-tax.pdf, as(pdf) replace

forvalues i = 1/7 {
	local t`i'=strofreal(`=T[`i',2]', "%8.0fc") + "/" + strofreal(`=T[`i',7]', "%9.0fc")
}

#delimit ;
line remain bonus if bonus <= 1200000, xsize(9.2) ysize(5) xaxis(1,2)
	lw(medium) lc(red) legend(off)
	ylabel(#10, format(%8.0fc) angle(75) labs(vsmall) glw(vthin))
	ymtick(##5, grid glw(vthin))
	xlabel(#12, format(%9.0fc) angle(0) labs(vsmall) grid glw(vthin))
	ytitle("gain", size(vsmall))
	xtitle("bonus", size(vsmall))
	xline(`=T[1,5]' `=T[2,5]' `=T[3,5]' `=T[4,5]' `=T[5,5]' `=T[6,5]', lw(vthin) lp(-.))
	xlabel(`=T[1,5]' `=T[2,5]' `=T[3,5]' `=T[4,5]' `=T[5,5]' `=T[6,5]', axis(2) angle(30) labs(vsmall))
	xtitle("", axis(2))
	xmtick(##5, grid glw(vthin))
	text(`=T[1,7]' `=T[1,2]' "`t1'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[2,7]' `=T[2,2]' "`t2'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[3,7]' `=T[3,2]' "`t3'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[4,7]' `=T[4,2]' "`t4'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[5,7]' `=T[5,2]' "`t5'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[6,7]' `=T[6,2]' "`t6'", size(vsmall) placement(nw) orient(vertical))
;

#delimit cr
graph export bonus-gain.pdf, as(pdf) replace
