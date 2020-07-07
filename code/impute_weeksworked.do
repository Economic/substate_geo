* create new variables in ACS to match CPS

* EDUCATION
gen new_educ = .
* Less than 1st grade
replace new_educ = 1 if educd == 2 | educd == 11 | educd == 12
* 1st-4th grade
replace new_educ = 2 if 14 <= educd & educd <= 17
* 5th-6th grade
replace new_educ = 3 if 22 <= educd & educd <= 23
* 7th-8th grade
replace new_educ = 4 if 25 <= educd & educd <= 26
* 9th grade
replace new_educ = 5 if educd == 30
* 10th grade
replace new_educ = 6 if educd == 40
* 11th grade
replace new_educ = 7 if educd == 50
* 12th grade, no diploma
replace new_educ = 8 if educd == 61
* HS grad, GED
replace new_educ = 9 if 63 <= educd & educd <= 64
* Some college, no degree
replace new_educ = 10 if educd == 65 | educd == 71
* Associate's degree (not specified)
replace new_educ = 11 if educd == 81
* Bachelor’s degree
replace new_educ = 13 if educd == 101
* Master's degree
replace new_educ = 14 if educd == 114
* Professional degree
replace new_educ = 15 if educd == 115
* Doctoral degree
replace new_educ = 16 if educd == 116
assert new_educ ~= .

* race & ethnicity
* combine hispanic ethnicity and race to get a better match to CPS
* without doing this, the ACS will show lower white share of population
* and a sizable share of "Other major" race, for which there is no comparable category in the CPS race definitions
gen hispanic = hispan >= 1 & hispan <= 4
gen new_race = .
* White
replace new_race = 1 if race == 1
* Black
replace new_race = 2 if race == 2
* Other
replace new_race = 4 if race >= 3 & race ~= .
replace new_race = 3 if hispanic == 1
assert new_race ~= .

* age
forvalues i = 2 / 5 {
	gen age`i' = age^`i'
}

* female
gen female = sex == 2

* Major industry
gen majorind = .
* Agriculture, forestry, fishing, and hunting
replace majorind = 1 if 170 <= ind & ind <= 290
* Mining
replace majorind = 2 if 370 <= ind & ind <= 490
* Construction
replace majorind = 3 if ind == 770
* Manufacturing
replace majorind = 4 if 1070 <= ind & ind <= 3990
* Wholesale & retail trade
replace majorind = 5 if 4070 <= ind & ind <= 5790
* Transportation & utilities
replace majorind = 6 if (6070 <= ind & ind <= 6390) | (570 <= ind & ind <= 690)
* Information
replace majorind = 7 if 6470 <= ind & ind <= 6780
* Financial activities
replace majorind = 8 if 6870 <= ind & ind <= 7190
* Professional and business services
replace majorind = 9 if 7270 <= ind & ind <= 7790
* Educational and health services
replace majorind = 10 if 7860 <= ind & ind <= 8470
* Leisure and hospitality
replace majorind = 11 if 8560 <= ind & ind <= 8690
* Other services
replace majorind = 12 if 8770 <= ind & ind <= 9290
* Public administration
replace majorind = 13 if 9370 <= ind & ind <= 9590
assert majorind ~= .

* Major occupation
gen majorocc = .
* Management, business, and financial occupations
replace majorocc = 1 if 10 <= occ & occ <= 950
* Professional and related occupations
replace majorocc = 2 if 1005 <= occ & occ <= 3540
* Service occupations
replace majorocc = 3 if 3600 <= occ & occ <= 4650
* Sales and related occupations
replace majorocc = 4 if 4700 <= occ & occ <= 4965
* Office and administrative support occupations
replace majorocc = 5 if 5000 <= occ & occ <= 5940
* Farming, fishing, and forestry occupations
replace majorocc = 6 if 6005 <= occ & occ <= 6130
* Construction and extraction occupations
replace majorocc = 7 if 6200 <= occ & occ <= 6940
* Installation, maintenance, and repair occupations
replace majorocc = 8 if 7000 <= occ & occ <= 7630
* Production occupations
replace majorocc = 9 if 7700 <= occ & occ <= 8965
*	Transportation and material moving occupations
replace majorocc = 10 if 9000 <= occ & occ <= 9750
assert majorocc ~= .

