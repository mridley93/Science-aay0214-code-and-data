* Ridley, Rao, Schilbach and Patel 2020-----------------------------------------*

/* This code imports, cleans and merges the following datasets, for use in 
	creating figures:
	
	Data																Source
	1. Numbers of psychiatrists, psychologists, mental health			WHO
	   nurses, and mental health social workers by country
	   (some cleaning already done in Excel)
	
	2. Prevalence of depression and anxiety by country					GBD 2017
	
	3. Expenditure on mental health by country							WHO
	
	4. Overall health expenditure by country							WHO
	
	5. Country GDP per capita (at Purchasing Power Parity)				World Bank
	
	6. Country classifications into low/middle/high-income				World Bank
	
	
*Last modified: 2020/04/20
*Last modified by: Matthew Ridley
*/



cd "C:\Users\mwrix\Dropbox (MIT)\Mental Health and Poverty -- Science\Figures\"


* 0. Define a program to standardize country names across the different datasets to make
*	  merging on country possible. 
cap program drop clean_countries
program clean_countries
	
	

	replace country = lower(country)

	replace country = subinstr(country,"republic of","",.)
	replace country = subinstr(country,"the","",.)
	replace country = subinstr(country,",","",.)
	replace country = subinstr(country,"ô","o",.)
	replace country = subinstr(country,"(","",.)
	replace country = subinstr(country,")","",.)
	replace country = subinstr(country,".","",.)

	replace country = strtrim(stritrim(country))
	

	replace country = "bolivia" if country == "bolivia plurinational state of" | country == "bolivia plurinational states of"
	replace country = "brunei" if country == "brunei darussalam"
	replace country = "cabo verde" if country == "cape verde"
	replace country = "dr congo" if country == "congo dem rep" | country == "democratic congo"
	replace country = "kyrgyzstan" if country == "kyrgyz republic"
	replace country = "laos" if country == "lao people's democratic republic" | country == "lao people's democratic" | country == "lao pdr"
	replace country = "micronesia" if country == "federated states of micronesia" | country == "micronesia federated states of"
	replace country = "north macedonia" if country == "the north macedonia" | country == "yugoslav macedonia" | country == "fyr macedonia"
	replace country = "slovakia" if country == "slovak republic"
	replace country = "united states" if country == "united states of america"
	replace country = "vietnam" if country == "viet nam"
	


end


*-------------------------------------------------------------------------------**




** 1. Import number of mental health workers by country-------------------------**

import delimited "Cleaned Data\who_psychiatrists_cleaned.csv", varnames(1) clear
ren year workers_year //data is from the most recent year available for each country
la var workers_year "Year that the mental health workers data is from"

clean_countries

**------------------------------------------------------------------------------**




**2. Import and merge depression and anxiety prevalence data--------------------**

preserve
 import delimited "Raw Data\IHME-GBD_2017_DATA-a272a981-1.csv", varnames(1) clear
 ren location country
 ren year prevalence_year //2017 for all obs
 ren val rate //rate per 100,000
 
 keep if measure == "Prevalence" //as opposed to YLD
 
 drop sex age measure metric
 
 clean_countries
 
 save temp, replace
restore

merge 1:m country using temp, gen(prevalence_merge)

**------------------------------------------------------------------------------**




** 3. Import mental health expenditure data-------------------------------------**

preserve
 import excel "Raw Data\Total Mental Health Expenditure (countries-split).xlsx", ///
			  firstrow case(lower) clear

 destring totalmentalhealthexpenditure, ignore("-") replace

 clean_countries

 **DROPPING OUTLIERS-------
 *Kiribati apparently spends, per person, about its entire GDP per capita on 
 *mental health - 10 times its *total* health budget according to the next dataset.
  
 *Cyprus and Cuba apparently spend over 50% of their total health budgets on 
 *mental health. No other country comes close. 

 *We assume that these numbers are inaccurate, and drop these countries.
 
 drop if country == "kiribati" | country == "cyprus" | country == "cuba" 
 *-------------------------
 
 save temp, replace
restore

merge m:1 country using temp, keepus(totalmentalhealthexpenditure reportedcurrency) ///
							  gen(mhe_merge)

**------------------------------------------------------------------------------**
 
 
 

** 4. Import and merge total health expenditure data----------------------------**
 
preserve
 import excel "Raw Data\NHA Indicators (1).xlsx", firstrow case(lower) clear
 ren (d e f) (tot_HE_2015 tot_HE_2016 tot_HE_2017)
 ren countries country
 
 keep if indicators == "Current health expenditure by financing schemes"
 
 clean_countries
 
 save temp, replace
restore
 
merge m:1 country using temp, keep(1 3) keepus(tot_HE_2016) gen(tot_he_merge)

**------------------------------------------------------------------------------**




** 5. Import and merge GDP per capita data--------------------------------------**

preserve
 import delimited "Cleaned Data\worldbank_gdppcppp.csv", varnames(1) clear
 
 ren *countryname country
 ren yr2017 gdppc //Using GDP per capita data from 2017 - same year as prevalence
 
 foreach var of varlist yr* {
	replace `var' = "." if `var' == ".."
 }
 destring, replace
 
 drop if country == ""
 
 clean_countries
 
 save temp, replace
restore

merge m:1 country using temp, keep(1 3) keepus(gdppc) gen(gdp_merge)

**------------------------------------------------------------------------------**




** 6. Import and merge low/middle/high income classification--------------------**

preserve
 import excel "Cleaned Data\LMHIC_Class_cleaned.xls", sheet("Country Analytical History") ///
													  firstrow clear
													  
 foreach var in class2016 class2017 { //the income classifications for 2016 and 2017 respectively
    replace `var' = "Low" if `var' == "L"
	replace `var' = "Lower middle" if `var' == "LM"
	replace `var' = "Upper middle" if `var' == "UM"
	replace `var' = "High" if `var' == "H"
 }
 
 clean_countries
 
 save temp, replace
restore

merge m:1 country using temp, gen(class_merge) keepus(class2016 class2017)

**------------------------------------------------------------------------------**


save "Cleaned Data\data_foranal", replace


