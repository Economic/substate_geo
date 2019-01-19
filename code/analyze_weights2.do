********************************************************************************
* Diagnostic checks on weights
********************************************************************************
* create in-sample diagnostics
* do ${code}diagnostic_weights_insample.do
/*
* Sample sizes
use ${output}acs_cd116, clear
gen byte male = sex == 1
gen byte female = sex == 2
gen byte white = race == 1
gen byte black = race == 2
gen byte teen = age >= 16 & age <= 19
gen byte prime = age >= 25 & age <= 54
gen byte older = age >= 55
collapse (sum) wpopmale = male wpopfemale = female wpopwhite = white wpopblack = black wpophispanic = hispanic wpopteen = teen wpopprime = prime wpopolder = older (rawsum) obsmale = male obsfemale = female obswhite = white obsblack = black obshispanic = hispanic obsteen = teen obsprime = prime obsolder = older [pw=perwt2], by(cd116)
reshape long obs wpop, i(cd116) j(outcome) string
save ${output}acs_cd116_democounts.dta, replace


local color1 68 1 84
local color2 49 104 142
local color3 53 183 121
local color4 253 231 37

use ${output}acs_cd116_democounts.dta, clear
foreach cat in obs wpop {
	egen total`cat' = total(`cat'), by(outcome)
	gen `cat'share = `cat' / total`cat'
	bysort outcome (`cat'): gen running`cat'share = sum(`cat'share)
	replace running`cat'share = running`cat'share * 100
}
keep if obs <= 1000
scatter runningobsshare obs if outcome == "teen", mcolor("`color1'") msize(small) mlwidth(thin) mfcolor(none) || scatter runningobsshare obs if outcome == "black", mcolor("`color2'") msize(small) mlwidth(thin) mfcolor(none) || scatter runningobsshare obs if outcome == "hispanic", mcolor("`color3'") msize(small) mlwidth(thin) mfcolor(none) xtitle("Observation count", size(small)) xlabel(0(100)1000, labsize(small)) ylabel(0(5)55, labsize(small) angle(0) gmin gmax) ytitle("Share (%)", size(small)) graphregion(color(white)) title("Share of Congressional districts with observations less than a given count", size(medium)) legend(label(1 "Teen") label(2 "Black") label(3 "Hispanic") position(10) ring(0) size(small) cols(1)) xsize(16) ysize(9)
graph export ${output}cddemo_obs_threshold.pdf, replace


stop
*/
********************************************************************************
* Confirm weights total to controls
********************************************************************************
local analysisvars empwhite1664 empwhite6599 empblack1664 empblack6599 empother1664 empother6599 emphispanic1664 emphispanic6599 empnonhispanic1664 empnonhispanic6599 empmale1624 empmale2544 empmale4564 empmale6599 empfemale1624 empfemale2544 empfemale4564 empfemale6599

use ${output}acs_cd116, clear
gen byte empwhite1664 = race == 1 & age >= 16 & age <= 64
gen byte empwhite6599 = race == 1 & age >= 65 & age <= 99
gen byte empblack1664 = race == 2 & age >= 16 & age <= 64
gen byte empblack6599 = race == 2 & age >= 65 & age <= 99
gen byte empother1664 = race >= 3 & age >= 16 & age <= 64
gen byte empother6599 = race >= 3 & age >= 65
gen byte emphispanic1664 = hispanic == 1 & age >= 16 & age <= 64
gen byte emphispanic6599 = hispanic == 1 & age >= 65 & age <= 99
gen byte empnonhispanic1664 = hispanic == 0 & age >= 16 & age <= 64
gen byte empnonhispanic6599 = hispanic == 0 & age >= 65
gen byte empmale1624 = sex == 1 & age >= 16 & age <= 24
gen byte empmale2544 = sex == 1 & age >= 25 & age <= 44
gen byte empmale4564 = sex == 1 & age >= 45 & age <= 64
gen byte empmale6599 = sex == 1 & age >= 65
gen byte empfemale1624 = sex == 2 & age >= 16 & age <= 24
gen byte empfemale2544 = sex == 2 & age >= 25 & age <= 44
gen byte empfemale4564 = sex == 2 & age >= 45 & age <= 64
gen byte empfemale6599 = sex == 2 & age >= 65
tempfile acs
save `acs'

foreach weight in wt1 wt2 {
	use `acs', clear
	gcollapse (sum) `analysisvars' [pw=per`weight'], by(cd116)
	foreach var of varlist `analysisvars' {
		rename `var' `weight'`var'
	}
	tempfile `weight'
	save ``weight''
}
use `wt1', clear
merge 1:1 cd116 using `wt2', assert(3) nogenerate
merge 1:1 cd116 using ${output}acs_tables.dta, assert(3) nogenerate

