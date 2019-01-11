********************************************************************************
* Create ACS hourly wages
********************************************************************************


********************************************************************************
* ACS sample restrictions
********************************************************************************
!gunzip -k ${acsdata}usa_00035.dta.gz
use ${acsdata}usa_00035.dta, clear
erase ${acsdata}usa_00035.dta

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

* should we restrict sample to hourly wages above $1 & below $200 (roughly 1989 values of $0.50 and $100) thresholds?
* this restriction eliminate about 0.54% of sample
keep if hrwage0 >= 1.00 & hrwage0 <= 200.00


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
keep year statefips puma perwt empstat sex age marst race* hispan* rac* parttime majorind majorocc adj_wkswork pw_puma pw_state hrwage0 hrwage1 hrwage2
compress

saveold ${output}acs_wages_imputed.dta, replace version(13)