* part/full-time
gen parttime = uhrswork <= 34

* marital
gen new_married = marst >= 1 & marst <= 2

tempfile acs
save `acs'

********************************************************************************
*  Load IPUMS March CPS for training
********************************************************************************
!gunzip -k ${miscdata}cps_00071.dta.gz
use ${miscdata}cps_00071.dta, clear
erase ${miscdata}cps_00071.dta

* keep 16+ positive wage earners with weeks worked
keep if age > = 16
keep if incwage > 0 & incwage < 9999998
keep if wkswork1 > 0
* drop self-emp
drop if classwly == 13 | classwly == 14
* drop armed forces
drop if (9670 <= ind & ind <= 9890) | (9800 <= occ & occ <= 9830)
* adjust data year to match reference year
replace year = year - 1

* EDUCATION
gen new_educ = .
* Less than 1st grade
replace new_educ = 1 if educ == 2
* 1st-4th grade
replace new_educ = 2 if educ == 10
* 5th-6th grade
replace new_educ = 3 if educ == 20
* 7th-8th grade
replace new_educ = 4 if educ == 30
* 9th grade
replace new_educ = 5 if educ == 40
* 10th grade
replace new_educ = 6 if educ == 50
* 11th grade
replace new_educ = 7 if educ == 60
* 12th grade, no diploma
replace new_educ = 8 if educ == 71
* HS grad, GED
replace new_educ = 9 if educ == 73
* Some college, no degree
replace new_educ = 10 if educ == 81
* Associate's degree (collapse degrees into one category)
replace new_educ = 11 if educ == 91 | educ == 92
* Bachelor’s degree
replace new_educ = 13 if educ == 111
* Master's degree
replace new_educ = 14 if educ == 123
* Professional degree
replace new_educ = 15 if educ == 124
* Doctoral degree
replace new_educ = 16 if educ == 125
assert new_educ ~= .

* race & ethnicity
* combine hispanic ethnicity and race to get a better match to CPS
* without doing this, the ACS will show lower white share of population
* and a sizable share of "Other major" race, for which there is no comparable category in the CPS race definitions
gen hispanic = hispan >= 100 & hispan <= 500
gen new_race = .
* White
replace new_race = 1 if race == 100
* Black
replace new_race = 2 if race == 200
* Other
replace new_race = 4 if race >= 300
replace new_race = 3 if hispanic == 1
assert new_race ~= .

* age
forvalues i = 2 / 5 {
	gen age`i' = age^`i'
}

* female
gen female = sex == 2

* Major industry
rename indly ind
gen majorind = .
* Agriculture, forestry, fishing, and hunting
replace majorind = 1 if 170 <= ind & ind <= 290
* Mining
replace majorind = 2 if 370 <= ind & ind <= 490
* Construction
replace majorind = 3 if ind == 770
* Manufacturing
replace majorind = 4 if 1070 <= ind & ind <= 3990
* Wholesale & retail trade
replace majorind = 5 if 4070 <= ind & ind <= 5790
* Transportation & utilities
replace majorind = 6 if (6070 <= ind & ind <= 6390) | (570 <= ind & ind <= 690)
* Information
replace majorind = 7 if 6470 <= ind & ind <= 6780
* Financial activities
replace majorind = 8 if 6870 <= ind & ind <= 7190
* Professional and business services
replace majorind = 9 if 7270 <= ind & ind <= 7790
* Educational and health services
replace majorind = 10 if 7860 <= ind & ind <= 8470
* Leisure and hospitality
replace majorind = 11 if 8560 <= ind & ind <= 8690
* Other services
replace majorind = 12 if 8770 <= ind & ind <= 9290
* Public administration
replace majorind = 13 if 9370 <= ind & ind <= 9590
assert majorind ~= .

