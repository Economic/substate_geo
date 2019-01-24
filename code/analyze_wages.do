/*
load_epiextracts, begin(2017m1) end(2017m12) sample(org)
keep if wageotc > 0 & wageotc ~= .
gen new_race = wbho_only
tempfile cps
save `cps'

use `cps', clear
binipolate wageotc [pw=orgwgt], binsize(0.25) p(5(5)95) collapsefun(gcollapse)
keep p*binned
tempfile cpsall
save `cpsall'

use `cps', clear
binipolate wageotc [pw=orgwgt], binsize(0.25) p(5(5)95) by(female) collapsefun(gcollapse)
keep female p*binned
tempfile cpsfemale
save `cpsfemale'

use `cps', clear
binipolate wageotc [pw=orgwgt], binsize(0.25) p(5(5)95) by(new_race) collapsefun(gcollapse)
keep new_race p*binned
tempfile cpsrace
save `cpsrace'

use using ${output}acs_state.dta, clear
gen new_race = .
* White
replace new_race = 1 if race == 1
* Black
replace new_race = 2 if race == 2
* Other
replace new_race = 4 if race >= 3 & race ~= .
replace new_race = 3 if hispanic == 1
assert new_race ~= .
* female
gen female = sex == 2
tempfile acs
save `acs'

foreach var in /*hrwage0 hrwage1*/ hrwage2 {
	use `acs', clear
	binipolate `var' [pw=perwt2], binsize(0.25) p(5(5)95) collapsefun(gcollapse)
	keep p*binned
	gen outcome = "`var'"
	tempfile acsall`var'
	save `acsall`var''

	use `acs', clear
	binipolate `var' [pw=perwt2], binsize(0.25) p(5(5)95) by(female) collapsefun(gcollapse)
	keep female p*binned
	gen outcome = "`var'"
	tempfile acsfemale`var'
	save `acsfemale`var''

	use `acs', clear
	binipolate `var' [pw=perwt2], binsize(0.25) p(5(5)95) by(new_race) collapsefun(gcollapse)
	keep new_race p*binned
	gen outcome = "`var'"
	tempfile acsrace`var'
	save `acsrace`var''
}

local counter = 0
foreach cat in all female race {
	foreach var in /*hrwage0 hrwage1*/ hrwage2 {
		local counter = `counter' + 1
		if `counter' == 1 use `acs`cat'`var'', clear
		else append using `acs`cat'`var''
	}
}
gen sample = "acs"
append using `cpsall'
append using `cpsfemale'
append using `cpsrace'
replace sample = "cps" if sample == ""
replace outcome = "wageotc" if sample == "cps"
save ${output}acscps_wagedist.dta, replace
*/

/*
use ${output}acs_cd116, clear
gen new_race = .
* White
replace new_race = 1 if race == 1
* Black
replace new_race = 2 if race == 2
* Other
replace new_race = 4 if race >= 3 & race ~= .
replace new_race = 3 if hispanic == 1
assert new_race ~= .
* female
gen female = sex == 2
tempfile acs
save `acs'

