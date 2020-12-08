* Ridley, Rao, Schilbach and Patel 2020-----------------------------------------*

/* This code creates Figure 2 from the paper.
	
	
*Last modified: 2020/05/07
*Last modified by: Matthew Ridley
*/
cap cd Code
*-------------------------------------------------------------------------------*


include clean_country_names.do //defines a program that standardizes country names, for merging on country

cd ..


*-------------------------------------------------------------------------------*




** 1. Import mental health expenditure data ------------------------------------**
** -----------------------------------------------------------------------------**

import excel "Raw Data/Figure 2/Total Mental Health Expenditure (countries-split).xlsx", ///
		  firstrow case(lower) clear

destring totalmentalhealthexpenditure, ignore("-") replace

clean_country_names

**Drop Outliers ---------------------------------------------------------------
*Kiribati apparently spends, per person, about its entire GDP per capita on 
*mental health - 10 times its *total* health budget according to the next dataset.

*Cyprus and Cuba apparently spend over 50% of their total health budgets on 
*mental health. No other country comes close. 

*We assume that these numbers are inaccurate, and drop these countries.

drop if country == "kiribati" | country == "cyprus" | country == "cuba" 
*-------------------------------------------------------------------------------

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 2. Import and merge total health expenditure data ---------------------------**
** -----------------------------------------------------------------------------**

preserve
 import excel "Raw Data/Figure 2/NHA Indicators (1).xlsx", firstrow case(lower) clear
 ren (d e f) (tot_HE_2015 tot_HE_2016 tot_HE_2017)
 ren countries country
 
 keep if indicators == "Current health expenditure by financing schemes"
 
 clean_country_names
 
 save temp/temp, replace
restore
 
merge m:1 country using temp/temp, /*keep(1 3)*/ keepus(tot_HE_2016) gen(tot_he_merge)

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 3. Import and merge World Bank income classifications------------------------**
** -----------------------------------------------------------------------------**

preserve
 import excel "Raw Data/Figure 7/OGHIST.xls", sheet("Country Analytical History") cellrange(A6) ///
													  firstrow clear
 ren Dataforcalendaryear country
 ds, has(varl "2016") // Pick classification from 2016
 foreach var in `r(varlist)' {
	ren `var' class2016
 }
 
 keep country class2016
													  
 replace class2016 = "Low" if class2016 == "L"
 replace class2016 = "Lower middle" if class2016 == "LM"
 replace class2016 = "Upper middle" if class2016 == "UM"
 replace class2016 = "High" if class2016 == "H"
 drop in 1/5 //these rows just give the income cutoffs; data proper starts at row 6
 drop if country == ""
 
 clean_country_names
 
 save temp, replace
restore

merge m:1 country using temp, gen(class_merge)

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 4. Prepare variables---------------------------------------------------------**
** -----------------------------------------------------------------------------**

* Y variable: percent expenditure on mental health
gen pct_mhe = 100*totalmentalhealthexpenditure/tot_HE_2016


* X variable: Define the order in which the income categories will be plotted
gen 	ord = 1 if class2016 == "Low"
replace ord = 2 if class2016 == "Lower middle"
replace ord = 3 if class2016 == "Upper middle"
replace ord = 4 if class2016 == "High"

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 5. Plot graph----------------------------------------------------------------**
** -----------------------------------------------------------------------------**

*drop if country == "bahamas" //the figure submitted last time excludes the bahamas for some reason.

graph bar pct_mhe, over(class2016, sort(ord)) 																				/// bars
	b2title("{bf:Income category}") 																						/// x axis
	ytitle("Mental health expenditure (% of total health expenditure)") yscale(titlegap(*3)) ylabel(0 1 2 3 4, grid gmax)	/// y axis
	bar(1, color("76 108 140")) bar(2, color("76 108 140")) 																/// bar look
	scheme(s1color)  plotregion(margin(b = 0) style(none)) 																	/// overall look
	
graph export "Output/png/fig_2.png", replace
graph export "Output/eps/fig_2.eps", replace
graph export "Output/svg/fig_2.svg", replace
cd Code
