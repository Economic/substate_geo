********************************************************************************
* Diagnostic checks on weights
********************************************************************************
* create in-sample diagnostics
* do ${code}diagnostic_weights_insample.do

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
*/

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
scatter runningobsshare obs if outcome == "teen", mcolor("`color1'") msize(small) mlwidth(thin) mfcolor(none) || scatter runningobsshare obs if outcome == "black", mcolor("`color2'") msize(small) mlwidth(thin) mfcolor(none) || scatter runningobsshare obs if outcome == "hispanic", mcolor("`color3'") msize(small) mlwidth(thin) mfcolor(none) xtitle("Observation count", size(small)) xlabel(0(100)1000, labsize(small)) ylabel(0(5)55, labsize(small) angle(0) gmin gmax) ytitle("Share (%)", size(small)) graphregion(color(white)) title("Share of Congressional districts with observations less than a given count", size(medium)) legend(label(1 "Teen") label(2 "Black") label(3 "Hispanic") position(10) ring(0) size(small) cols(1))
graph export ${output}cddemo_obs_threshold.pdf, replace


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
		assert (`var') < 0.01
	}
}



* create out-of-sample diagnostics
* do ${code}diagnostic_weights_exsample.do
