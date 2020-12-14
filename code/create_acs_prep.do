********************************************************************************
* Prepare ACS data
********************************************************************************


********************************************************************************
* Load IPUMS ACS
********************************************************************************
!gunzip -k ${acsdata}usa_00046.dta.gz
use ${acsdata}usa_00046.dta, clear
erase ${acsdata}usa_00046.dta

replace year = multyear 


********************************************************************************
* Family relations
********************************************************************************
gen byte youth = age < 18
gegen byte hasyouth_fam = max(youth), by(year serial famunit)
gegen byte hasyouth_sfam = max(youth), by(year serial famunit subfam)
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

* drop armed forces
drop if (9670 <= ind & ind <= 9890) | (9800 <= occ & occ <= 9830)

* ONLY KEEP EMPLOYED
keep if empstat == 1


********************************************************************************
* Define place of work state & PUMA
********************************************************************************
rename statefip statefips

gen pwpuma = pwpuma00
gen pwstate = pwstate2

* place of work is missing if currently not at work (even though employed/worked last year)
* assign place of residence in these cases (about 13% of pos inc, or only 2% of posinc and employed)
replace pwpuma = puma if pwpuma00 == 0
replace pwstate = statefips if pwpuma00 == 0

assert pwpuma > 0 & pwpuma ~= .
assert pwstate > 0 & pwstate ~= .


********************************************************************************
* Impute weeks worked
********************************************************************************
* output variable: adj_wkswork0 and adj_wkswork1
do ${code}impute_weeksworked.do


********************************************************************************
* Create initial hourly wages
********************************************************************************
gen hrwage0 = incwage / (uhrswork * adj_wkswork1)
assert hrwage0 >= 0 & hrwage0 ~= .


********************************************************************************
* Save preparatory data
********************************************************************************
keep adj_wkswork* age bpl citizen classwkr classwkrd educd empstatd empstat famsize famunit foodstmp ftotinc hasyouth_* hhincome hhwt hispan* hrwage0 incearn inctot incwage ind ind1990 marst metro met2013 nchild nfams occ parent_* pernum perwt poverty puma pwpuma pwstate rac* related serial sex statefips subfam uhrswork vetstatd wkswork2 year
compress
saveold ${output}acs_prep.dta, replace version(13)
