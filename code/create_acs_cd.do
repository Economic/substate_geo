********************************************************************************
* Process ACS tables
********************************************************************************
do ${code}clean_acs_tables_cd.do
* for now use CD115 demographics for 116th CDs:
rename cd115 cd116
saveold ${output}acs_tables_cd.dta, replace version(13)


********************************************************************************
* Create PUMA-CD mapping
********************************************************************************
* use Geocorr PUMA-CD concordance
* from http://mcdc.missouri.edu/applications/geocorr2018.html
import delim ${miscdata}geocorr_puma_cd116.csv, clear varnames(1) rowrange(3)
drop pumaname pop10 stab
rename puma12 puma
rename state statefips
destring puma, replace
destring statefips, replace
destring afact, replace
destring cd116, replace
tempfile puma_cd
save `puma_cd'


********************************************************************************
* Join CDs to ACS
********************************************************************************
* this will duplicate observations that get mapped to multiple CDs
use ${output}acs_wages_imputed.dta, clear
joinby statefips puma using `puma_cd', unm(both) _merge()
assert _merge == 3
drop _merge
gen statecd116 = strofreal(statefips) + strofreal(cd116,"%02.0f")
drop cd116
rename statecd116 cd116
destring cd116, replace


********************************************************************************
* Prepare ACS for ACS tables
********************************************************************************
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
do ${code}calibrate_weights_acs_cd.do
compress
saveold ${output}acs_cd116.dta, replace version(13)
