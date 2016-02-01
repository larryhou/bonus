insheet using data.txt, clear
drop 奖金区间

format %7.0fc 工资区间 扣除数
format %3.2f 税率
list 

gen 盲点 = ((工资区间[_n] * (1 - 税率[_n]) + 扣除数[_n]) - 扣除数[_n + 1]) / (1 - 税率[_n + 1]), a(工资区间)
format %9.0fc 盲点

gen 盲距 = 盲点 - 工资区间, a(盲点)
format %8.0fc 盲距

gen 税后 = 工资区间[_n] - (工资区间[_n] * 税率[_n] - 扣除数[_n])
format %9.0fc 税后
list

mkmat 工资区间 税率 扣除数 盲* 税后, mat(T)
matrix list T

clear
set obs 1000

gen salary = _n * 100
format %9.0fc salary

gen remain=.
format %9.0fc remain

local node = 0
forvalues n = 1/7 {
	replace remain = salary - (salary * T[`n',2] - T[`n', 3]) if salary <= T[`n',1] & salary > `node'
	
	gen r`n' = salary - (salary * T[`n',2] - T[`n', 3])
	replace r`n' = . if salary <= T[`n',1]
	local node = T[`n',1]
}

forvalues i = 1/7 {
	local t`i'=strofreal(`=T[`i',1]', "%8.0fc") + "/" + strofreal(`=T[`i',6]', "%9.0fc")
}

#delimit ;
line remain salary, xsize(9.2) ysize(5)
	lw(medium) lc(red) legend(off)
	ylabel(#10, format(%8.0fc) angle(75) labs(vsmall) glw(vthin))
	ymtick(##5, grid glw(vthin))
	xlabel(#10, format(%9.0fc) angle(0) labs(vsmall) grid glw(vthin))
	ytitle("gain", size(vsmall))
	xtitle("salary", size(vsmall))
	xline(`=T[1,1]' `=T[2,1]' `=T[3,1]' `=T[4,1]' `=T[5,1]' `=T[6,1]', lw(vthin) lp(-.))
	//xlabel(`=T[1,1]' `=T[2,1]' `=T[3,1]' `=T[4,1]' `=T[5,1]' `=T[6,1]', axis(2) angle(30) labs(vsmall))
	//xtitle("", axis(2))
	xmtick(##5, grid glw(vthin))
	text(`=T[1,6]' `=T[1,1]' "`t1'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[2,6]' `=T[2,1]' "`t2'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[3,6]' `=T[3,1]' "`t3'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[4,6]' `=T[4,1]' "`t4'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[5,6]' `=T[5,1]' "`t5'", size(vsmall) placement(nw) orient(vertical))
	text(`=T[6,6]' `=T[6,1]' "`t6'", size(vsmall) placement(nw) orient(vertical))
;

#delimit cr
graph export salary-gain.pdf, as(pdf) replace