foreach var of varlist `analysisvars' {
	foreach weight in wt1 wt2 {
		gen pct`weight'`var' = (`weight'`var' / `var' - 1)*100
		*assert (`var') < 0.01
	}
}
*/


import delim ${acsdata}ACS_17_5YR_S2001_ftfy_cd.csv, varnames(1) rowrange(3) clear
destring hc01*, replace
destring geoid2, replace
rename geoid2 cd115
rename hc01_est_vc02 allp50
rename hc01_est_vc15 allftp50
rename hc01_est_vc16 allftmean
rename hc01_est_vc20 lthsp50
rename hc01_est_vc21 hsp50
rename hc01_est_vc22 scolp50
rename hc01_est_vc23 colp50
rename hc01_est_vc24 advp50
keep cd115 *p50
rename cd115 cd116

drop if cd116 == 7298
tempfile acsalltables
save `acsalltables'



use ${output}acs_cd116.dta, clear

gen rincwage = .
replace rincwage = incwage * 361.0 / 342.5 if year == 2013
replace rincwage = incwage * 361.0 / 348.3 if year == 2014
replace rincwage = incwage * 361.0 / 348.9 if year == 2015
replace rincwage = incwage * 361.0 / 353.4 if year == 2016
replace rincwage = incwage * 361.0 / 361.0 if year == 2017
assert rincwage ~= .

gen byte educ5 = .
replace educ5 = 1 if educd <= 61
replace educ5 = 2 if educd >= 63 & educd <= 64
replace educ5 = 3 if educd >= 65 & educd <= 81
replace educ5 = 4 if educd == 101
replace educ5 = 5 if educd >= 114
assert educ5 ~= .

gen byte ftfy = uhrswork >= 35 & wkswork2 == 6

tempfile acs
save `acs'
/*
use `acs', clear
binipolate rincwage [pw=perwt2], binsize(250) by(cd116) collapsefun(gcollapse)
keep cd116 p50_binned
rename p50_binned allp50
tempfile all
save `all'

use `acs', clear
binipolate rincwage [pw=perwt2], binsize(250) by(cd116 ftpt) collapsefun(gcollapse)
keep cd116 ftpt p50_binned
reshape wide p50_binned, i(cd116) j(ftpt)
rename p50_binned1 ftp50
rename p50_binned0 ptp50
tempfile ftp
save `ftp'

use `acs', clear
binipolate rincwage [pw=perwt2], binsize(250) by(cd116 sex) collapsefun(gcollapse)
keep cd116 sex p50_binned
reshape wide p50_binned, i(cd116) j(sex)
rename p50_binned1 malep50
rename p50_binned2 femalep50
tempfile sex
save `sex'

use `acs', clear
binipolate rincwage [pw=perwt2], binsize(250) by(cd116 sex ftfy) collapsefun(gcollapse)
keep cd116 sex ftfy p50_binned
reshape wide p50_binned, i(cd116 ftfy) j(sex)
rename p50_binned1 malep50
rename p50_binned2 femalep50
reshape wide malep50 femalep50, i(cd116) j(ftfy)
rename malep501 maleftp50
rename femalep501 femaleftp50
rename malep500 maleptp50
rename femalep500 femaleptp50
tempfile sexft
save `sexft'
*/
use `acs', clear
keep if age >= 25
binipolate rincwage [pw=perwt1], binsize(250) by(cd116 educ5) collapsefun(gcollapse)
keep cd116 educ5 p50_binned
reshape wide p50_binned, i(cd116) j(educ5)
rename p50_binned1 lthsp50
rename p50_binned2 hsp50
rename p50_binned3 scolp50
rename p50_binned4 colp50
rename p50_binned5 advp50
tempfile educ
save `educ'



use `educ', clear
foreach var of varlist _all {
	rename `var' est_`var'
}
rename est_cd116 cd116

save /tmp/acs_quality2.dta, replace
*/


use /tmp/acs_quality2.dta, clear
merge 1:1 cd116 using `acsalltables', assert(3) nogenerate
gen n = 1

foreach stat in lthsp50 hsp50 scolp50 colp50 advp50 {
	gen diff`stat' = (est_`stat'/`stat'-1)*100
}

keep cd116 diff*
reshape long diff, i(cd116) j(outcome) string

gen educ = .
replace educ = 1 if substr(outcome,1,4) == "lths"
replace educ = 2 if substr(outcome,1,2) == "hs"
replace educ = 3 if substr(outcome,1,4) == "scol"
replace educ = 4 if substr(outcome,1,3) == "col"
replace educ = 5 if substr(outcome,1,3) == "adv"

gen educlabel = ""
replace educlabel = "LTHS: p50 incwage" if educ == 1
replace educlabel = "HS: p50 incwage" if educ == 2
replace educlabel = "Some college: p50 incwage" if educ == 3
replace educlabel = "College: p50 incwage" if educ == 4
replace educlabel = "Advanced: p50 incwage" if educ == 5

local color1 68 1 84
local color2 59 82 139
local color3 33 144 140
local color4 93 200 99
local color5 253 231 37

local coloropt
forvalues i = 1/5 {
	local coloropt `coloropt' box(`i', color("`color`i''")) marker(`i', mlcolor("`color`i''") mlwidth(thin) mfcolor(none))
}
local axislabelopt ylabel(-30(10)50, labsize(small) angle(0) gmin gmax)
local axistitleopt ytitle("Percent difference from ACS tables (%)", size(small))
local layoutopt graphregion(color(white)) title("Difference of our estimate from ACS tables", size(medium)) ysize(3) xsize(4)
local legendopt legend(off) over(educlabel, label(labsize(small)) axis(noline) sort(educ)) asyvars showyvars

graph hbox diff, `coloropt' `axislabelopt' `axistitleopt' `layoutopt' `legendopt'
graph export ${output}boxplot1.pdf, replace
stop


use /tmp/acs_quality.dta, clear
merge 1:1 cd116 using `acsalltables', assert(3) nogenerate
gen n = 1
foreach stat in lthsp50 hsp50 scolp50 colp50 advp50 {
	gen absdiff`stat' = abs(est_`stat'/`stat'-1)*100
	sort absdiff`stat'
	gen `stat'runshare = sum(n)/_N*100
}
scatter lthsp50runshare absdifflthsp50 if absdifflthsp50 <= 16, mcolor("`color1'") msize(small) mlwidth(thin) mfcolor(none) || scatter hsp50runshare absdiffhsp50 if absdiffhsp50 <= 16, mcolor("`color2'") msize(small) mlwidth(thin) mfcolor(none) || scatter scolp50runshare absdiffscolp50 if absdiffscolp50 <= 16, mcolor("`color3'") msize(small) mlwidth(thin) mfcolor(none) || scatter colp50runshare absdiffcolp50 if absdiffcolp50 <= 16, mcolor("`color4'") msize(small) mlwidth(thin) mfcolor(none) || scatter advp50runshare absdiffadvp50 if absdiffadvp50 <= 16, mcolor("`color5'") msize(small) mlwidth(thin) mfcolor(none) xtitle("Absolute value of percent difference from ACS 5-year tables", size(small)) xlabel(2(2)16, labsize(small)) ylabel(0(5)100, labsize(small) angle(0) gmin gmax) ytitle("Share (%)", size(small)) graphregion(color(white)) title("Share of CDs with earnings discrepancies less than a given amount", size(medium)) legend(label(1 "LTHS p50 incwage") label(2 "HS p50 incwage") label(3 "Some col p50 incwage") label(4 "Col p50 incwage") label(5 "Adv p50 incwage") position(10) ring(0) size(small) cols(1))
graph export ${output}educ_p50.pdf, replace
* create out-of-sample diagnostics
* do ${code}diagnostic_weights_exsample.do
