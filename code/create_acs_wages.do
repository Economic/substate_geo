********************************************************************************
* Create ACS hourly wages
********************************************************************************


********************************************************************************
* Load IPUMS ACS
********************************************************************************
!gunzip -k ${acsdata}usa_00035.dta.gz
use ${acsdata}usa_00035.dta, clear
erase ${acsdata}usa_00035.dta


********************************************************************************
* Family relations
********************************************************************************
gen byte youth = age < 18
egen byte hasyouth_fam = max(youth), by(year serial famunit)
egen byte hasyouth_sfam = max(youth), by(year serial famunit subfam)
gen byte parent_fam = nchild >= 1 & hasyouth_fam == 1
gen byte parent_sfam = nchild >= 1 & hasyouth_sfam == 1


********************************************************************************
* ACS sample restrictions
********************************************************************************
* exlude under 16
drop if age < 16

* nonmissing, positive wage income
replace incwage = . if incwage >= 999998
keep if incwage > 0 & incwage ~= .

* with positive income, all entries nonzero for hours & weeks worked
assert uhrswork > 0 & wkswork2 > 0

* remove self employed workers
drop if classwkr == 1
* should we also drop people who have large amounts of business/farm income?

* drop those working abroad
drop if pwstate2 > 56


********************************************************************************
* Impute weeks worked
********************************************************************************
* output variable: adj_wkswork
do ${code}impute_weeksworked.do


********************************************************************************
* Assign place of work state & PUMA
********************************************************************************
gen pw_puma = pwpuma00
gen pw_state = pwstate2
* use pwstate and pwpuma when possible, otherwise use statefip + puma (12.35%)
replace pw_puma = puma if pw_state == 0
rename statefip statefips
replace pw_state = statefips if pw_state == 0


********************************************************************************
* Create hourly wages
********************************************************************************
* define initial hourly wage
gen hrwage0 = incwage / (uhrswork * adj_wkswork)
assert hrwage0 >= 0 & hrwage0 ~= .


********************************************************************************
* Impute wages based on CPS wage regression
********************************************************************************
* output: hrwage1
do ${code}impute_wages_cpsreg.do


********************************************************************************
* Modify imputation based on CPS state wage location
********************************************************************************
* output: hrwage2
do ${code}impute_wages_cpsloc.do
keep adj_wkswork age bpl citizen classwkrd educd empstatd empstat famsize famunit foodstmp ftotinc hasyouth_* hhincome hhwt hispan* hrwage0 hrwage1 hrwage2 incearn inctot incwage ind ind1990 majorind majorocc marst metro met2013 nchild nfams occ parent_* parttime pernum perwt poverty puma pwpuma00 pwstate2 pw_puma pw_state rac* related serial sex statefips subfam uhrswork vetstatd wkswork2 year
compress

saveold ${output}acs_wages_imputed.dta, replace version(13)
