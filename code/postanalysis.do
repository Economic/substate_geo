* calculate number of children per household
!gunzip -k ${acsdata}usa_00035.dta.gz
use ${acsdata}usa_00035.dta, clear
erase ${acsdata}usa_00035.dta

gen byte youth18 = age < 18
gen byte youth16 = age < 16

egen numkid16_hh = total(youth16), by(year serial)
egen numkid18_hh = total(youth18), by(year serial)

gen byte all = 1
egen numpeople_hh = total(all), by(year serial)

egen tag = tag(year serial)
keep if tag == 1

keep year serial numkid16_hh numkid18_hh numpeople_hh hhwt
compress
saveold ${output}acs_numpeople.dta, replace version(13)
