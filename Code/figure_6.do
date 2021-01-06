* Ridley, Rao, Schilbach and Patel 2020-----------------------------------------*

/* This code creates Figure 6 from the paper.
	
*Last modified: 2020/11/28
*Last modified by: Matthew Ridley
*/
cap cd Code
include clean_country_names.do

cd ..


** 1. Import depression and anxiety prevalence data ----------------------------**
** -----------------------------------------------------------------------------**

import delimited "Raw Data/Figure 6/IHME-GBD_2017_DATA-a272a981-1.csv", varnames(1) clear
ren location country
ren year prevalence_year //2017 for all obs
ren val rate //rate per 100,000

keep if measure == "Prevalence" //as opposed to YLD

drop sex age measure metric

clean_country_names

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 2. Import and merge gdp per capita data -------------------------------------**
** -----------------------------------------------------------------------------**

preserve
 import delimited "Raw Data/Figure 6/Data_Extract_From_World_Development_Indicators/Data.csv", varnames(1) clear
 
 ren *countryname country
 ren yr2017 gdppc //Using GDP per capita data from 2017 - same year as prevalence
 
 foreach var of varlist yr* {
	replace `var' = "." if `var' == ".."
 }
 destring, replace
 
 drop if country == ""
 
 clean_country_names
 
 save temp, replace
restore

merge m:1 country using temp, keep(1 3) keepus(gdppc) gen(gdp_merge)

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 3. Prepare variables --------------------------------------------------------**
** -----------------------------------------------------------------------------**

* X variable: log GDP per capita ($000s PPP)
replace gdppc = "." if gdppc == ".."
destring gdppc, replace
replace gdppc = gdppc/1000
gen lngdppc = ln(gdppc)

* Y variable: percent prevalence
replace rate = rate/1000 //convert rate per 100000 to %
ren rate pct_prevalence

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 4. Plot graphs --------------------------------------------------------------**
** -----------------------------------------------------------------------------**

*Plot depression graph----------------------------------------------------------

*Correlation coefficient and p value
pwcorr pct_prevalence lngdppc if cause == "Depressive disorders", sig
local rho: di %4.3f `r(rho)'
matrix sig = r(sig)
local pval: di %3.2f sig[2,1]

*Line of best fit
reg pct_prevalence lngdppc if cause == "Depressive disorders"
predict p_pctdep

*Plot
twoway (scatter pct_prevalence gdppc if cause == "Depressive disorders", color("76 108 140")) 	/// scatter plot
		(line p_pctdep gdppc, sort color(black)),  											  	/// line of best fit
		note("Correlation coef. {it: r} = `rho' ({it:p} = `pval')") 						  	/// correlation and p-value
		xscale(log) xlabel(1 2 4 8 16 32 64) xtitle("{bf:Log GDP per capita ($000s PPP)}") 		/// x axis
		yscale(range(0 8)) ylabel(0(2)8, grid gmax) ytitle("{bf:Point prevalence (%)}") 		/// y axis
		legend(off) scheme(s1color)  plotregion(margin(b = 0) style(none)) 						/// overall look
		title("Depression") 																	/// title
		saving(temp/prev_dep, replace)

*-------------------------------------------------------------------------------


*Plot anxiety graph-------------------------------------------------------------

*Correlation coefficient and p value
pwcorr pct_prevalence lngdppc if cause == "Anxiety disorders", sig
local rho: di %4.3f `r(rho)'
matrix sig = r(sig)
local pval: di %3.2f sig[2,1]

*Line of best fit
reg pct_prevalence lngdppc if cause == "Anxiety disorders"
predict p_pctanx

*Plot
twoway (scatter pct_prevalence gdppc if cause == "Anxiety disorders", color("76 108 140")) 	/// scatter plot
		(line p_pctanx gdppc, sort color(black)),  											/// line of best fit
		note("Correlation coef. {it: r} = `rho' ({it:p} = `pval')") 						/// correlation and p-value
		xscale(log) xlabel(1 2 4 8 16 32 64) xtitle("{bf:Log GDP per capita ($000s PPP)}")	/// x axis
		yscale(range(0 8)) ylabel(0(2)8, grid gmax) ytitle("{bf:Point prevalence (%)}")		/// y axis
		legend(off) scheme(s1color)  plotregion(margin(b = 0) style(none)) 					/// overall look
		title("Anxiety") 																	/// title
		saving(temp/prev_anx, replace)
		

*-------------------------------------------------------------------------------

*Combine the two graphs---------------------------------------------------------
graph combine "temp/prev_dep" "temp/prev_anx", graphregion(color(white))
foreach ext in png eps svg pdf {
	graph export "Output/`ext'/fig_6.`ext'", replace
}

cd Code
