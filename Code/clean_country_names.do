cap program drop clean_country_names
program clean_country_names
	
	

	replace country = lower(country)

	replace country = subinstr(country,"the ","",.)
	replace country = subinstr(country," the","",.)
	replace country = subinstr(country,",","",.)
	replace country = subinstr(country,"ô","o",.)
	replace country = subinstr(country,"ã","a",.)
	replace country = subinstr(country,"é","e",.)
	replace country = subinstr(country,"(","",.)
	replace country = subinstr(country,")","",.)
	replace country = subinstr(country,".","",.)

	replace country = "south korea" if country == "republic of korea" | country == "korea rep" /**/
	replace country = subinstr(country,"republic of","",.)
	replace country = subinstr(country,"saint","st",.)
	
	replace country = strtrim(stritrim(country))

	replace country = "bolivia" if country == "bolivia plurinational state of" | country == "bolivia plurinational states of"
	replace country = "brunei" if country == "brunei darussalam"
	replace country = "cabo verde" if country == "cape verde"
	replace country = "czechia" if country == "czech republic" /**/
	replace country = "congo" if country == "congo rep" /**/
	replace country = "dr congo" if country == "congo dem rep" | country == "democratic congo"
	replace country = "egypt" if country == "egypt arab rep"
	replace country = "eswatini" if country == "swaziland" /**/
	replace country = "iran" if country == "iran islamic rep"  /**/
	replace country = "kyrgyzstan" if country == "kyrgyz republic"
	replace country = "laos" if country == "lao people's democratic republic" | country == "lao people's democratic" | country == "lao pdr"
	replace country = "micronesia" if country == "federated states of micronesia" | country == "micronesia federated states of" | country == "micronesia fed sts" /**/
	replace country = "north korea" if country == "korea dem rep"
	replace country = "north macedonia" if country == "the north macedonia" | country == "yugoslav macedonia" | country == "fyr macedonia" | country == "macedonia" /**/
	replace country = "slovakia" if country == "slovak republic"
	replace country = "syria" if country == "syrian arab republic"
	replace country = "tanzania" if country == "united tanzania"  /**/
	replace country = "united states" if country == "united states of america"
	replace country = "venezuela" if country == "venezuela bolivarian" | country == "venezuela rb" /**/
	replace country = "vietnam" if country == "viet nam"
	replace country = "yemen" if country == "yemen rep"
	


end
