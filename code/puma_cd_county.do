*puma_cd_county.do
/*

*/
*read ACS data
!gunzip -k ${acs_extracts}usa_00002.dta.gz
use ${acs_extracts}usa_00002.dta
replace incwage = . if incwage == 999999
*check N/As on hours worked and weeks
assert uhrswork == 0 if wkswork2 == 0
*drop people who didn't work
drop if uhrswork == 0
tab wkswork2
gen adj_wkswork = .
replace adj_wkswork = 7 if wkswork2 == 1
replace adj_wkswork = 20 if wkswork2 == 2
replace adj_wkswork = 33 if wkswork2 == 3
replace adj_wkswork = 43.5 if wkswork2 == 4
replace adj_wkswork = 48.5 if wkswork2 == 5
replace adj_wkswork = 51 if wkswork2 == 6

*create hourly wage variable
gen hrwage = incwage / (uhrswork * adj_wkswork)
*getting some wierd values (lots of 0s and some 5 digit hourly wages)
*sum hrwage if hrwage != 0, d
*count if hrwage > 100
*count if hrwage > 1000
*count if hrwage > 10000
*keep only needed vars for now
keep year datanum serial pernum puma statefip hrwage

tempfile acs
save `acs'
erase ${acs_extracts}usa_00002.dta

*read geocorr crosswalks
import delim ${data}geocorr_puma_county.csv, clear varnames(1) rowrange(3)
*drop uneeded vars
drop cntyname2 pumaname stab pop10
*acs state and puma identifiers are numeric
destring puma12, generate(puma)
destring state, generate(statefip)
destring afact, replace
tempfile puma_county
save `puma_county'

import delim ${data}geocorr_puma_cd.csv, clear varnames(1) rowrange(3)
*acs state and puma identifiers are numeric
drop pumaname stab pop10
destring puma12, generate(puma)
destring state, generate(statefip)
destring afact, replace
tempfile puma_cd
save `puma_cd'

use `acs', clear
joinby statefip puma using `puma_county', unm(both) _merge()
tab _merge
drop _merge
d
gcollapse (count) puma_counts = datanum (first) afact, by(year statefip puma county14)

gen allocated_counts = puma_counts * afact
sort  year statefip puma

export delim ${data}county_counts_unw.csv, replace

use `acs', clear
joinby statefip puma using `puma_cd', unm(both) _merge()
tab _merge
drop _merge

gcollapse (count) puma_counts = datanum (first) afact, by(year statefip puma cd114)

gen allocated_counts = puma_counts * afact
sort year statefip puma

export delim ${data}cd_counts_unw.csv, replace
