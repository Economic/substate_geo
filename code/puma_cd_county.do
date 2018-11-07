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
*remove non-wage earners
drop if hrwage == 0
*restrict ages in sample
drop if age < 16 | age > 64
tab age
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

*create sample sizes by county for 1 through 5 years of data
use `acs', clear
joinby statefip puma using `puma_county', unm(both) _merge()
tab _merge
drop _merge

gen count1 = year == 2016
gen count2 = year >= 2015 & year <= 2016
gen count3 = year >= 2014 & year <= 2016
gen count4 = year >= 2013 & year <= 2016
gen count5 = year >= 2012 & year <= 2016

gen acount1 = count1 * afact
gen acount2 = count2 * afact
gen acount3 = count3 * afact
gen acount4 = count4 * afact
gen acount5 = count5 * afact

gcollapse (sum) count1 count2 count3 count4 count5 acount* (first) statefip, by(county14)
export delim ${output}county_counts_unw.csv, replace

*create sample sizes by congressional district for 1 through 5 years of data
use `acs', clear

joinby statefip puma using `puma_cd', unm(both) _merge()
tab _merge
drop _merge

gen count1 = year == 2016
gen count2 = year >= 2015 & year <= 2016
gen count3 = year >= 2014 & year <= 2016
gen count4 = year >= 2013 & year <= 2016
gen count5 = year >= 2012 & year <= 2016

gen acount1 = count1 * afact
gen acount2 = count2 * afact
gen acount3 = count3 * afact
gen acount4 = count4 * afact
gen acount5 = count5 * afact

gcollapse (sum) count1 count2 count3 count4 count5 acount*, by(statefip cd114)
li if statefip == 1
export delim ${output}cd_counts_unw.csv, replace