* Major occupation
rename occly occ
gen majorocc = .
* Management, business, and financial occupations
replace majorocc = 1 if 10 <= occ & occ <= 950
* Professional and related occupations
replace majorocc = 2 if 1005 <= occ & occ <= 3540
* Service occupations
replace majorocc = 3 if 3600 <= occ & occ <= 4650
* Sales and related occupations
replace majorocc = 4 if 4700 <= occ & occ <= 4965
* Office and administrative support occupations
replace majorocc = 5 if 5000 <= occ & occ <= 5940
* Farming, fishing, and forestry occupations
replace majorocc = 6 if 6005 <= occ & occ <= 6130
* Construction and extraction occupations
replace majorocc = 7 if 6200 <= occ & occ <= 6940
* Installation, maintenance, and repair occupations
replace majorocc = 8 if 7000 <= occ & occ <= 7630
* Production occupations
replace majorocc = 9 if 7700 <= occ & occ <= 8965
*	Transportation and material moving occupations
replace majorocc = 10 if 9000 <= occ & occ <= 9750
assert majorocc ~= .

* part/full-time
gen parttime = uhrsworkly <= 34

* marital status
gen new_married = marst >= 1 & marst <= 2
assert new_married ~= .

rename statefip statefips

* weeks worked bin-specific wage predictions
* should these be gender-specific?
forvalues j = 1/6 {
	reg wkswork1 age* i.female i.new_educ i.new_race i.new_married i.majorind i.majorocc i.parttime i.year i.statefips [aw=asecwt] if wkswork2 == `j'
	eststo wks`j'
}


********************************************************************************
* Impute weeks worked in ACS
********************************************************************************
use `acs', clear

* simple imputation: midpoint of bin range
gen adj_wkswork0 = .
replace adj_wkswork0 = 0.5 * ( 1 + 13) if wkswork2 == 1
replace adj_wkswork0 = 0.5 * (14 + 26) if wkswork2 == 2
replace adj_wkswork0 = 0.5 * (27 + 39) if wkswork2 == 3
replace adj_wkswork0 = 0.5 * (40 + 47) if wkswork2 == 4
replace adj_wkswork0 = 0.5 * (48 + 49) if wkswork2 == 5
replace adj_wkswork0 = 0.5 * (50 + 52) if wkswork2 == 6

* regression predicted weeks worked
gen adj_wkswork1 = .
forvalues j = 1/6 {
	estimates restore wks`j'
	predict xb if wkswork2 == `j', xb
	replace adj_wkswork1 = round(xb) if wkswork2 == `j'
	drop xb
}

* bound predictions
replace adj_wkswork1 = 1  if wkswork2 == 1 & adj_wkswork1 < 1
replace adj_wkswork1 = 13 if wkswork2 == 1 & adj_wkswork1 > 13
replace adj_wkswork1 = 14 if wkswork2 == 2 & adj_wkswork1 < 14
replace adj_wkswork1 = 26 if wkswork2 == 2 & adj_wkswork1 > 26
replace adj_wkswork1 = 27 if wkswork2 == 3 & adj_wkswork1 < 27
replace adj_wkswork1 = 39 if wkswork2 == 3 & adj_wkswork1 > 39
replace adj_wkswork1 = 40 if wkswork2 == 4 & adj_wkswork1 < 40
replace adj_wkswork1 = 47 if wkswork2 == 4 & adj_wkswork1 > 47
replace adj_wkswork1 = 48 if wkswork2 == 5 & adj_wkswork1 < 48
replace adj_wkswork1 = 49 if wkswork2 == 5 & adj_wkswork1 > 49
replace adj_wkswork1 = 50 if wkswork2 == 6 & adj_wkswork1 < 50
replace adj_wkswork1 = 52 if wkswork2 == 6 & adj_wkswork1 > 52

* remove new variables to avoid confusion with subsequent predictions
drop new_educ hispanic new_race age2-age5 female majorind majorocc parttime new_married