foreach var in hrwage2 {
	foreach weight in perwt1 perwt2 {
		use `acs', clear
		binipolate `var' [pw=`weight'], binsize(0.25) p(5(5)95) collapsefun(gcollapse)
		keep p*binned
		gen outcome = "`var'"
		gen weight = "`weight'"
		tempfile acsall`var'`weight'
		save `acsall`var'`weight''

		use `acs', clear
		binipolate `var' [pw=`weight'], binsize(0.25) p(5(5)95) by(female) collapsefun(gcollapse)
		keep female p*binned
		gen outcome = "`var'"
		gen weight = "`weight'"
		tempfile acsfemale`var'`weight'
		save `acsfemale`var'`weight''

		use `acs', clear
		binipolate `var' [pw=`weight'], binsize(0.25) p(5(5)95) by(new_race) collapsefun(gcollapse)
		keep new_race p*binned
		gen outcome = "`var'"
		gen weight = "`weight'"
		tempfile acsrace`var'`weight'
		save `acsrace`var'`weight''
	}
}
local counter = 0
foreach cat in all female race {
	foreach var in hrwage2 {
		foreach weight in perwt1 perwt2 {
			local counter = `counter' + 1
			if `counter' == 1 use `acs`cat'`var'`weight'', clear
			else append using `acs`cat'`var'`weight''
		}
	}
}
gen sample = "acs"
append using `cpsall'
append using `cpsfemale'
append using `cpsrace'
replace sample = "cps" if sample == ""
replace outcome = "wageotc" if sample == "cps"
replace weight = "orgwgt" if sample == "cps"
save ${output}acscps_cd_wagedist.dta, replace
*/

local color1 68 1 84
local color2 49 104 142
local color3 53 183 121
local color4 253 231 37


use ${output}acscps_wagedist, clear
reshape long p@_binned, i(female new_race sample outcome) j(percentile)
rename p_binned wage
gen logwage = log(wage)
gen all = 1 if new_race == . & female == .
gen white = new_race == 1
gen black = new_race == 2
gen hispanic = new_race == 3
gen male = female == 0
tempfile all
save `all'

local alltitle "Overall"
local whitetitle "White only"
local blacktitle "Black only"
local hispanictitle "Hispanic only"
local maletitle "Male only"
local femaletitle "Female only"

foreach group in all white black hispanic female male {
	use `all' if `group' == 1
	scatter logwage percentile if sample == "cps", msize(small) mcolor("`color4'") msymbol(circle) /*|| scatter logwage percentile if sample == "acs" & outcome == "hrwage0", mcolor("`color3'") mfcolor(none) || scatter logwage percentile if sample == "acs" & outcome == "hrwage1", mcolor("`color2'") mfcolor(none)*/ || scatter logwage percentile if sample == "acs" & outcome == "hrwage2", mcolor("`color1'") mfcolor(none) legend( position(10) ring(0) size(small) label(1 "CPS: wageotc") /*label(2 "ACS0: incwage / (usual hours * imputed weeks)") label(3 "ACS1: mean(ACS0, CPS demo prediction)")*/ label(2 "ACS: CPS state location match of ACS imputed wage") cols(1))  ylabel(1.5(0.10)4.5, labsize(small) angle(0) gmin gmax) xtitle("Percentile", size(small)) xlabel(0(10)100, labsize(small)) ytitle("2017 hourly wage $", size(small)) graphregion(color(white)) title("``group'title'", size(medium)) ysize(3) xsize(4)
	graph export ${output}acscps_wagedist_`group'.pdf, replace
}

/*
use ${output}acscps_cd_wagedist, clear
reshape long p@_binned, i(female new_race sample outcome weight) j(percentile)
rename p_binned wage
gen logwage = log(wage)
gen all = 1 if new_race == . & female == .
gen white = new_race == 1
gen black = new_race == 2
gen hispanic = new_race == 3
gen male = female == 0
tempfile all
save `all'

local alltitle "Overall"
local whitetitle "White only"
local blacktitle "Black only"
local hispanictitle "Hispanic only"
local maletitle "Male only"
local femaletitle "Female only"

foreach group in all white black hispanic female male {
	use `all' if `group' == 1 & (outcome == "hrwage2" | sample == "cps")
	scatter logwage percentile if sample == "cps", msize(small) mcolor("`color4'") msymbol(circle) || scatter logwage percentile if sample == "acs" & weight == "perwt1", mcolor("`color2'") mfcolor(none) || scatter logwage percentile if sample == "acs" & weight == "perwt2", mcolor("`color1'") mfcolor(none) legend( position(10) ring(0) size(small) label(1 "CPS: wageotc") label(2 "ACS weight1: no raking") label(3 "ACS weight1: raked") cols(1)) ylabel(2(0.10)4.5, labsize(small) angle(0) gmin gmax) xtitle("Percentile", size(small)) xlabel(0(10)100, labsize(small)) ytitle("2017 log hourly wage", size(small)) graphregion(color(white)) title("``group'title'", size(medium)) ysize(3) xsize(4)
	graph export ${output}acscps_wagedist_cd_`group'.pdf, replace
}
*/


/* more wage analysis

use ${output}acs_cd116.dta, clear
keep if empstat == 1
gen byte educ5 = .
replace educ5 = 1 if educd <= 61
replace educ5 = 2 if educd >= 63 & educd <= 64
replace educ5 = 3 if educd >= 65 & educd <= 81
replace educ5 = 4 if educd == 101
replace educ5 = 5 if educd >= 114
assert educ5 ~= .
table educ5 [aw=perwt2], c(p50 hrwage2 mean hrwage2)

load_epiextracts, begin(2017m1) end(2017m12) sample(org)
keep if wageotc > 0 & wageotc ~= .
table educ [aw=orgwgt], c(p50 wageotc mean wageotc)



*/
