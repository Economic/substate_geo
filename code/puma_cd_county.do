*puma_cd_county.do
/*

*/
*read ACS data
!gunzip -k ${acs_extracts}usa_00002.dta.gz
use ${acs_extracts}usa_00002.dta, clear
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
d
local acs_obs = `r(N)'
tempfile acs
save `acs'
erase ${acs_extracts}usa_00002.dta

*read county population
import delim ${data}county_pop.csv, clear varnames(1) rowrange(3)
tempfile county_pop
save `county_pop'

import delim ${data}cd_pop.csv, clear varnames(1) rowrange(3)
destring state, replace
rename state statefip
tempfile cd_pop
save `cd_pop'

*read geocorr crosswalks
*drop uneeded vars
import delim ${data}geocorr_puma_county.csv, clear varnames(1) rowrange(3)

drop cntyname2 pumaname pop10
*acs state and puma identifiers are numeric
destring puma12, generate(puma)
destring state, generate(statefip)
destring afact, replace
tempfile puma_county
save `puma_county'

import delim ${data}geocorr_puma_cd.csv, clear varnames(1) rowrange(3)
*acs state and puma identifiers are numeric
drop pumaname pop10
destring puma12, generate(puma)
destring state, generate(statefip)
destring afact, replace
tempfile puma_cd
save `puma_cd'

***************************************************************
* create sample sizes by county for 1 through 5 years of data *
***************************************************************

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

gcollapse (sum) count1 count2 count3 count4 count5 acount* (first) statefip (min) minafact = afact, by(county14)
gen partial_puma = minafact < 1
tab partial_puma
*merge in county names and population
merge 1:1 county14 using `county_pop', keepusing(county14 cntyname2 pop10 stab)
destring pop10, replace
drop _merge minafact
order stab statefip cntyname2 county14 count1-count4 count5 acount* pop10 partial_puma
sort count5
*export data as is
export delim ${output}county_counts_unw.csv, replace nolabel
*create spreadsheet
export excel ${output}sample_sizes.xlsx, replace sheet("County") firstrow(var) nolabel
*generate data for distribution figures

sum count5, d
*topcode count5
gen sample_5yr = count5
replace sample_5yr = 10000 if count5 > 10000

gen sample_5yr_a = acount5
replace sample_5yr_a = 10000 if count5 > 10000

tempfile county_data
save `county_data'

use `county_data', clear
cumul sample_5yr, gen(cdf)
cumul sample_5yr_a, gen(cdf_a)
gen inv_cdf = 1-cdf
gen inv_cdf_a = 1-cdf_a

stack inv_cdf sample_5yr inv_cdf_a sample_5yr_a, into(inv samp) wide clear

scatter inv_cdf inv_cdf_a samp if samp <= 5000, title("Share of counties with sample sizes greater than a given count", size(medium)) ///
msymbol(o o) msize(small small) ytitle("") xtitle(County sample size) xlabel(0 1000 2000 3000 4000 5000 "5000+") ylabel(0(.2)1) ///
legend(label(1 "equal allocation") label(2 "proportional allocation"))

graph export ${output}fig_a.pdf, replace

*Share of total US population (weighted by population)
use `county_data', clear
cumul sample_5yr [aw=pop10], gen(w_cdf)
cumul sample_5yr_a [aw=pop10], gen(w_cdf_a)
gen inv_w_cdf = 1-w_cdf
gen inv_w_cdf_a = 1-w_cdf_a


stack inv_w_cdf sample_5yr inv_w_cdf_a sample_5yr_a, into(inv_w samp) wide clear

scatter inv_w_cdf inv_w_cdf_a samp if samp <= 5000, title("Total share of US population for counties with sample sizes greater than a given count", size(small)) ///
  msymbol(o o) msize(small small) ytitle("") xtitle(County sample size ) xlabel(0 1000 2000 3000 4000 5000 "5000+") ylabel(0(.2)1) ///
  legend(label(1 "equal allocation") label(2 "proportional allocation"))

graph export ${output}fig_b.pdf, replace

*******************************************************************************
* create sample sizes by congressional district for 1 through 5 years of data *
*******************************************************************************

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

gcollapse (sum) count1 count2 count3 count4 count5 acount* (min) minafact = afact, by(statefip cd114)
gen partial_puma = minafact < 1
tab partial_puma

*merge in cd population and stat abb
merge 1:1 cd114 statefip using `cd_pop', keepusing(pop10 stab)

destring pop10, replace

drop _merge minafact
sort count5
order stab statefip cd114 count1-count4 count5 acount* pop10 partial_puma
export excel ${output}sample_sizes.xlsx, sheet("CD") firstrow(var) nolabel sheetmodify
export delim ${output}cd_counts_unw.csv, replace nolabel

tempfile cd_data
save `cd_data'

use `cd_data', clear
cumul count5, gen(cdf)
cumul acount5, gen(cdf_a)
gen inv_cdf = 1-cdf
gen inv_cdf_a = 1-cdf_a

scatter inv_cdf inv_cdf_a samp if samp <= 40000, title("Share of CDs with sample sizes greater than a given count", size(medium)) ///
msymbol(o o) msize(small small) ytitle("") xtitle(CD sample size) ylabel(0(.2)1) xlabel(10000(10000)40000 40000 "40000+") ///
legend(label(1 "equal allocation") label(2 "proportional allocation"))

graph export ${output}fig_c.pdf, replace

/*Share of total US population (weighted by population) Not used since CDs are all the same size for the most part.
use `cd_data', clear
cumul count5 [aw=pop10], gen(w_cdf)
cumul acount5 [aw=pop10], gen(w_cdf_a)
gen inv_w_cdf = 1-w_cdf
gen inv_w_cdf_a = 1-w_cdf_a

scatter inv_w_cdf inv_w_cdf_a samp if samp <= 40000, title("Total share of US population for CDs with sample sizes greater than a given count" , size(small)) ///
msymbol(o o) msize(small small) ytitle("") xtitle(CD sample size) ylabel(0(.2)1) xlabel(10000(10000)40000 40000 "40000+") ///
legend(label(1 "equal allocation") label(2 "proportional allocation"))

graph export ${output}fig_d.pdf, replace*/

!pdfunite ${output}fig_a.pdf ${output}fig_b.pdf ${output}fig_c.pdf ${output}figures.pdf
