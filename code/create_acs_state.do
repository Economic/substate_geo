********************************************************************************
* Process ACS tables
********************************************************************************
do ${code}clean_acs_tables_state.do
saveold ${output}acs_tables_state.dta, replace version(13)


********************************************************************************
* Prepare ACS for ACS tables
********************************************************************************
use ${output}acs_wages_imputed.dta, clear

gen byte agegroup = .
replace agegroup = 1 if age >= 16 & age <= 19
replace agegroup = 2 if age >= 20 & age <= 24
replace agegroup = 3 if age >= 25 & age <= 34
replace agegroup = 4 if age >= 35 & age <= 44
replace agegroup = 5 if age >= 45 & age <= 54
replace agegroup = 6 if age >= 55 & age <= 64
replace agegroup = 7 if age >= 65
assert agegroup ~= .

gen byte raceagegroup = .
replace raceagegroup = 11 if race == 1 & age >= 16 & age <= 64
replace raceagegroup = 12 if race == 1 & age >= 65
replace raceagegroup = 21 if race == 2 & age >= 16 & age <= 64
replace raceagegroup = 22 if race == 2 & age >= 65
replace raceagegroup = 31 if race >= 3 & age >= 16 & age <= 64
replace raceagegroup = 32 if race >= 3 & age >= 65
assert raceagegroup ~= .

cap drop hispanic
gen byte hispanic = hispan >= 1 & hispan <= 4
gen byte hispagegroup = .
replace hispagegroup = 11 if hispanic == 1 & age >= 16 & age <= 64
replace hispagegroup = 12 if hispanic == 1 & age >= 65
replace hispagegroup = 21 if hispanic == 0 & age >= 16 & age <= 64
replace hispagegroup = 22 if hispanic == 0 & age >= 65
assert hispagegroup ~= .

gen byte educgroup = .
replace educgroup = 1 if educd <= 61 & age >= 25 & age <= 64
replace educgroup = 2 if educd >= 63 & educd <= 64 & age >= 25 & age <= 64
replace educgroup = 3 if educd >= 65 & educd <= 81 & age >= 25 & age <= 64
replace educgroup = 4 if educd >= 101 & age >= 25 & age <= 64
replace educgroup = 5 if age < 25 | age > 64
assert educgroup ~= .


********************************************************************************
* Calibrate sample weights
********************************************************************************
do ${code}calibrate_weights_acs_state.do
compress
saveold ${output}acs_state.dta, replace version(13)
