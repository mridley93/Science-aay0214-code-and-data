* Ridley, Rao, Schilbach and Patel 2020-----------------------------------------*

/* This code creates Figure 1 from the paper.
	
	
*Last modified: 2020/11/28
*Last modified by: Matthew Ridley
*/

*-------------------------------------------------------------------------------*
cd ..

import excel "Raw Data/Figure 1/arvindetal_2019_table1.xlsx", firstrow clear

*Clean variable names
ren (lower upper F G) (curlower curupper lifelower lifeupper)
ren Current curpct 
ren Lifetime lifepct
foreach var in curlower lifelower {
	replace `var' = subinstr(`var',"(","",.)
}
foreach var in curupper lifeupper {
	replace `var' = subinstr(`var',")","",.)
}



*Prepare data for plotting------------------------------------------------------*

destring, replace

reshape long @pct @lower @upper, i(Incomequintile) j(cur_or_life) str //cur_or_life indicates whether 
																	   *the number in question is current or lifetime prevalence
																	   
*Convert from 95% CIs to +/- 1 SEM
replace lower = pct + (lower-pct)*(1/1.96)
replace upper = pct + (upper-pct)*(1/1.96)

*Make cur_or_life numeric
encode cur_or_life, g(c2)
drop cur_or_life
gen cur_or_life = c2 //1 is current, 2 is lifetime

gen group = (Incomequintile - 1)*3 + cur_or_life //indicates position each bar will appear in the plot

*-------------------------------------------------------------------------------*


*Create graph-------------------------------------------------------------------*

graph twoway (bar pct group if cur_or_life == 1, color(navy)) (rcap upper lower group if cur_or_life == 1, color(black) msize(vlarge)),  ///
		xlabel( 1 "Lowest" 4 "Second" 7 "Third" 10 "Fourth" 13 "Highest", noticks) ///
		legend(order(1 "Current prevalence" 2 "±1 SEM")) scheme(s1color) plotregion(margin(b = 0) style(none)) ///
       xtitle("Income quintile") ytitle("Prevalence of depression (%)") yscale(range(0 4)) ylabel(0(1)4, grid gmax)
graph export "Output/png/fig_1.png", replace
graph export "Output/eps/fig_1.eps", replace
graph export "Output/svg/fig_1.svg", replace



