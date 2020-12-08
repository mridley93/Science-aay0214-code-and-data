* Ridley, Rao, Schilbach and Patel 2020-----------------------------------------*

/* This code creates Figure 3 from the paper.
	
	
*Last modified: 2020/11/28
*Last modified by: Matthew Ridley
*/

cd ..


import delimited "Raw Data/Figure 3/barchart_data.csv", varnames(1) case(lower) clear

*Convert from 95% CIs to +/- 1 SEM
replace uci = coeff + (uci-coeff)*(1/1.96)
replace lci = coeff + (lci-coeff)*(1/1.96)

*Control where bracket appears 
set obs 5

replace t = 2.005 if _n == 4 //left end of bracket
replace t = 2.995 if _n == 5 //right end of bracket
replace bracket = 1.01 if _n >= 4 //height of bracket

#delimit ;


graph twoway (bar coeff t if t == 1, color(gs7) barw(0.6))															/* bar 1: overall effect */
			 (bar coeff t if t == 2, color(ltblue) barw(0.6)) 														/* bar 2: no drought */			
			 (bar coeff t if t == 3, color(navy) barw(0.6))															/* bar 3: drought */
			 (rcap uci lci t, color(black)) 																		/* error bars */
			 (connected bracket t if _n >=4, lwidth(medthick) color(black) msymbol(i)), 							/* comparison bracket */
			 text(1.01 2.5 " *** ", place(c) box fcolor(white) lcolor(white))										/* stars */		
			 text(1.0205 2 "|", place(s)) text(1.0205 3 "|", place(s))												/* bracket ends */
			 xscale(range(0.3 3.7)) xlabel(1 `""Average effect" "for all districts""' 								/* x axis */
										   2 `""Effect for districts" "not in drought""' 
										   3 `""Effect for districts" "in drought""') 
			 xtitle("{bf:Treatment effect of cash transfers}", height(7)) 
			 yscale(range(0 1.02)) ylabel(0(0.2)1, grid gmax) ytitle("{bf:Reduction in suicides per 100,000}")		/* y axis */
			 scheme(s1color) legend(off) plotregion(margin(b = 0) style(none))										/* overall look */
			 title("Reductions in suicide rates due to cash transfers")												/* title */
			 ;

graph export "Output/png/fig_3.png", replace;
graph export "Output/eps/fig_3.eps", replace;
graph export "Output/svg/fig_3.svg", replace;

#delimit cr

cd Code
