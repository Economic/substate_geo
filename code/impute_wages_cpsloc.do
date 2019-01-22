* calculate quantiles in ACS and match to appropriate percentiles in CPS
*
* 1. To calculate quantiles in ACS, linearly interpolate them according to ACS percentiles.
* To calculate ACS percentiles, linearly interpolate those
* 2. To calculate percentiles in CPS, linearly interpolate them
* 3. To match ACS linearly interpolate quantiles to appropriate CPS percentiles, linearly interpolate between CPS (linearlly interpolated) percentiles

tempfile allacs
save `allacs'

* calculate linearally interpolated percentiles by state year in ACS
binipolate hrwage1 [pw=perwt], binsize(0.25) p(1(1)99) by(year statefips) collapsefun(gcollapse)
drop p*classical
reshape long p@_binned, i(statefips year) j(xtile)
rename p_binned pctile
tempfile acspctile
save `acspctile'

* grab pctiles from CPS
* going to stick with one year of data right now... not sure this is best.
load_epiextracts, begin(2017m1) end(2017m12) sample(org) keep(wageotc statefips)
keep if wageotc > 0 & wageotc ~= .
binipolate wageotc [pw=orgwgt], binsize(0.25) p(1(1)99) by(statefips) collapsefun(gcollapse)
drop p*classical
reshape long p@_binned, i(statefips) j(xtile)
rename p_binned pctile
tempfile cpspctile
save `cpspctile'

* calculate linearly interpolated quantile categories in ACS
use `allacs', clear
* add acs percentiles to the data for use as cutpoints
* do this by a merge:
bysort statefips year: gen xtile = _n
merge 1:1 statefips year xtile using `acspctile', assert(1 3) nogenerate
drop xtile
* calculate xtile for each wage using pctile cutpoints
gquantiles xtile = hrwage1 [pw=perwt], xtile by(year statefips) cutpoints(pctile) cutby
drop pctile
* calculate pctile for surrounding xtiles
merge m:1 statefips year xtile using `acspctile', assert(1 3) nogenerate
rename xtile xtile1
rename pctile acs_pctile1
gen xtile = xtile1 - 1
merge m:1 statefips year xtile using `acspctile', assert(1 3) nogenerate
rename xtile xtile0
rename pctile acs_pctile0
* linearly interpolate xtile from surrounding xtiles using associated pctiles & wage value
gen xtile_ipolate = xtile1 + [(xtile1-xtile0)/(acs_pctile1-acs_pctile0)]*(hrwage1-acs_pctile1)
* deal with edge cases
* assign xtile_ipolate=99 if xtile1=100
* assign  xtile_ipolate=1 if xtile0=0
replace xtile_ipolate = 99 if xtile1 == 100
replace xtile_ipolate = 1 if xtile0 == 0

* merge CPS percentiles
rename xtile1 xtile
merge m:1 statefips xtile using `cpspctile', assert(1 3) nogenerate
rename pctile cps_pctile1
rename xtile xtile1
rename xtile0 xtile
merge m:1 statefips xtile using `cpspctile', assert(1 3) nogenerate
rename pctile cps_pctile0
rename xtile xtile0

* linearly interpolate wage using CPS percentiles and ACS (interpolated) quantile
gen hrwage2 = cps_pctile1 + [(cps_pctile1-cps_pctile0)/(xtile1-xtile0)]*(xtile_ipolate-xtile1)
* deal with edge cases
* assign pctile0 if xtile1 == 100
* assign pctile1 if xtile0 == 0
replace hrwage2 = cps_pctile0 if xtile1 == 100
replace hrwage2 = cps_pctile1 if xtile0 == 0

drop *pctile* *xtile*
