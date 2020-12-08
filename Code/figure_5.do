* Ridley, Rao, Schilbach and Patel 2020-----------------------------------------*

/* This code creates Figure 5 from the paper.
	
	
*Last modified: 2020/11/28
*Last modified by: Matthew Ridley
*/
cd ..

import excel "Raw Data/Figure 5/Patel_et_al_TreatmentEffects.xlsx", cellrange(A3) firstrow clear


** 1. Organize the data---------------------------------------------------------**
** -----------------------------------------------------------------------------**
ren (Control Treatment) (Controlval Treatmentval)

* Reshape to have control and treatment in different rows, not different columns
reshape long @val @SD @N, i(Var) j(group) str

label define tc 1 "Control" 2 "Treatment"
encode group, gen(x) label(tc)

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 2. Prepare the variables-----------------------------------------------------**
** -----------------------------------------------------------------------------**

* Convert number in remission to fraction depressed
replace val = val/N if Var == "Number in remission"
replace val = 1-val if Var == "Number in remission"
replace Var = "Depression" if Var == "Number in remission"

* Calculate standard error of fraction depressed
gen SE = sqrt(val*(1-val)/N) if Var == "Depression"
replace SE = SD/sqrt(N) if Var != "Depression"

* Construct error bars
gen val_hi = val + SE //1 std. error of the mean
gen val_low = val - SE

** -----------------------------------------------------------------------------**
** -----------------------------------------------------------------------------**




** 3. Plot graph ---------------------------------------------------------------**
** -----------------------------------------------------------------------------**

replace Var = "Health costs" if Var == "Health costs exc intervention"

* Set location of comparison brackets
gen bracket = .
replace bracket = 0.9 if Var == "Depression"
replace bracket = 9 if Var == "Days unable to work"
replace bracket = 90 if Var == "Health costs"

* Set the significance stars for each comparison (obtained from Patel et al. (2017))
gen stars = ""
replace stars = " *** " if Var == "Depression" 
replace stars = " *** " if Var == "Days unable to work"
replace stars = "  *  " if Var == "Health costs"

foreach v in "Depression" "Days unable to work" "Health costs" {

	*Get title (DisplayName), y axis (Units) and stars
	levelsof DisplayName if Var == "`v'", local(name)
	levelsof Units if Var == "`v'", local(u) 
	levelsof stars if Var == "`v'", local(st)
	
	*Get position of bracket and stars
	sum bracket if Var == "`v'"
	local starpos=`r(mean)'
	local bracepos = `starpos'*1.0105
	
	*Plot
	graph twoway (bar val x if x==1, color(ltblue) barw(0.6)) (bar val x if x== 2, color(navy) barw(0.6))  				/// bars
				 (rcap val_low val_hi x, color(black)) (line bracket x, lwidth(medthick) color(black)) if Var == "`v'", /// error bars and comparison brackets
				 text(`starpos' 1.5 `st', place(c) box fcolor(white) lcolor(white)) 									/// stars
				 text(`bracepos' 1 "|", place(s)) text(`bracepos' 2 "|", place(s)) 										/// bracket ends
				 xscale(range(0.2 2.8)) xlabel(1 2, valuelabel) xtitle("") 												/// x axis
				 yscale(range(0 1)) ylabel(#6, grid gmax) ytitle(`u')  													/// y axis
				 plotregion(margin(b = 0) style(none)) legend(off) scheme(s1color)  									/// overall look
				 title(`name')  																						/// title
				 saving("temp/`v'", replace)
				 
				 
	local forsave `"`forsave' "temp/`v'.gph""'
	di `"`forsave'"'
}


graph combine `forsave', graphregion(color(white))
graph export "Output/png/fig_5.png", replace
