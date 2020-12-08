* Ridley, Rao, Schilbach and Patel 2020-----------------------------------------*

/* This code creates Figure 7 from the paper.
	
	
*Last modified: 2020/04/29
*Last modified by: Matthew Ridley
*/
cap cd Code
*-------------------------------------------------------------------------------*

include clean_country_names.do
cd ..

** 1. Import mental health workers data ----------------------------------------**
**------------------------------------------------------------------------------**

import delimited "Raw Data/Figure 7/MH_6,MH_7,MH_8,MH_9.csv", varnames(1) clear
ren year workers_year //data is from the most recent year available for each country
la var workers_year "Year that the mental health workers data is from"

clean_country_names

**------------------------------------------------------------------------------**
**------------------------------------------------------------------------------**




** 2. Import and merge World Bank income classifications------------------------**
** -----------------------------------------------------------------------------**

preserve
 import excel "Raw Data/Figure 7/OGHIST.xls", sheet("Country Analytical History") cellrange(A6) ///
													  firstrow clear
 ren Dataforcalendaryear country
 ds, has(varl "2016") //Pick classification from 2016
 foreach var in `r(varlist)' { 
	ren `var' class2016 // rename for convenience
 }
 
 keep country class2016
 drop in 1/5 //these rows just give the income cutoffs; data proper starts at row 6
 drop if country == ""
 
 replace class2016 = "Low" if class2016 == "L"
 replace class2016 = "Lower middle" if class2016 == "LM"
 replace class2016 = "Upper middle" if class2016 == "UM"
 replace class2016 = "High" if class2016 == "H"
 
 clean_country_names
 
 save temp/temp, replace
restore

merge m:1 country using temp/temp, gen(class_merge) keepus(class2016)

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 3. Prepare variables---------------------------------------------------------**
** -----------------------------------------------------------------------------**

* Define the order in which the income categories will be plotted
gen ord = 1 if class2016 == "Low"
replace ord = 2 if class2016 == "Lower middle"
replace ord = 3 if class2016 == "Upper middle"
replace ord = 4 if class2016 == "High"

**------------------------------------------------------------------------------**
**------------------------------------------------------------------------------**




** 4. Plot graph----------------------------------------------------------------**
** -----------------------------------------------------------------------------**

* Define the order in which to plot the variables
order country psychiatrists socialworkers psychologists nurses


* Plot the graph
graph bar psychiatrists-nurses, over(class2016, sort(ord)) 																				  		/// bars
	      b2title("{bf:Income category}") 																								  		/// x axis
		  ytitle("Number per 100,000 inhabitants") yscale(titlegap(*3)) ylabel(0 10 20 30 40, grid gmax)								  		/// y axis
		  legend(order(1 "Psychiatrists" 2 "Mental health social workers" 3 "Psychologists" 4 "Mental health nurses") span size(small) cols(2)) /// legend
		  bar(1, color(bluishgray)) bar(2, color(ltblue)) bar(3, color(emidblue)) bar(4, color(navy)) 											/// bar look
		  scheme(s1color)  plotregion(margin(b = 0) style(none)) 																				/// overall look
	
graph export "Output/png/fig_7.png", replace
graph export "Output/eps/fig_7.eps", replace
graph export "Output/svg/fig_7.svg", replace
cd Code
